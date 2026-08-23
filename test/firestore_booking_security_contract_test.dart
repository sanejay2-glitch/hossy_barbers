import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'booking rules deny customer updates and allow limited admin workflow',
    () async {
      final rules = await File('firestore.rules').readAsString();

      expect(
        rules,
        contains("request.resource.data.paymentStatus == 'not_required'"),
      );
      expect(rules, contains('function hasAllowedAdminBookingTransition()'));
      expect(rules, contains("hasOnly(['status', 'adminUpdatedAt'])"));
      expect(
        rules,
        contains('allow update: if hasAllowedAdminBookingTransition();'),
      );
      expect(rules, contains('allow delete: if false;'));
    },
  );
}
