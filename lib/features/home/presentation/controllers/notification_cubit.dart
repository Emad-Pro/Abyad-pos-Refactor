import 'package:abyadpos_tab/features/home/data/models/notification_model.dart';
import 'package:abyadpos_tab/features/home/presentation/controllers/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState());

  void markAsRead(int id) {
    final index = state.notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updatedNotifications = List<NotificationModel>.from(state.notifications);

      updatedNotifications[index].isRead = true;

      emit(state.copyWith(notifications: updatedNotifications));
    }
  }

  void addNotification(NotificationModel notification) {
    final updatedNotifications = List<NotificationModel>.from(state.notifications)
      ..insert(0, notification);

    emit(state.copyWith(notifications: updatedNotifications));
  }

  void clearAll() {
    emit(state.copyWith(notifications: []));
  }
}
