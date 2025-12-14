import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:care_center/pages/home/guest_home.dart';
import 'package:care_center/pages/home/renter_home.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final itemName = TextEditingController();
  final description = TextEditingController();
  final imageUrl = TextEditingController();
  final quantity = TextEditingController(text: "1");
  String condition = "good";
  bool loading = false;

  Future<void> submitDonation() async {
    if (itemName.text.isEmpty ||
        description.text.isEmpty ||
        imageUrl.text.isEmpty ||
        quantity.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final donorId = user?.uid ?? "guest";


    // Save the donation request
    await FirebaseFirestore.instance.collection("donations").add({
      "donorId": donorId,
      "itemName": itemName.text.trim(),
      "description": description.text.trim(),
      "imageUrl": imageUrl.text.trim(),
      "condition": condition,
      "quantity": int.tryParse(quantity.text) ?? 1,
      "status": "pending",
      "createdAt": DateTime.now(),
    });

    // Create ADMIN notification
    await FirebaseFirestore.instance
        .collection("notifications")
        .add({
      "type": "donation",
      "title": "New Donation Submitted",
      "message":
          "A new donation request was submitted for ${itemName.text.trim()}",
      "donorId": donorId,
      "createdAt": DateTime.now(),
      "read": false,
    });
         
    final admins = await FirebaseFirestore.instance
   .collection("users")
   .where("role", isEqualTo: "admin")
   .get();
   
    for (final admin in admins.docs) {
      await admin.reference.update({
        "hasUnreadAdminNotifications": true,
      });
    }
    



    // Redirect according to role
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GuestHomePage()),
      );
    } else {
      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final role = snap.data()?["role"] ?? "guest";

      if (role == "renter") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RenterHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GuestHomePage()),
        );
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Equipment"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: itemName,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: condition,
              decoration: const InputDecoration(labelText: "Condition"),
              items: const [
                DropdownMenuItem(value: "new", child: Text("New")),
                DropdownMenuItem(value: "good", child: Text("Good")),
                DropdownMenuItem(value: "used", child: Text("Used")),
              ],
              onChanged: (value) {
                setState(() => condition = value.toString());
              },
            ),
            const SizedBox(height: 15),

            TextField(
              controller: quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: imageUrl,
              decoration: const InputDecoration(
                labelText: "Image URL",
                hintText: "https://example.com/item.jpg",
              ),
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: loading ? null : submitDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    vertical: 15, horizontal: 40),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit Donation",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
