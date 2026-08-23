const crypto = require('node:crypto');
const {getApps, initializeApp} = require('firebase-admin/app');
const {FieldValue, getFirestore} = require('firebase-admin/firestore');
const {logger} = require('firebase-functions');
const {defineSecret, defineString} = require('firebase-functions/params');
const {HttpsError, onCall, onRequest} = require('firebase-functions/v2/https');
const {FlutterwaveSandboxClient} = require('./src/flutterwave_client');
const {
  createPaymentAccessToken,
  createPaymentReference,
  evaluateChargeVerification,
  isFlutterwaveWebhookSignatureValid,
  parseServiceAmount,
  shouldProcessWebhookEvent,
} = require('./src/payment_domain');

if (!getApps().length) {
  initializeApp();
}

const db = getFirestore();
const flutterwaveClientId = defineSecret('FLW_SANDBOX_CLIENT_ID');
const flutterwaveClientSecret = defineSecret('FLW_SANDBOX_CLIENT_SECRET');
const flutterwaveWebhookSecret = defineSecret('FLW_SANDBOX_WEBHOOK_SECRET');
const paymentCurrency = defineString('PAYMENT_CURRENCY', {default: 'NGN'});
const paymentPublicBaseUrl = defineString('PAYMENT_PUBLIC_BASE_URL', {
  default: 'https://hossy-barbers.web.app',
});

exports.acceptBooking = onCall(async (request) => {
  await requireActiveAdmin(request);
  const bookingId = requiredId(request.data?.bookingId, 'bookingId');
  const bookingRef = db.collection('bookings').doc(bookingId);
  const paymentUrl = await db.runTransaction(async (transaction) => {
    const bookingSnapshot = await transaction.get(bookingRef);
    if (!bookingSnapshot.exists) {
      throw new HttpsError('not-found', 'Booking request not found.');
    }
    const booking = bookingSnapshot.data();
    if (booking.status !== 'prepared') {
      throw new HttpsError('failed-precondition', 'Only prepared booking requests can be accepted.');
    }
    if (typeof booking.customerEmail !== 'string' || booking.customerEmail.length < 3) {
      throw new HttpsError('failed-precondition', 'A customer email address is required before payment can be requested.');
    }
    const serviceSnapshot = await transaction.get(
      db.collection('services').doc(booking.serviceId),
    );
    if (!serviceSnapshot.exists || serviceSnapshot.get('isActive') !== true) {
      throw new HttpsError('failed-precondition', 'The selected service is no longer bookable.');
    }

    let amount;
    try {
      amount = parseServiceAmount(serviceSnapshot.get('price'));
    } catch (error) {
      throw new HttpsError('failed-precondition', error.message);
    }
    const accessToken = createPaymentAccessToken();
    const reference = createPaymentReference(bookingSnapshot.id);
    const currency = paymentCurrency.value();
    transaction.update(bookingRef, {
      status: 'accepted',
      paymentStatus: 'pending',
      paymentReference: reference,
      paymentAmount: amount,
      paymentCurrency: currency,
      paymentAccessToken: accessToken,
      paymentCreatedAt: FieldValue.serverTimestamp(),
      paymentTransactionId: FieldValue.delete(),
      paymentVerifiedAt: FieldValue.delete(),
      paymentFailureReason: FieldValue.delete(),
      adminUpdatedAt: FieldValue.serverTimestamp(),
    });
    return paymentUrlFor(accessToken);
  });

  const accepted = await bookingRef.get();
  return {
    paymentUrl,
    paymentReference: accepted.get('paymentReference'),
    amount: accepted.get('paymentAmount'),
    currency: accepted.get('paymentCurrency'),
  };
});

exports.declineBooking = onCall(async (request) => {
  await requireActiveAdmin(request);
  const bookingId = requiredId(request.data?.bookingId, 'bookingId');
  const bookingRef = db.collection('bookings').doc(bookingId);
  await db.runTransaction(async (transaction) => {
    const bookingSnapshot = await transaction.get(bookingRef);
    if (!bookingSnapshot.exists) {
      throw new HttpsError('not-found', 'Booking request not found.');
    }
    if (bookingSnapshot.get('status') !== 'prepared') {
      throw new HttpsError('failed-precondition', 'Only prepared booking requests can be declined.');
    }
    transaction.update(bookingRef, {
      status: 'declined',
      paymentStatus: 'not_required',
      adminUpdatedAt: FieldValue.serverTimestamp(),
    });
  });
  return {status: 'declined'};
});

