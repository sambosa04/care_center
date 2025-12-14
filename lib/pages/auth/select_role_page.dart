import 'package:flutter/material.dart';
import '../home/admin_home.dart';
import '../home/renter_home.dart';
import '../home/guest_home.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});

  Widget buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
    Color color = Colors.teal,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Care Center"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            const Text(
              "Choose how you want to continue",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            // Admin card
            buildRoleCard(
              context: context,
              icon: Icons.admin_panel_settings,
              title: "Admin",
              subtitle: "Manage inventory, reservations and donations",
              page: const AdminHomePage(),
              color: Colors.redAccent,
            ),

            // Renter card
            buildRoleCard(
              context: context,
              icon: Icons.person,
              title: "Renter",
              subtitle: "Browse equipment and make reservations",
              page: const RenterHomePage(),
              color: Colors.blueAccent,
            ),

            // Guest card
            buildRoleCard(
              context: context,
              icon: Icons.people_alt,
              title: "Guest",
              subtitle: "Explore and make donations",
              page: const GuestHomePage(),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
