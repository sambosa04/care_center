import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .update({"read": true});
  }


  

  @override
  Widget build(BuildContext context) {

      final uid = FirebaseAuth.instance.currentUser!.uid;

FirebaseFirestore.instance
    .collection("users")
    .doc(uid)
    .update({"hasUnreadAdminNotifications": false});

    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No notifications"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final notif = docs[i];
              final data = notif.data() as Map<String, dynamic>;
              final bool unread = data["read"] == false;

              return Card(
                color: unread ? Colors.yellow.shade100 : Colors.white,
                child: ListTile(
                  title: Text(data["title"] ?? ""),
                  subtitle: Text(data["message"] ?? ""),
                  trailing: unread
                      ? Icon(Icons.circle, color: Colors.red, size: 12)
                      : const SizedBox(),
                  onTap: () {
                    markAsRead(notif.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