exports.cancelAcceptedBooking = onCall(async (request) => {
  await requireActiveAdmin(request);
  const bookingId = requiredId(request.data?.bookingId, 'bookingId');
  const bookingRef = db.collection('bookings').doc(bookingId);
  await db.runTransaction(async (transaction) => {
    const bookingSnapshot = await transaction.get(bookingRef);
    if (!bookingSnapshot.exists) {
      throw new HttpsError('not-found', 'Booking request not found.');
    }
    if (!['prepared', 'accepted'].includes(bookingSnapshot.get('status'))) {
      throw new HttpsError('failed-precondition', 'This booking can no longer be cancelled.');
    }
    transaction.update(bookingRef, {
      status: 'cancelled',
      paymentStatus: bookingSnapshot.get('paymentStatus') === 'successful'
        ? 'successful'
        : 'cancelled',
      adminUpdatedAt: FieldValue.serverTimestamp(),
    });
  });
  return {status: 'cancelled'};
});

exports.getPaymentDetails = onCall(async (request) => {
  const booking = await bookingForPaymentToken(request.data?.paymentToken);
  return publicPaymentDetails(booking);
});

exports.startFlutterwavePayment = onCall(
  {secrets: [flutterwaveClientId, flutterwaveClientSecret]},
  async (request) => {
    const paymentMethodId = requiredId(request.data?.paymentMethodId, 'paymentMethodId');
    const booking = await bookingForPaymentToken(request.data?.paymentToken);
    assertPaymentCanStart(booking);
    if (!booking.customerEmail) {
      throw new HttpsError('failed-precondition', 'An email address is required to start payment.');
    }

    const client = sandboxClient();
    try {
      const customer = await client.createCustomer({
        name: booking.customerName,
        email: booking.customerEmail,
        phoneNumber: booking.customerPhone,
        bookingId: booking.id,
      });
      const charge = await client.createCharge({
        customerId: customer.id,
        paymentMethodId,
        booking,
        redirectUrl: paymentUrlFor(booking.paymentAccessToken),
      });
      await db.collection('bookings').doc(booking.id).update({
        paymentTransactionId: charge.id,
        paymentStatus: 'pending',
        paymentStartedAt: FieldValue.serverTimestamp(),
      });
      const checkoutUrl = charge?.next_action?.redirect_url?.url;
      return {
        checkoutUrl: typeof checkoutUrl === 'string' ? checkoutUrl : null,
        paymentStatus: 'pending',
      };
    } catch (error) {
      logger.error('Flutterwave sandbox charge creation failed', {bookingId: booking.id, error});
      throw new HttpsError('internal', 'The secure payment session could not be started.');
    }
  },
);

exports.verifyFlutterwavePayment = onCall(
  {secrets: [flutterwaveClientId, flutterwaveClientSecret]},
  async (request) => {
    const booking = await bookingForPaymentToken(request.data?.paymentToken);
    if (!booking.paymentTransactionId) {
      return publicPaymentDetails(booking);
    }
    const updated = await verifyAndApplyCharge({
      booking,
      chargeId: booking.paymentTransactionId,
      client: sandboxClient(),
    });
    return publicPaymentDetails(updated);
  },
);

exports.flutterwaveWebhook = onRequest(
  {secrets: [flutterwaveClientId, flutterwaveClientSecret, flutterwaveWebhookSecret]},
  async (request, response) => {
    if (request.method !== 'POST') {
      response.status(405).send('Method not allowed');
      return;
    }
    const rawBody = request.rawBody?.toString('utf8') || '';
    const signature = request.get('flutterwave-signature');
    if (!isFlutterwaveWebhookSignatureValid(rawBody, signature, flutterwaveWebhookSecret.value())) {
      response.status(401).send('Invalid signature');
      return;
    }

    const event = request.body;
    if (event?.type !== 'charge.completed' || !event?.id || !event?.data?.id) {
      response.status(200).send('Ignored');
      return;
    }
    const eventRef = db.collection('paymentWebhookEvents').doc(hashEventId(event.id));
    const shouldProcess = await claimWebhookEvent(eventRef, event.id);
    if (!shouldProcess) {
      response.status(200).send('Already processed');
      return;
    }

    try {
      const booking = await bookingForReference(event.data.reference);
      if (!booking) {
        await eventRef.update({processedAt: FieldValue.serverTimestamp(), outcome: 'booking_not_found'});
        response.status(200).send('Ignored');
        return;
      }
      const result = await verifyAndApplyCharge({
        booking,
        chargeId: event.data.id,
        client: sandboxClient(),
      });
      await eventRef.update({
        processedAt: FieldValue.serverTimestamp(),
        outcome: result.paymentStatus,
        bookingId: result.id,
      });
      response.status(200).send('OK');
    } catch (error) {
      logger.error('Flutterwave webhook processing failed', {eventId: event.id, error});
      await eventRef.set({
        lastError: String(error.message || error),
        processingAt: FieldValue.delete(),
      }, {merge: true});
      response.status(500).send('Retry later');
    }
  },
);

