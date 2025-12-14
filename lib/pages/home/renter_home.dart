import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../renter/renter_equipment_list.dart';
import '../renter/my_rentals.dart';
import '../renter/notifications_page.dart';
import '../renter/profile_page.dart';
import '../renter/donation_page.dart';

class RenterHomePage extends StatefulWidget {
  const RenterHomePage({super.key});

  @override
  State<RenterHomePage> createState() => _RenterHomePageState();
}

class _RenterHomePageState extends State<RenterHomePage> {
  int index = 0;

  final pages = const [
    RenterEquipmentList(),
    MyRentalsPage(),
    NotificationsPage(),
    DonationPage(),
    RenterProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Browse",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "My Rentals",
          ),

          // 🔴 NOTIFICATION WITH RED DOT
          BottomNavigationBarItem(
            label: "Notifications",
            icon: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                bool showDot = false;

                if (snap.hasData && snap.data!.exists) {
                  final data = snap.data!.data() as Map<String, dynamic>;
                  showDot = data["hasUnreadNotifications"] == true;
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
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Donate",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
