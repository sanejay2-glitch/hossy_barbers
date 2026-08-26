import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('review summary stays public-read and admin-write only', () async {
    final rules = await File('firestore.rules').readAsString();

    expect(rules, contains('match /reviewSummaries/main'));
    expect(rules, contains('allow read: if true;'));
    expect(rules, contains('allow write: if isAdmin();'));
  });
}
