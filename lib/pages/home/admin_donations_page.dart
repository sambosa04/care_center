import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDonationsPage extends StatelessWidget {
  const AdminDonationsPage({super.key});

  // Equipment TYPE options (categories)
  static const List<String> equipmentTypes = [
    "Heavy Equipment",
    "Light Equipment",
    "Medical",
    "Mobility",
    "Electronic",
    "Other",
  ];

 
  // APPROVE DONATION DIALOG
  Future<void> _approveDonation(
    BuildContext context,
    String donationId,
    Map<String, dynamic> data,
  ) async {
    final TextEditingController priceCtrl = TextEditingController();
    final TextEditingController locationCtrl =
        TextEditingController(text: "Donation Center");
    final TextEditingController tagsCtrl = TextEditingController();

    String selectedType = "Light Equipment";

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Approve Donation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show origin
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Origin: Donated",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 10),

                // Type dropdown
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: "Equipment Type"),
                  value: selectedType,
                  items: equipmentTypes.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    );
                  }).toList(),
                  onChanged: (value) => selectedType = value!,
                ),

                const SizedBox(height: 10),

                // Price field
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Rental Price (BD)"),
                ),

                const SizedBox(height: 10),

                // Location
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: "Location"),
                ),

                const SizedBox(height: 10),

                // Tags
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Tags (comma separated)",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Confirm"),
              onPressed: () async {
                if (priceCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter rental price")),
                  );
                  return;
                }

                Navigator.pop(ctx);

                // Convert tags
                final List<String> tags = tagsCtrl.text.isEmpty
                    ? []
                    : tagsCtrl.text.split(",").map((e) => e.trim()).toList();

                // Add to equipment collection
                await FirebaseFirestore.instance.collection("equipment").add({
                  "name": data["itemName"],
                  "type": selectedType,
                  "origin": "Donated",
                  "quantity": data["quantity"], // from guest
                  "description": data["description"],
                  "condition": data["condition"],
                  "status": "available",
                  "imageUrl": data["imageUrl"],
                  "location": locationCtrl.text,
                  "tags": tags,
                  "rentalPrice": double.tryParse(priceCtrl.text) ?? 0,
                  "rentalCount": 0,
                  "createdAt": DateTime.now(),
                });

                // Update donation status
                await FirebaseFirestore.instance
                    .collection("donations")
                    .doc(donationId)
                    .update({"status": "approved"});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Donation approved and added to inventory"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Reject donation
  Future<void> _rejectDonation(String donationId) async {
    await FirebaseFirestore.instance
        .collection("donations")
        .doc(donationId)
        .update({"status": "rejected"});
  }

  // MAIN PAGE UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Donations"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("donations")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No donation requests", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final donation = docs[index];
              final data = donation.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data["imageUrl"]),
                    radius: 28,
                  ),

                  title: Text(
                    data["itemName"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    "Condition: ${data["condition"]}\n"
                    "Quantity: ${data["quantity"]}\n"
                    "Status: ${data["status"]}\n"
                    "${data["description"]}",
                  ),

                  trailing: PopupMenuButton<String>(
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "approve",
                        child: Text("Approve"),
                      ),
                      PopupMenuItem(
                        value: "reject",
                        child: Text("Reject"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "approve") {
                        _approveDonation(context, donation.id, data);
                      } else {
                        _rejectDonation(donation.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
