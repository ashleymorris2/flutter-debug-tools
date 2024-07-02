import 'package:debug_tools/src/log_viewer.dart';
import 'package:debug_tools/src/notification_viewer.dart';
import 'package:flutter/material.dart';

class DebugMenuScreen extends StatelessWidget {
  final String? logFileName;

  const DebugMenuScreen({super.key, this.logFileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Debug Tools',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Scheduled Notification Viewer  ',
            ),
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationViewerScreen(),
                  ));
            },
          ),
          logFileName == null
              ? const SizedBox.shrink()
              : ListTile(
                  title: const Text(
                    'Log File Viewer ',
                  ),
                  onTap: () async {
                    if (logFileName != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogViewerScreen(
                              fileName: logFileName!,
                            ),
                          ));
                    }
                  },
                ),
        ],
      ),
    );
  }
}
