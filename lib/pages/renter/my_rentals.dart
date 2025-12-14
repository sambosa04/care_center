import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRentalsPage extends StatelessWidget {
  const MyRentalsPage({super.key});


  // CANCEL REQUEST
  Future<void> cancelReservation(BuildContext context, String reservationId) async {
    await FirebaseFirestore.instance
        .collection("reservations")
        .doc(reservationId)
        .update({"status": "canceled"});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reservation request canceled")),
    );
  }

 
  // EDIT DATES
  Future<void> editDates(
      BuildContext context,
      String reservationId,
      Timestamp start,
      Timestamp end) async {
    DateTime startDate = start.toDate();
    DateTime endDate = end.toDate();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text("Edit Rental Dates"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Start: ${startDate.toString().substring(0, 10)}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => startDate = picked);
                    },
                  ),
                  ListTile(
                    title: Text("End: ${endDate.toString().substring(0, 10)}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("reservations")
                        .doc(reservationId)
                        .update({
                      "startDate": startDate,
                      "endDate": endDate,
                    });

                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Dates updated successfully")),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // MAIN UI
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Rentals"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .where("renterId", isEqualTo: user.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No rentals yet"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No rentals yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final reservation = docs[i];
              final data = reservation.data() as Map<String, dynamic>;

              final status = data["status"];
              final start = data["startDate"];
              final end = data["endDate"];


              // CARD COLORS BASED ON STATUS
              Color cardColor;

              switch (status) {
                case "approved":
                  cardColor = Colors.green.shade100;
                  break;
                case "rejected":
                  cardColor = Colors.red.shade100;
                  break;
                case "canceled":
                  cardColor = Colors.grey.shade300;
                  break;
                case "returned":
                  cardColor = Colors.blue.shade100;
                  break;
                case "checked_out":
                  cardColor = Colors.orange.shade100;
                  break;
                default:
                  cardColor = Colors.white;
              }

              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["equipmentName"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "From: ${start.toDate().toString().substring(0, 10)}\n"
                        "To:   ${end.toDate().toString().substring(0, 10)}\n"
                        "Status: $status",
                      ),

                      const SizedBox(height: 10),

                      // BUTTONS ONLY IF PENDING
                      if (status == "pending")
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                editDates(context, reservation.id, start, end);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text("Edit Dates"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                cancelReservation(context, reservation.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Cancel Request"),
                            ),
                          ],
                        ),
                    ],
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
