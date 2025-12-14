import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';

class RenterProfilePage extends StatelessWidget {
  const RenterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Edit Profile Button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(uid: uid),
                ),
              );
            },
          ),

          // LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>? ?? {};

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),

                const SizedBox(height: 20),

                infoItem("Name", data["name"] ?? "Unknown"),
                infoItem("Email", data["email"] ?? "Unknown"),
                infoItem("Phone", data["phone"] ?? "Not provided"),
                infoItem("Preferred Contact", data["preferredContact"] ?? "email"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
