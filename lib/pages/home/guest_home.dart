import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:care_center/pages/renter/donation_page.dart';
import 'about_page.dart';
import 'guest_equipment_list.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  int index = 0;

  final pages = [
    const GuestEquipmentList(),
    DonationPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      title: const Text("Guest Home"),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            // For guest login, just go back to login page
            Navigator.pushReplacementNamed(context, "/");
          },
        ),
      ],
),

      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Donate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "About",
          ),
        ],
      ),
    );
  }
}
