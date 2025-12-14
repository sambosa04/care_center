import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReservationsPage extends StatelessWidget {
  const AdminReservationsPage({super.key});

  // Helper: send overdue notifications once
  Future<void> _checkOverdueAndNotify(
      List<QueryDocumentSnapshot> docs) async {
    final now = DateTime.now();

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final String status = data["status"] ?? "";
      final Timestamp? endTs = data["endDate"];
      final bool alreadyNotified = data["overdueNotified"] == true;

      if (endTs == null) continue;

      final DateTime endDate = endTs.toDate();

      // Consider overdue only if approved or checked out
      final bool isActive =
          status == "approved" || status == "checked_out";

      if (!alreadyNotified && isActive && endDate.isBefore(now)) {
        // Create notification
        await FirebaseFirestore.instance
            .collection("notifications")
            .add({
          "type": "overdue",
          "title": "Overdue Rental",
          "message":
              "Reservation for ${data["equipmentName"]} is overdue.",
          "reservationId": doc.id,
          "renterId": data["renterId"],
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


        // Mark this reservation as already notified
        await doc.reference.update({"overdueNotified": true});
      }
    }
  }

  Future<void> updateStatus(String reservationId, String newStatus) async {
  final reservationRef =
      FirebaseFirestore.instance.collection("reservations").doc(reservationId);

  final reservationSnap = await reservationRef.get();
  final data = reservationSnap.data() as Map<String, dynamic>;

  final equipmentId = data["equipmentId"];
  final renterId = data["renterId"];
  final equipmentName = data["equipmentName"];

  final equipmentRef =
      FirebaseFirestore.instance.collection("equipment").doc(equipmentId);

  final equipmentSnap = await equipmentRef.get();
  final equipment = equipmentSnap.data() as Map<String, dynamic>;
  final currentQty = equipment["quantity"] ?? 0;

  // Update reservation status ONCE
  await reservationRef.update({"status": newStatus});

  // -------------------------
  // RENTER NOTIFICATIONS
  // -------------------------
  if (newStatus == "approved") {
    await _createRenterNotification(
      renterId: renterId,
      reservationId: reservationId,
      title: "Reservation Approved",
      message: "Your reservation for $equipmentName has been approved.",
      type: "status",
    );
  }

  if (newStatus == "rejected") {
    await _createRenterNotification(
      renterId: renterId,
      reservationId: reservationId,
      title: "Reservation Rejected",
      message: "Your reservation for $equipmentName was rejected.",
      type: "status",
    );
  }

  if (newStatus == "returned") {
    await _createRenterNotification(
      renterId: renterId,
      reservationId: reservationId,
      title: "Equipment Returned",
      message: "Thank you for returning $equipmentName.",
      type: "status",
    );
  }

  // -------------------------
  // EQUIPMENT LOGIC
  // -------------------------
  if (newStatus == "approved" && currentQty > 0) {
    await equipmentRef.update({
      "quantity": currentQty - 1,
      "status": (currentQty - 1 == 0) ? "unavailable" : "available",
      "rentalCount": (equipment["rentalCount"] ?? 0) + 1,
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(renterId)
        .update({
      "rentalCount": FieldValue.increment(1),
      "hasUnreadNotifications": true,
    });
  }

  if (newStatus == "returned") {
    await equipmentRef.update({
      "quantity": currentQty + 1,
      "status": "available",
    });
  }

  if (newStatus == "maintenance") {
    await equipmentRef.update({
      "status": "maintenance",
      "quantity": currentQty - 1,
    });
  }

  if (newStatus == "checked_out") {
    await equipmentRef.update({"status": "rented"});
  }
}

   
   Future<void> _createRenterNotification({
  required String renterId,
  required String reservationId,
  required String title,
  required String message,
  required String type,
}) async {
  await FirebaseFirestore.instance
      .collection("renter_notifications")
      .add({
    "renterId": renterId,
    "reservationId": reservationId,
    "title": title,
    "message": message,
    "type": type,
    "createdAt": DateTime.now(),
    "read": false,
  });

  await FirebaseFirestore.instance
      .collection("users")
      .doc(renterId)
      .update({"hasUnreadNotifications": true});
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Reservations"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No reservations yet"));
          }

          // Check for overdue reservations and notify admins
          _checkOverdueAndNotify(docs);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final reservation = docs[index];
              final data = reservation.data() as Map<String, dynamic>;

              final status = data["status"] ?? "Unknown";
              final start = data["startDate"]?.toDate();
              final end = data["endDate"]?.toDate();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  title: Text(
                    data["equipmentName"] ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Renter: ${data["renterName"]}\n"
                    "From: ${start != null ? start.toString().substring(0, 10) : "N/A"}\n"
                    "To: ${end != null ? end.toString().substring(0, 10) : "N/A"}\n"
                    "Status: $status",
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "approved",
                        child: Text("Approve"),
                      ),
                      PopupMenuItem(
                        value: "checked_out",
                        child: Text("Mark Checked Out"),
                      ),
                      PopupMenuItem(
                        value: "returned",
                        child: Text("Mark Returned"),
                      ),
                      PopupMenuItem(
                        value: "maintenance",
                        child: Text("Set as Maintenance"),
                      ),
                      PopupMenuItem(
                        value: "rejected",
                        child: Text("Reject"),
                      ),
                    ],
                    onSelected: (value) {
                      updateStatus(reservation.id, value);
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
