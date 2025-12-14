import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool cleared = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Clear unread flag ONCE
    if (!cleared) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"hasUnreadNotifications": false});
      cleared = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("renter_notifications")
            .where("renterId", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              final data = snap.data!.docs[i].data() as Map<String, dynamic>;

              Color color;
              IconData icon;

              switch (data["type"]) {
                case "overdue":
                  color = Colors.red;
                  icon = Icons.warning;
                  break;
                case "reminder":
                  color = Colors.orange;
                  icon = Icons.schedule;
                  break;
                default:
                  color = Colors.blue;
                  icon = Icons.notifications;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(icon, color: color, size: 30),
                  title: Text(
                    data["title"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data["message"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
