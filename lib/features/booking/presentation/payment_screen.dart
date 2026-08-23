import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  static const routeName = '/payment';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hossy Barbers payment')),
    body: SingleChildScrollView(
      child: PageContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: AppSpacing.xLarge,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: const _PaymentUnavailable(),
        ),
      ),
    ),
  );
}

class _PaymentUnavailable extends StatelessWidget {
  const _PaymentUnavailable();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Online payment is not active yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Your booking is not confirmed by visiting this page. Hossy Barbers will contact you directly to confirm your appointment and payment.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
