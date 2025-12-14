import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_equipment.dart';
import '../renter/reserve_page.dart';

class EquipmentDetailsPage extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const EquipmentDetailsPage({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<EquipmentDetailsPage> createState() => _EquipmentDetailsPageState();
}

class _EquipmentDetailsPageState extends State<EquipmentDetailsPage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => userRole = "guest");
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!snap.exists) {
      setState(() => userRole = "guest");
      return;
    }

    setState(() => userRole = snap["role"]);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Equipment Details"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,

        // Only admin sees edit/delete
        actions: [
          if (userRole == "admin") ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEquipmentPage(
                      id: widget.id,
                      data: widget.data,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("equipment")
                    .doc(widget.id)
                    .delete();

                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  data["imageUrl"],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              data["name"],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              data["description"],
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              "Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Equipment Details
            detailItem("Type", data["type"]),
            detailItem("Origin", data["origin"] ?? "N/A"),  
            detailItem("Quantity", data["quantity"].toString()),
            detailItem("Condition", data["condition"]),
            detailItem("Status", data["status"]),
            detailItem("Location", data["location"]),
            detailItem("Rental Price / Day", "${data["rentalPrice"]} BD"),

            const SizedBox(height: 15),

            const Text(
              "Tags",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                if (data["tags"] is List)
                  for (var t in data["tags"])
                    Chip(
                      label: Text(t.toString()),
                      backgroundColor: Colors.teal.shade100,
                    ),
              ],
            ),

            const SizedBox(height: 30),

            // ONLY renter can reserve
            if (userRole == "renter")
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 40,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservePage(
                          equipmentId: widget.id,
                          equipmentName: data["name"],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Reserve",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

            // Guest sees nothing here
            if (userRole == "guest")
              const Center(
                child: Text(
                  "Login as renter to reserve equipment",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
