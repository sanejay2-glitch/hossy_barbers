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
    expect(find.text('Book now'), findsNWidgets(2));
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
    expect(find.text('Continue to WhatsApp'), findsOneWidget);
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
}
