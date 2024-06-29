import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotificationViewer extends StatelessWidget {
  NotificationViewer({super.key});

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Viewer'),
      ),
      body: Scrollbar(
        thickness: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<PendingNotificationRequest>>(
              future: plugin.pendingNotificationRequests(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sortedNotifications =
                      _sortNotificationsByDate(snapshot.data!);

                  return ListView.builder(
                      itemCount: sortedNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = sortedNotifications[index];
                        DateTime? scheduleTime = notification.payload != null
                            ? DateTime.tryParse(notification.payload!)
                            : null;
                        String formattedDate = scheduleTime != null
                            ? DateFormat('[EEEE - dd/MM/yyyy - HH:mm]')
                                .format(scheduleTime)
                            : '';

                        return ListTile(
                          title: Text(
                            notification.title ?? 'No Title',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formattedDate,
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                                const SizedBox(height: 8),
                                Text(
                                  "${notification.body}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          leading: const Icon(Icons.notifications),
                        );
                      });
                }
                return const Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }

// Method to sort notifications by date
  List<PendingNotificationRequest> _sortNotificationsByDate(
      List<PendingNotificationRequest> notifications) {
    notifications.sort((a, b) {
      DateTime? dateA =
          a.payload != null ? DateTime.tryParse(a.payload!) : null;
      DateTime? dateB =
          b.payload != null ? DateTime.tryParse(b.payload!) : null;
      // Ensure non-null dates come first and compare them
      if (dateA != null && dateB != null) {
        return dateA.compareTo(dateB);
      }
      return dateA != null ? -1 : 1;
    });
    return notifications;
  }
}
