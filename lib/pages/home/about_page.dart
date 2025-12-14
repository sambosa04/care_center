import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("About Care Center"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Care Equipment Center",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Our mission is to support community members by providing access to essential medical and mobility equipment. "
              "We aim to make healthcare more accessible by offering equipment rentals and accepting donations from generous individuals.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            Row(
              children: const [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Our Mission",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "To help individuals in need by ensuring medical equipment is available, affordable, and accessible.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            Row(
              children: const [
                Icon(Icons.handshake, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Our Services",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text("• Renting medical and mobility equipment."),
            const Text("• Accepting donations of equipment in good condition."),
            const Text("• Helping community members access essential resources."),

            const SizedBox(height: 25),

            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Manama, Bahrain", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 25),

            Row(
              children: const [
                Icon(Icons.phone, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Contact Us",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Phone: +973 1234 5678"),
            const Text("Email: support@carecenter.com"),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Thank you for supporting our mission!",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
