import 'package:abyadpos_tab/features/home/data/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;

  NotificationState({
    this.notifications = const [],
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}
