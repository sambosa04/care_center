import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEquipmentPage extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const EditEquipmentPage({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<EditEquipmentPage> createState() => _EditEquipmentPageState();
}

class _EditEquipmentPageState extends State<EditEquipmentPage> {
  late TextEditingController nameCtrl;
  late TextEditingController quantityCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController tagsCtrl;
  late TextEditingController imageUrlCtrl;

  final List<String> typeOptions = [
    "Heavy Equipment",
    "Light Equipment",
    "Medical",
    "Mobility",
    "Electronic",
    "Other",
  ];

  final List<String> originOptions = [
    "Owned by Center",
    "Donated",
  ];

  final List<String> conditionOptions = [
    "New",
    "Like New",
    "Good Condition",
    "Used",
    "Needs Maintenance",
  ];

  String selectedType = "Light Equipment";
  String selectedOrigin = "Owned by Center";
  String selectedCondition = "Good Condition";

  bool loading = false;

 @override
void initState() {
  super.initState();

  final existingCondition = widget.data["condition"] ?? "Good Condition";

 
  if (!conditionOptions.contains(existingCondition)) {
    selectedCondition = "Good Condition";
  } else {
    selectedCondition = existingCondition;
  }

  selectedType = widget.data["type"] ?? "Light Equipment";
  selectedOrigin = widget.data["origin"] ?? "Owned by Center";

  nameCtrl = TextEditingController(text: widget.data["name"]);
  quantityCtrl = TextEditingController(text: widget.data["quantity"]?.toString() ?? "1");
  priceCtrl = TextEditingController(
      text: widget.data["rentalPrice"]?.toString() ?? "0");
  descriptionCtrl = TextEditingController(text: widget.data["description"]);
  locationCtrl = TextEditingController(text: widget.data["location"]);
  tagsCtrl = TextEditingController(
    text: (widget.data["tags"] as List<dynamic>?)
            ?.map((e) => e.toString())
            .join(", ") ??
        "",
  );
  imageUrlCtrl = TextEditingController(text: widget.data["imageUrl"]);
}


  Future<void> saveChanges() async {
    if (nameCtrl.text.isEmpty ||
        quantityCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        imageUrlCtrl.text.isEmpty ||
        selectedCondition.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);

    final List<String> tags = tagsCtrl.text.isEmpty
        ? []
        : tagsCtrl.text.split(",").map((e) => e.trim()).toList();

    await FirebaseFirestore.instance
        .collection("equipment")
        .doc(widget.id)
        .update({
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
      "updatedAt": DateTime.now(),
    });

    setState(() => loading = false);

    Navigator.pop(context, true);   // return TRUE so previous page knows to refresh

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Equipment updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Equipment"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: "Type"),
              items: typeOptions.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedType = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedOrigin,
              decoration: const InputDecoration(labelText: "Origin"),
              items: originOptions.map((o) {
                return DropdownMenuItem(
                  value: o,
                  child: Text(o),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedOrigin = v!),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCondition,
              decoration: const InputDecoration(labelText: "Condition"),
              items: conditionOptions.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
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
              decoration: const InputDecoration(
                labelText: "Tags (comma separated)",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: imageUrlCtrl,
              decoration: const InputDecoration(
                labelText: "Image URL",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
