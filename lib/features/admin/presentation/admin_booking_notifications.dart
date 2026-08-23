import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/admin/domain/booking_notification.dart';
import 'package:hossy_barbers/features/admin/services/booking_notification_service.dart';

class AdminBookingNotifications extends StatefulWidget {
  const AdminBookingNotifications({
    super.key,
    required this.service,
    required this.onOpenBookings,
  });

  final BookingNotificationService service;
  final VoidCallback onOpenBookings;

  @override
  State<AdminBookingNotifications> createState() =>
      _AdminBookingNotificationsState();
}

class _AdminBookingNotificationsState extends State<AdminBookingNotifications> {
  late final StreamSubscription _newBookingSubscription;

  @override
  void initState() {
    super.initState();
    _newBookingSubscription = widget.service.newBookings.listen((booking) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'New booking request: ${booking.customerName} • ${booking.serviceName}',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              widget.onOpenBookings();
              widget.service.markRead(booking.id);
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _newBookingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.service.state,
    builder: (context, state, _) => MenuAnchor(
      menuChildren: [
        SizedBox(
          width: 360,
          child: _NotificationsPanel(
            state: state,
            onOpenNotification: (notification) async {
              await widget.service.markRead(notification.booking.id);
              widget.onOpenBookings();
            },
            onMarkAllRead: widget.service.markAllRead,
            onEnableBrowserAlerts: widget.service.requestBrowserNotifications,
          ),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Booking notifications',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: Badge.count(
          count: state.unreadCount,
          isLabelVisible: state.unreadCount > 0,
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ),
    ),
  );
}

class _NotificationsPanel extends StatelessWidget {
  const _NotificationsPanel({
    required this.state,
    required this.onOpenNotification,
    required this.onMarkAllRead,
    required this.onEnableBrowserAlerts,
  });

  final BookingNotificationsState state;
  final ValueChanged<BookingNotification> onOpenNotification;
  final Future<void> Function() onMarkAllRead;
  final Future<BrowserNotificationPermission> Function() onEnableBrowserAlerts;

  @override
  Widget build(BuildContext context) {
    final notifications = state.notifications.take(8).toList(growable: false);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Booking notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (state.unreadCount > 0)
                  TextButton(
                    onPressed: onMarkAllRead,
                    child: const Text('Mark all read'),
                  ),
              ],
            ),
            if (state.browserNotificationsSupported &&
                state.browserPermission ==
                    BrowserNotificationPermission.defaultPermission)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: TextButton.icon(
                  onPressed: () async => onEnableBrowserAlerts(),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Enable browser alerts'),
                ),
              ),
            if (state.browserPermission == BrowserNotificationPermission.denied)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.small),
                child: Text(
                  'Browser alerts are blocked. In-app booking alerts remain active.',
                ),
              ),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
                child: Center(child: Text('No booking notifications yet.')),
              )
            else
              ...notifications.map(
                (notification) => _BookingNotificationTile(
                  notification: notification,
                  onTap: () => onOpenNotification(notification),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingNotificationTile extends StatelessWidget {
  const _BookingNotificationTile({
    required this.notification,
    required this.onTap,
  });

  final BookingNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final booking = notification.booking;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              notification.isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              color: notification.isRead
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New booking request',
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w800,
                    ),
                  ),
                  Text('${booking.customerName} • ${booking.serviceName}'),
                  Text('${booking.preferredDate} • ${booking.preferredTime}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
