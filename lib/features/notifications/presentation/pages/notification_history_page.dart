import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/models/notification_model.dart';
import 'package:mobile_pager_flutter/features/notifications/presentation/providers/notification_providers.dart';

class NotificationHistoryPage extends ConsumerWidget 
{
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) 
  {
    final user = ref.watch(authNotifierProvider.select((state) => state.user));

    if (user == null) {return Scaffold(body: Center(child: Text('Please login')));}

    final notificationsAsync = ref.watch(userNotificationsProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.textPrimary),
        actions: <Widget>[
          IconButton(
            onPressed: () => _markAllAsRead(context, ref, user.uid),
            icon: Icon(Iconsax.tick_circle),
            tooltip: 'Tandai semua dibaca',
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading notifications: $error',
            style: GoogleFonts.inter(color: Colors.red),
          ),
        ),
        data: (notifications) 
        {
          if (notifications.isEmpty) 
          {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Iconsax.notification,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Belum ada notifikasi',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(AppPadding.p16),
            itemCount: notifications.length,
            itemBuilder: (context, index) 
            {
              final notification = notifications[index];
              return _buildNotificationCard(context, ref, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, NotificationModel notification) 
  {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColor.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade200 : AppColor.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(ref, notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      notification.body,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(notification.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) 
  {
    switch (type) 
    {
      case NotificationType.newCustomer:
        return Iconsax.user_add;
      case NotificationType.orderReady:
        return Iconsax.tick_circle;
      case NotificationType.orderCalling:
        return Iconsax.notification_bing;
      case NotificationType.orderExpiringSoon:
        return Iconsax.timer_1;
      case NotificationType.orderExpired:
        return Iconsax.close_circle;
      case NotificationType.orderFinished:
        return Iconsax.verify;
    } // 'default' case already covered, no need to add it
  }

  Color _getNotificationColor(NotificationType type) 
  {
    switch (type) 
    {
      case NotificationType.newCustomer:
        return Colors.blue;
      case NotificationType.orderReady:
        return Colors.green;
      case NotificationType.orderCalling:
        return Colors.orange;
      case NotificationType.orderExpiringSoon:
        return Colors.orange.shade700;
      case NotificationType.orderExpired:
        return Colors.red;
      case NotificationType.orderFinished:
        return Colors.green.shade700;
    } // 'default' case already covered, no need to add it
  }

  String _formatTime(DateTime dateTime) 
  {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {return 'Baru saja';} 
    else if (difference.inMinutes < 60) {return '${difference.inMinutes} menit yang lalu';} 
    else if (difference.inHours < 24) {return '${difference.inHours} jam yang lalu';} 
    else if (difference.inDays < 7) {return '${difference.inDays} hari yang lalu';} 
    else {return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);}
  }

  void _handleNotificationTap(WidgetRef ref, NotificationModel notification) 
  {
    // Mark as read
    if (!notification.isRead) 
    {
      final repository = ref.read(notificationRepositoryProvider);
      repository.markAsRead(notification.id);
    }

    // TODO: Navigate to related page based on notification data
    // For example, navigate to pager detail page
  }

  void _markAllAsRead(BuildContext context, WidgetRef ref, String userId) async 
  {
    try 
    {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(userId);

      if (context.mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Semua notifikasi ditandai dibaca',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } 
    catch (e) 
    {
      if (context.mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menandai notifikasi: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}