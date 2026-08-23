const assert = require('node:assert/strict');
const test = require('node:test');
const {
  createPaymentAccessToken,
  createPaymentReference,
  evaluateChargeVerification,
  isFlutterwaveWebhookSignatureValid,
  parseServiceAmount,
  shouldProcessWebhookEvent,
} = require('../src/payment_domain');

test('creates Flutterwave-compatible unique payment references', () => {
  const reference = createPaymentReference('booking_123');

  assert.match(reference, /^[a-zA-Z0-9-]{6,42}$/);
  assert.notEqual(reference, createPaymentReference('booking_123'));
});

test('parses valid NGN price formats and rejects invalid amounts', () => {
  assert.equal(parseServiceAmount('₦ 4,500.50'), 4500.5);
  assert.equal(parseServiceAmount(5000), 5000);
  assert.throws(() => parseServiceAmount('price on request'));
  assert.throws(() => parseServiceAmount('0'));
});

test('confirms only a matching successful Flutterwave charge', () => {
  const result = evaluateChargeVerification({
    charge: {reference: 'HB-TEST-123', amount: 5000, currency: 'NGN', status: 'succeeded'},
    expectedReference: 'HB-TEST-123',
    expectedAmount: 5000,
    expectedCurrency: 'NGN',
  });

  assert.deepEqual(result, {paymentStatus: 'successful'});
});

test('keeps failed or mismatched provider results out of confirmed state', () => {
  const failed = evaluateChargeVerification({
    charge: {reference: 'HB-TEST-123', amount: 5000, currency: 'NGN', status: 'failed'},
    expectedReference: 'HB-TEST-123',
    expectedAmount: 5000,
    expectedCurrency: 'NGN',
  });
  const mismatched = evaluateChargeVerification({
    charge: {reference: 'OTHER', amount: 5000, currency: 'NGN', status: 'succeeded'},
    expectedReference: 'HB-TEST-123',
    expectedAmount: 5000,
    expectedCurrency: 'NGN',
  });

  assert.equal(failed.paymentStatus, 'failed');
  assert.equal(mismatched.paymentStatus, 'failed');
});

test('validates webhook signatures and generates opaque customer access tokens', () => {
  const body = '{"id":"event-1"}';
  const secret = 'sandbox-webhook-secret';
  const crypto = require('node:crypto');
  const signature = crypto.createHmac('sha256', secret).update(body).digest('base64');

  assert.equal(isFlutterwaveWebhookSignatureValid(body, signature, secret), true);
  assert.equal(isFlutterwaveWebhookSignatureValid(body, signature, 'wrong'), false);
  assert.match(createPaymentAccessToken(), /^[A-Za-z0-9_-]{40,}$/);
});

test('does not process an already completed webhook event twice', () => {
  assert.equal(shouldProcessWebhookEvent({processedAt: '2026-08-22'}), false);
  assert.equal(shouldProcessWebhookEvent({processingAt: '2026-08-22'}), false);
  assert.equal(shouldProcessWebhookEvent({}), true);
});
