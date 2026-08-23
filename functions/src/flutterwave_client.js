const crypto = require('node:crypto');

const sandboxBaseUrl = 'https://developersandbox-api.flutterwave.com';
const tokenUrl = 'https://idp.flutterwave.com/realms/flutterwave/protocol/openid-connect/token';

class FlutterwaveSandboxClient {
  constructor({clientId, clientSecret, fetchImpl = fetch}) {
    this.clientId = clientId;
    this.clientSecret = clientSecret;
    this.fetchImpl = fetchImpl;
    this.accessToken = undefined;
    this.accessTokenExpiresAt = 0;
  }

  async createCustomer({name, email, phoneNumber, bookingId}) {
    const names = name.trim().split(/\s+/);
    const phone = phoneNumber.replace(/\D/g, '').replace(/^234/, '');
    const response = await this._request('/customers', {
      method: 'POST',
      body: {
        email,
        name: {
          first: names[0] || 'Customer',
          last: names.slice(1).join(' ') || 'Customer',
        },
        phone: {country_code: '234', number: phone},
        meta: {booking_id: bookingId},
      },
    });
    return response.data;
  }

  async createCharge({customerId, paymentMethodId, booking, redirectUrl}) {
    const response = await this._request('/charges', {
      method: 'POST',
      idempotencyKey: booking.paymentReference,
      body: {
        reference: booking.paymentReference,
        currency: booking.paymentCurrency,
        customer_id: customerId,
        payment_method_id: paymentMethodId,
        amount: booking.paymentAmount,
        redirect_url: redirectUrl,
        meta: {booking_id: booking.id},
      },
    });
    return response.data;
  }

  async retrieveCharge(chargeId) {
    const response = await this._request(`/charges/${encodeURIComponent(chargeId)}`, {
      method: 'GET',
    });
    return response.data;
  }

  async _request(path, {method, body, idempotencyKey}) {
    const accessToken = await this._getAccessToken();
    const response = await this.fetchImpl(`${sandboxBaseUrl}${path}`, {
      method,
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
        'X-Trace-Id': crypto.randomUUID(),
        ...(idempotencyKey ? {'X-Idempotency-Key': idempotencyKey} : {}),
      },
      ...(body ? {body: JSON.stringify(body)} : {}),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok || data.status === 'failed') {
      throw new Error(data?.error?.message || data?.message || 'Flutterwave could not process the payment request.');
    }
    return data;
  }

  async _getAccessToken() {
    if (this.accessToken && Date.now() < this.accessTokenExpiresAt) {
      return this.accessToken;
    }
    const body = new URLSearchParams({
      client_id: this.clientId,
      client_secret: this.clientSecret,
      grant_type: 'client_credentials',
    });
    const response = await this.fetchImpl(tokenUrl, {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body,
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok || !data.access_token) {
      throw new Error('Flutterwave sandbox authentication failed.');
    }
    this.accessToken = data.access_token;
    this.accessTokenExpiresAt = Date.now() + Math.max(0, Number(data.expires_in || 600) - 30) * 1000;
    return this.accessToken;
  }
}

module.exports = {FlutterwaveSandboxClient};
