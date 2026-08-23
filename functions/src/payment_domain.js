const crypto = require('node:crypto');

const bookingStatuses = Object.freeze([
  'prepared',
  'accepted',
  'declined',
  'cancelled',
  'confirmed',
]);

const paymentStatuses = Object.freeze([
  'not_required',
  'pending',
  'successful',
  'failed',
  'cancelled',
]);

function parseServiceAmount(price) {
  if (typeof price === 'number') {
    return normalizeAmount(price);
  }
  if (typeof price !== 'string') {
    throw new Error('The accepted service does not have a valid price.');
  }

  const normalized = price
    .trim()
    .replace(/^(?:NGN|₦)\s*/i, '')
    .replace(/,/g, '');
  if (!/^\d+(?:\.\d{1,2})?$/.test(normalized)) {
    throw new Error('The accepted service does not have a valid price.');
  }
  return normalizeAmount(Number(normalized));
}

function normalizeAmount(amount) {
  if (!Number.isFinite(amount) || amount < 0.01) {
    throw new Error('The accepted service does not have a valid price.');
  }
  return Number(amount.toFixed(2));
}

function createPaymentReference(bookingId) {
  const safeBookingId = String(bookingId).replace(/[^a-zA-Z0-9]/g, '').slice(0, 14);
  const suffix = crypto.randomBytes(10).toString('hex');
  return `HB-${safeBookingId || 'BOOKING'}-${suffix}`.slice(0, 42);
}

function createPaymentAccessToken() {
  return crypto.randomBytes(32).toString('base64url');
}

function isFlutterwaveWebhookSignatureValid(rawBody, signature, secret) {
  if (typeof rawBody !== 'string' || !signature || !secret) {
    return false;
  }
  const expected = crypto
    .createHmac('sha256', secret)
    .update(rawBody)
    .digest('base64');
  const actualBuffer = Buffer.from(signature);
  const expectedBuffer = Buffer.from(expected);
  return actualBuffer.length === expectedBuffer.length && crypto.timingSafeEqual(actualBuffer, expectedBuffer);
}

function shouldProcessWebhookEvent(existingEvent) {
  return !existingEvent?.processedAt && !existingEvent?.processingAt;
}

function evaluateChargeVerification({charge, expectedReference, expectedAmount, expectedCurrency}) {
  const matchesBooking =
    charge?.reference === expectedReference &&
    Number(charge?.amount) === Number(expectedAmount) &&
    charge?.currency === expectedCurrency;

  if (!matchesBooking) {
    return {paymentStatus: 'failed', failureReason: 'Payment verification did not match this booking.'};
  }
  if (charge.status === 'succeeded') {
    return {paymentStatus: 'successful'};
  }
  if (charge.status === 'failed') {
    return {paymentStatus: 'failed', failureReason: 'Flutterwave reported that the payment failed.'};
  }
  if (charge.status === 'cancelled') {
    return {paymentStatus: 'cancelled', failureReason: 'Flutterwave reported that the payment was cancelled.'};
  }
  return {paymentStatus: 'pending'};
}

module.exports = {
  bookingStatuses,
  paymentStatuses,
  createPaymentAccessToken,
  createPaymentReference,
  evaluateChargeVerification,
  isFlutterwaveWebhookSignatureValid,
  parseServiceAmount,
  shouldProcessWebhookEvent,
};
