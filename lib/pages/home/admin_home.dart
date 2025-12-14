import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:care_center/pages/equipment/equipment_list.dart';
import 'admin_reservations_page.dart';
import 'admin_donations_page.dart';
import 'admin_reports_page.dart';
import 'AdminDashboardPage.dart';
import 'admin_notification_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int index = 0;

  final List<Widget> pages = [
    AdminDashboardPage(),
    EquipmentListPage(),
    AdminReservationsPage(),
    AdminDonationsPage(),
    AdminReportsPage(),
    AdminNotificationsPage(),   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text("Admin Panel",
                      style: TextStyle(
                          fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                setState(() => index = 0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Equipment"),
              onTap: () {
                setState(() => index = 1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("Reservations"),
              onTap: () {
                setState(() => index = 2);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text("Donations"),
              onTap: () {
                setState(() => index = 3);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Reports"),
              onTap: () {
                setState(() => index = 4);
                Navigator.pop(context);
              },
            ),
ListTile(
  leading: StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (context, snap) {
      bool showDot = false;

      if (snap.hasData && snap.data!.exists) {
        final data = snap.data!.data() as Map<String, dynamic>;
        showDot = data["hasUnreadAdminNotifications"] == true;
      }

      return Stack(
        children: [
          const Icon(Icons.notifications),
          if (showDot)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    },
  ),
  title: const Text("Notifications"),
  onTap: () {
    setState(() => index = 5);
    Navigator.pop(context);
  },
),



            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);    
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),

      body: pages[index],
    );
  }
}
