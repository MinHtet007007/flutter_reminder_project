import 'package:flutter/material.dart';
import 'package:flutter_alarm_project/database/db_helper.dart';
import 'package:flutter_alarm_project/screens/add_edit_reminder.dart';
import 'package:flutter_alarm_project/screens/reminder_detail_screen.dart';
import 'package:flutter_alarm_project/services/notification_helper.dart';
import 'package:flutter_alarm_project/services/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNotificationPermissions();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await DbHelper.getReminders();
    setState(() {
      _reminders = reminders;
    });
    debugPrint(reminders.toString());
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = _reminders.firstWhere((rem) => rem['id'] == id);
      NotificationHelper.scheduleNotification(id, reminder['title'],
          reminder['category'], DateTime.parse(reminder['remindersTime']));
    } else {
      NotificationHelper.cancelNotification(id);
    }
    _loadReminders();
  }

  Future<void> _deleteReminder(int id) async {
    await DbHelper.deleteReminder(id);
    NotificationHelper.cancelNotification(id);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Reminders",
            style: TextStyle(color: Colors.teal),
          ),
          iconTheme: const IconThemeData(color: Colors.teal),
        ),
        body: _reminders.isEmpty
            ? const Center(
                child: Text(
                  "No Reminders Found",
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              )
            : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder["id"].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) async {
                      _deleteReminder(reminder['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reminder Deleted")));
                    },
                    child: Card(
                      color: Colors.teal.shade50,
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReminderDetailScreen(
                                reminderId: reminder['id'],
                              ),
                            ),
                          )
                        },
                        leading: Icon(
                          Icons.notifications,
                          color: Colors.teal,
                        ),
                        title: Text(
                          reminder["title"],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                        subtitle: Text("Category: ${reminder['category']}"),
                        trailing: Switch(
                            value: reminder['isActive'] == 1,
                            activeColor: Colors.teal,
                            inactiveTrackColor: Colors.white,
                            inactiveThumbColor: Colors.black54,
                            onChanged: (value) {
                              _toggleReminder(reminder['id'], value);
                            }),
                      ),
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditReminderScreen(),
              ),
            );
          },
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

//show confirmation dialog before deleting a reminder
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext content) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Delete Reminder"),
            content:
                const Text("Are you sure you want to delete this reminder?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          );
        });
  }
}
