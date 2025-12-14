import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservePage extends StatefulWidget {
  final String equipmentId;
  final String equipmentName;

  const ReservePage({
    super.key,
    required this.equipmentId,
    required this.equipmentName,
  });

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  DateTime? startDate;
  DateTime? endDate;
  int? recommendedDays;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestedDates();
  }

  // SMART AUTO-DURATION SYSTEM
  Future<void> _loadSuggestedDates() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user data safely
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      // rentalCount ALWAYS integer
      final int rentalCount = int.tryParse("${userData["rentalCount"] ?? 0}") ?? 0;

      // trusted user flag
      final bool trusted = (userData["trusted"] ?? false) == true;

      // Get equipment type
      final equipDoc = await FirebaseFirestore.instance
          .collection("equipment")
          .doc(widget.equipmentId)
          .get();

      final equipData = equipDoc.data() ?? {};
      final String eqType = (equipData["type"] ?? "").toString().toLowerCase();

 
      // IMPROVED HEAVY EQUIPMENT DETECTION
      final bool isHeavy = eqType.contains("heavy") ||
          eqType.contains("medical") ||
          eqType.contains("mobility");


      // AUTO-DURATION LOGIC
      int baseDays = 3; // default

      if (trusted) baseDays += 2;
      if (isHeavy) baseDays += 2;

      if (rentalCount >= 5) baseDays += 1;
      if (rentalCount >= 15) baseDays += 1;


      final now = DateTime.now();

      setState(() {
        startDate = now;
        endDate = now.add(Duration(days: baseDays));
        recommendedDays = baseDays;
      });
    } catch (e) {
      // fallback safe defaults
      final now = DateTime.now();
      setState(() {
        startDate = now;
        endDate = now.add(const Duration(days: 3));
        recommendedDays = 3;
      });
    }
  }


  // PICKERS
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => startDate = picked);

      if (endDate != null && endDate!.isBefore(picked)) {
        endDate = picked.add(const Duration(days: 1));
      }
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => endDate = picked);
  }


  // SUBMIT RESERVATION
  Future<void> submitReservation() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select start and end dates")),
      );
      return;
    }

    setState(() => loading = true);

    // Check quantity
    final equipSnap = await FirebaseFirestore.instance
        .collection("equipment")
        .doc(widget.equipmentId)
        .get();

    final equipData = equipSnap.data() ?? {};
    int quantity = equipData["quantity"] ?? 0;

    if (quantity <= 0) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Equipment unavailable right now.")),
      );
      return;
    }

    // User data
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final String renterName = userDoc.data()?["name"] ?? "Unknown User";

    // Create reservation
    final reservationRef = await FirebaseFirestore.instance
        .collection("reservations")
        .add({
      "equipmentId": widget.equipmentId,
      "equipmentName": widget.equipmentName,
      "renterId": user.uid,
      "renterName": renterName,
      "startDate": startDate,
      "endDate": endDate,
      "status": "pending",
      "createdAt": DateTime.now(),
      "overdueNotified": false,
    });

    // Notify admin
    await FirebaseFirestore.instance.collection("notifications").add({
      "type": "reservation",
      "title": "New Reservation Request",
      "message": "$renterName requested ${widget.equipmentName}",
      "reservationId": reservationRef.id,
      "createdAt": DateTime.now(),
      "read": false,
    });

    // mark admins as having unread notifications
    final admins = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "admin")
        .get();
    
    for (final admin in admins.docs) {
      await admin.reference.update({
        "hasUnreadAdminNotifications": true,
      });
    }


    Navigator.pop(context);
    setState(() => loading = false);
  }


  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reserve Equipment"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.equipmentName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            if (recommendedDays != null)
              Text(
                "Recommended duration: $recommendedDays days",
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),

            const SizedBox(height: 12),

            // Start date
            ListTile(
              title: Text(
                startDate == null
                    ? "Pick start date"
                    : "Start: ${startDate!.toString().substring(0, 10)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickStartDate,
            ),

            // Pick up now button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                onPressed: () {
                  setState(() => startDate = DateTime.now());
                },
                child: const Text("Pick Up Now", style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 10),

            // End date
            ListTile(
              title: Text(
                endDate == null
                    ? "Pick end date"
                    : "End: ${endDate!.toString().substring(0, 10)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickEndDate,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: loading ? null : submitReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Request", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
