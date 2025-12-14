import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RenterRentalHistoryPage extends StatelessWidget {
  final String renterId;
  final String renterName;

  const RenterRentalHistoryPage({
    super.key,
    required this.renterId,
    required this.renterName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text("$renterName Rentals"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .where("renterId", isEqualTo: renterId)
            .snapshots(),                   
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data!.docs;

          if (reservations.isEmpty) {
            return Center(
              child: Text(
                "No rental records for this user.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          // MANUAL SORTING BY DATE (avoids Firestore index problems)
          reservations.sort((a, b) {
            final aDate = a["startDate"]?.toDate() ?? DateTime(2000);
            final bDate = b["startDate"]?.toDate() ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              final data = res.data() as Map<String, dynamic>;

              final start = data["startDate"] != null
                  ? data["startDate"].toDate().toString().substring(0, 10)
                  : "Unknown";

              final end = data["endDate"] != null
                  ? data["endDate"].toDate().toString().substring(0, 10)
                  : "Unknown";

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    data["equipmentName"] ?? "Unknown Equipment",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "From: $start\n"
                    "To: $end\n"
                    "Status: ${data["status"]}",
                  ),
                  trailing: const Icon(Icons.list_alt),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