async function requireActiveAdmin(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Sign in to manage booking requests.');
  }
  const admin = await db.collection('adminUsers').doc(request.auth.uid).get();
  if (!admin.exists || admin.get('active') !== true) {
    throw new HttpsError('permission-denied', 'Administrator access is required.');
  }
}

function requiredId(value, name) {
  if (typeof value !== 'string' || !/^[a-zA-Z0-9_-]{4,200}$/.test(value)) {
    throw new HttpsError('invalid-argument', `${name} is invalid.`);
  }
  return value;
}

function paymentUrlFor(accessToken) {
  const baseUrl = paymentPublicBaseUrl.value().replace(/\/$/, '');
  return `${baseUrl}/payment?token=${encodeURIComponent(accessToken)}`;
}

function sandboxClient() {
  return new FlutterwaveSandboxClient({
    clientId: flutterwaveClientId.value(),
    clientSecret: flutterwaveClientSecret.value(),
  });
}

async function bookingForPaymentToken(accessToken) {
  if (typeof accessToken !== 'string' || accessToken.length < 40) {
    throw new HttpsError('invalid-argument', 'Payment link is invalid.');
  }
  const snapshot = await db
    .collection('bookings')
    .where('paymentAccessToken', '==', accessToken)
    .limit(1)
    .get();
  if (snapshot.empty) {
    throw new HttpsError('not-found', 'Payment link is unavailable.');
  }
  return withId(snapshot.docs[0]);
}

async function bookingForReference(reference) {
  if (typeof reference !== 'string' || reference.length < 6) {
    return undefined;
  }
  const snapshot = await db
    .collection('bookings')
    .where('paymentReference', '==', reference)
    .limit(1)
    .get();
  return snapshot.empty ? undefined : withId(snapshot.docs[0]);
}

function withId(snapshot) {
  return {id: snapshot.id, ...snapshot.data()};
}

function assertPaymentCanStart(booking) {
  if (booking.status !== 'accepted' || booking.paymentStatus !== 'pending') {
    throw new HttpsError('failed-precondition', 'Payment is not available for this booking.');
  }
  if (!booking.paymentReference || !booking.paymentAmount || !booking.paymentCurrency) {
    throw new HttpsError('failed-precondition', 'This booking does not have a payment requirement.');
  }
  if (booking.paymentTransactionId) {
    throw new HttpsError('failed-precondition', 'A secure payment session is already in progress.');
  }
}

async function verifyAndApplyCharge({booking, chargeId, client}) {
  const charge = await client.retrieveCharge(chargeId);
  const verification = evaluateChargeVerification({
    charge,
    expectedReference: booking.paymentReference,
    expectedAmount: booking.paymentAmount,
    expectedCurrency: booking.paymentCurrency,
  });
  const bookingRef = db.collection('bookings').doc(booking.id);
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(bookingRef);
    if (!snapshot.exists || snapshot.get('paymentReference') !== booking.paymentReference) {
      return;
    }
    if (snapshot.get('paymentStatus') === 'successful') {
      return;
    }
    const update = {
      paymentStatus: verification.paymentStatus,
      paymentTransactionId: charge.id,
      paymentVerifiedAt: FieldValue.serverTimestamp(),
    };
    if (verification.paymentStatus === 'successful') {
      if (snapshot.get('status') === 'accepted') {
        update.status = 'confirmed';
      }
      update.paymentFailureReason = FieldValue.delete();
    } else if (verification.failureReason) {
      update.paymentFailureReason = verification.failureReason;
    }
    transaction.update(bookingRef, update);
  });
  return withId(await bookingRef.get());
}

function publicPaymentDetails(booking) {
  return {
    bookingId: booking.id,
    serviceName: booking.serviceName,
    preferredDate: booking.preferredDate,
    preferredTime: booking.preferredTime,
    bookingStatus: booking.status,
    paymentStatus: booking.paymentStatus || 'not_required',
    amount: booking.paymentAmount || null,
    currency: booking.paymentCurrency || null,
    reference: booking.paymentReference || null,
    failureReason: booking.paymentFailureReason || null,
  };
}

async function claimWebhookEvent(eventRef, eventId) {
  return db.runTransaction(async (transaction) => {
    const existing = await transaction.get(eventRef);
    if (existing.exists && !shouldProcessWebhookEvent(existing.data())) {
      return false;
    }
    transaction.set(eventRef, {
      eventId,
      receivedAt: FieldValue.serverTimestamp(),
      processingAt: FieldValue.serverTimestamp(),
      attempts: FieldValue.increment(1),
    }, {merge: true});
    return true;
  });
}

function hashEventId(eventId) {
  return crypto.createHash('sha256').update(String(eventId)).digest('hex');
}
