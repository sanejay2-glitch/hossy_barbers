import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/app/app.dart';

void main() {
  testWidgets('desktop home presents navigation and booking call to action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const HossyBarbersApp());

    expect(find.text('HOSSY BARBERS'), findsWidgets);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Book now'), findsOneWidget);
    expect(find.text('Book appointment'), findsOneWidget);
  });

  testWidgets('mobile home opens booking flow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const HossyBarbersApp());

    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
    await tester.ensureVisible(find.text('Book now'));
    await tester.tap(find.text('Book now'));
    await tester.pumpAndSettle();

    expect(find.text('Book an appointment'), findsOneWidget);
    expect(find.text('Phone or WhatsApp number'), findsOneWidget);
    expect(find.text('Review booking request'), findsOneWidget);
  });

  testWidgets('admin route stays unavailable until Firebase is configured', (
    tester,
  ) async {
    await tester.pumpWidget(const HossyBarbersApp());

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/admin');
    await tester.pumpAndSettle();

    expect(find.text('Hossy Barbers Admin'), findsOneWidget);
    expect(
      find.textContaining('Firebase has not been configured'),
      findsOneWidget,
    );
  });

  testWidgets('direct admin deep link resolves to the admin gate', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/admin';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.pumpWidget(const HossyBarbersApp());
    await tester.pumpAndSettle();

    expect(find.text('Hossy Barbers Admin'), findsOneWidget);
    expect(
      find.textContaining('Firebase has not been configured'),
      findsOneWidget,
    );
  });
}
