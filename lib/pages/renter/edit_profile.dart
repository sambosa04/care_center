import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  String contact = "email";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get();

    final data = doc.data() ?? {};

    name.text = data["name"] ?? "";
    phone.text = data["phone"] ?? "";
    contact = data["preferredContact"] ?? "email";

    setState(() {});
  }

  Future<void> save() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .update({
      "name": name.text.trim(),
      "phone": phone.text.trim(),
      "preferredContact": contact,
    });

    Navigator.pop(context);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phone,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: contact,
              decoration: const InputDecoration(
                labelText: "Preferred Contact",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "email", child: Text("Email")),
                DropdownMenuItem(value: "phone", child: Text("Phone")),
              ],
              onChanged: (v) => setState(() => contact = v!),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 40),
              ),
              onPressed: loading ? null : save,
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
