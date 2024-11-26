import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_project/database/db_helper.dart';
import 'package:flutter_alarm_project/screens/add_edit_reminder.dart';
import 'package:intl/intl.dart';

class ReminderDetailScreen extends StatefulWidget {
  final int reminderId;
  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DbHelper.getReminderById(widget.reminderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            ),
          );
        }
        final reminder = snapshot.data!;
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.teal),
              backgroundColor: Colors.white,
              title: Text("Reminder Details"),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                      label: "Title",
                      icon: Icons.title,
                      content: reminder['title']),
                  SizedBox(
                    height: 20,
                  ),
                  _buildDetailCard(
                      label: "Description",
                      icon: Icons.description,
                      content: reminder['description']),
                  SizedBox(
                    height: 20,
                  ),
                  _buildDetailCard(
                      label: "Category",
                      icon: Icons.category,
                      content: reminder['category']),
                  SizedBox(
                    height: 20,
                  ),
                  _buildDetailCard(
                    label: "Reminder Time",
                    icon: Icons.access_time,
                    content: DateFormat('yyyy-MM-dd hh:mm a').format(
                      DateTime.parse(
                        reminder['remindersTime'],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditReminderScreen(
                      reminderId: widget.reminderId,
                    ),
                  ),
                );
              },
              child: Icon(Icons.edit),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ));
      },
    );
  }

  Widget _buildDetailCard(
      {required String label,
      required IconData icon,
      required String content}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
