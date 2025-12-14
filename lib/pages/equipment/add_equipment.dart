import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({super.key});

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController quantityCtrl = TextEditingController(text: "1");
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController tagsCtrl = TextEditingController();
  final TextEditingController imageUrlCtrl = TextEditingController();

  // Type options
  final List<String> typeOptions = [
    "Heavy Equipment",
    "Light Equipment",
    "Medical",
    "Mobility",
    "Electronic",
    "Other",
  ];

  // Origin options
  final List<String> originOptions = [
    "Owned by Center",
    "Donated",
  ];

  // Condition options
  final List<String> conditionOptions = [
    "New",
    "Like New",
    "Good Condition",
    "Used",
    "Needs Maintenance",
  ];

  String selectedType = "Light Equipment";
  String selectedOrigin = "Owned by Center";
  String selectedCondition = "New";

  bool loading = false;

  Future<void> saveEquipment() async {
    if (nameCtrl.text.isEmpty ||
        quantityCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        imageUrlCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);

    final List<String> tags = tagsCtrl.text.isEmpty
        ? []
        : tagsCtrl.text.split(",").map((e) => e.trim()).toList();

    await FirebaseFirestore.instance.collection("equipment").add({
      "name": nameCtrl.text.trim(),
      "type": selectedType,
      "origin": selectedOrigin,
      "condition": selectedCondition,
      "quantity": int.tryParse(quantityCtrl.text) ?? 1,
      "description": descriptionCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "tags": tags,
      "imageUrl": imageUrlCtrl.text.trim(),
      "rentalPrice": double.tryParse(priceCtrl.text) ?? 0,
      "status": "available",
      "rentalCount": 0,           
      "createdAt": DateTime.now(),
    });

    setState(() => loading = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Equipment added successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Equipment"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: "Type"),
              items: typeOptions.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (v) => setState(() => selectedType = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedOrigin,
              decoration: const InputDecoration(labelText: "Origin"),
              items: originOptions.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (v) => setState(() => selectedOrigin = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCondition,
              decoration: const InputDecoration(labelText: "Condition"),
              items: conditionOptions.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) => setState(() => selectedCondition = v!),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Rental Price (BD)"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(labelText: "Location"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: tagsCtrl,
              decoration: const InputDecoration(labelText: "Tags (comma separated)"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: imageUrlCtrl,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : saveEquipment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Add Equipment",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
