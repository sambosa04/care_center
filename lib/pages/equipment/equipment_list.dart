import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_equipment.dart';
import 'equipment_details.dart';

class EquipmentListPage extends StatefulWidget {
  const EquipmentListPage({super.key});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  String searchQuery = "";
  String typeFilter = "all";
  String availabilityFilter = "all";

  // Equipment type list
  static const equipmentTypes = [
    "all",
    "Heavy Equipment",
    "Light Equipment",
    "Medical",
    "Mobility",
    "Electronic",
    "Other",
  ];

  // Availability filter (quantity based)
  static const availabilityTypes = [
    "all",
    "available",
    "not available",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEquipmentPage()),
          );
        },
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search equipment...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // FILTER ROW
          Row(
            children: [
              // TYPE FILTER
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField(
                    value: typeFilter,
                    decoration: const InputDecoration(
                      labelText: "Type",
                      border: OutlineInputBorder(),
                    ),
                    items: equipmentTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (v) => setState(() => typeFilter = v.toString()),
                  ),
                ),
              ),

              // AVAILABILITY FILTER
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField(
                    value: availabilityFilter,
                    decoration: const InputDecoration(
                      labelText: "Availability",
                      border: OutlineInputBorder(),
                    ),
                    items: availabilityTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => availabilityFilter = v.toString()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // EQUIPMENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("equipment")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snap.data!.docs;

                if (items.isEmpty) {
                  return const Center(child: Text("No equipment found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name =
                        (data["name"] ?? "").toString().toLowerCase();
                    final type =
                        (data["type"] ?? "").toString().toLowerCase();
                    final location =
                        (data["location"] ?? "").toString().toLowerCase();

                    final int qty = data["quantity"] is int
                        ? data["quantity"]
                        : int.tryParse("${data["quantity"]}") ?? 0;

                    final bool isAvailable = qty > 0;
                    final bool isNotAvailable = qty == 0;

                    // TAGS
                    final List<String> tags = [];
                    if (data["tags"] is List) {
                      for (var t in data["tags"]) {
                        tags.add(t.toString().toLowerCase());
                      }
                    }

                    // SEARCH FILTER
                    if (searchQuery.isNotEmpty) {
                      final match = name.contains(searchQuery) ||
                          type.contains(searchQuery) ||
                          location.contains(searchQuery) ||
                          tags.any((tag) => tag.contains(searchQuery));

                      if (!match) return const SizedBox.shrink();
                    }

                    // TYPE FILTER
                    if (typeFilter != "all" &&
                        typeFilter.toLowerCase() != type) {
                      return const SizedBox.shrink();
                    }

                    // AVAILABILITY FILTER (quantity based)
                    if (availabilityFilter == "available" && !isAvailable) {
                      return const SizedBox.shrink();
                    }

                    if (availabilityFilter == "not available" &&
                        !isNotAvailable) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data["imageUrl"]),
                          radius: 30,
                        ),
                        title: Text(
                          data["name"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Type: ${data["type"]}\n"
                          "Qty: ${data["quantity"]}\n"
                          "Price/Day: ${data["rentalPrice"]} BD",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EquipmentDetailsPage(
                                id: doc.id,
                                data: data,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
