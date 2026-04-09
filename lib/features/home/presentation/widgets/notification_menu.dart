import 'package:abyadpos_tab/features/home/presentation/controllers/notification_cubit.dart';
import 'package:abyadpos_tab/features/home/presentation/controllers/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:abyadpos_tab/main.dart';

import 'package:abyadpos_tab/features/home/data/models/notification_model.dart';

class NotificationMenuController {
  static VoidCallback? _onHideMenu;

  static void registerHideMenu(VoidCallback? hideMenuCallback) {
    _onHideMenu = hideMenuCallback;
  }

  static void unregisterHideMenu() {
    _onHideMenu = null;
  }

  static void hide() {
    if (_onHideMenu != null) {
      try {
        _onHideMenu!();
      } catch (_) {
        // swallow errors, but ensure callback cleared if it's invalid
        _onHideMenu = null;
      }
    }
  }
}

class NotificationIconWithMenu extends StatefulWidget {
  @override
  _NotificationIconWithMenuState createState() => _NotificationIconWithMenuState();
}

class _NotificationIconWithMenuState extends State<NotificationIconWithMenu> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    NotificationMenuController.registerHideMenu(_hideMenu);
  }

  @override
  void dispose() {
    // Ensure overlay removed and static reference cleared
    _hideMenu();
    NotificationMenuController.unregisterHideMenu();
    super.dispose();
  }

  void _showMenu() {
    if (!mounted) return;
    // defensive: ensure render object exists
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject == null || !(renderObject is RenderBox)) return;

    final renderBox = renderObject;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(offset);
    // use root overlay to ensure overlay stays above everything
    final overlay = Overlay.of(context, rootOverlay: true);
    if (_overlayEntry != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlayEntry(Offset offset) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + 40,
        right: isArabic ? null : 100,
        left: isArabic ? 100 : null,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(state),
                    Divider(height: 1),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: state.notifications.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = state.notifications[index];
                          return _buildNotificationItem(
                            notification,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _hideMenu() {
    try {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    } catch (_) {
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: () {
        if (_overlayEntry == null) {
          _showMenu();
        } else {
          _hideMenu();
        }
      },
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (state.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        state.unreadCount > 9 ? "9+" : "${state.unreadCount}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  // Make sure you have this import at top of file:
// import 'package:abyadpos_tab/controller/Viewmodel/notification_provider.dart';

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "No notifications",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NotificationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            "Notifications",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          if (state.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${state.unreadCount} new",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          SizedBox(width: 8),
          TextButton(
            onPressed: () {
              context.read<NotificationCubit>().clearAll();
              _hideMenu();
            },
            child: Text("Clear all"),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    }
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.event,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          SizedBox(height: 4),
          Text(
            _formatTime(notification.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: notification.isRead ? null : Icon(Icons.circle, color: Colors.red, size: 8),
      onTap: () {
        context.read<NotificationCubit>().markAsRead(notification.id);
        // optionally navigate to detail here
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
    );
  }

// notification item builders and helpers omitted for brevity,
// you can keep the same _buildNotificationItem and _formatTime methods
}
