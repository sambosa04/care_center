import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  // Stream to get all equipment
  Stream<QuerySnapshot> allEquipment() {
    return FirebaseFirestore.instance.collection("equipment").snapshots();
  }

  // Helper method to generate equipment report cards (sorted by rental count)
  Widget equipmentReportCard(String title, List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Text("No data available", style: TextStyle(color: Colors.grey));
    }

    // Sort by rental count in descending order
    docs.sort((a, b) {
      return ((b["rentalCount"] ?? 0) as int).compareTo((a["rentalCount"] ?? 0) as int);
    });

    // Take the top 3 items
    final top = docs.take(3).toList();

    return Column(
      children: top.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Card(
          color: Colors.teal.shade100,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              data["name"] ?? "Unknown",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Rented: ${data["rentalCount"] ?? 0} times\n"
              "Origin: ${data["origin"]}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Build the page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text("Reports & Statistics"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Most Rented Equipment Section
            const Text(
              "Most Frequently Rented Equipment",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: allEquipment(),
              builder: (context, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                final owned = snap.data!.docs
                    .where((d) => d["origin"] == "Owned by Center")
                    .toList();

                return equipmentReportCard("Most Rented", owned);
              },
            ),
            const SizedBox(height: 30),

            // Most Donated Equipment Section
            const Text(
              "Most Frequently Donated Equipment",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: allEquipment(),
              builder: (context, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                final donated = snap.data!.docs
                    .where((d) => d["origin"] == "Donated")
                    .toList();

                return equipmentReportCard("Most Donated", donated);
              },
            ),
            const SizedBox(height: 30),

            // Reservation Statistics Section
            const Text(
              "Reservation Statistics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("reservations")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                final docs = snap.data!.docs;
                final total = docs.length;
                final pending = docs.where((d) => d["status"] == "pending").length;
                final approved = docs.where((d) => d["status"] == "approved").length;
                final rejected = docs.where((d) => d["status"] == "rejected").length;
                final returned = docs.where((d) => d["status"] == "returned").length;
                final now = DateTime.now();
                final overdue = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final end = (data["endDate"] as Timestamp).toDate();
                  return end.isBefore(now) && data["status"] != "returned";
                }).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    numberCard("Total Reservations", total),
                    numberCard("Pending Reservations", pending),
                    numberCard("Approved Reservations", approved),
                    numberCard("Rejected Reservations", rejected),
                    numberCard("Returned / Completed", returned),
                    numberCard("Overdue Rentals", overdue),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),

            // Donation Statistics Section
            const Text(
              "Donation Statistics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("donations")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                final docs = snap.data!.docs;
                final total = docs.length;
                final pending = docs.where((d) => d["status"] == "pending").length;
                final approved = docs.where((d) => d["status"] == "approved").length;
                final rejected = docs.where((d) => d["status"] == "rejected").length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    numberCard("Total Donations", total),
                    numberCard("Pending Donations", pending),
                    numberCard("Approved Donations", approved),
                    numberCard("Rejected Donations", rejected),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),

            // Maintenance Statistics Section
            const Text(
              "Maintenance Records",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("equipment")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                final maintenance = snap.data!.docs
                    .where((d) => d["status"] == "maintenance")
                    .length;

                return numberCard("Items in Maintenance", maintenance);
              },
            ),
            const SizedBox(height: 30),

            // Total Equipment Statistics
            const Text(
              "Equipment Summary",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("equipment")
                  .snapshots(),
              builder: (context, snap) {
                return numberCard(
                  "Total Equipment",
                  snap.data?.docs.length ?? 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to display number statistics cards
  Widget numberCard(String title, int number) {
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "$title: $number",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
