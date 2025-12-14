import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../equipment/equipment_details.dart';

class GuestEquipmentList extends StatefulWidget {
  const GuestEquipmentList({super.key});

  @override
  State<GuestEquipmentList> createState() => _GuestEquipmentListState();
}

class _GuestEquipmentListState extends State<GuestEquipmentList> {
  String searchQuery = "";
  String originFilter = "all";
  String typeFilter = "all";
  String availabilityFilter = "all";

  static const equipmentTypes = [
    "all",
    "Heavy Equipment",
    "Light Equipment",
    "Medical",
    "Mobility",
    "Electronic",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

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
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // FILTER ROW 1 (Origin + Type)
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField(
                    value: originFilter,
                    decoration: const InputDecoration(
                      labelText: "Origin",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "Donated", child: Text("Donated")),
                      DropdownMenuItem(
                        value: "Owned by Center",
                        child: Text("Owned by Center"),
                      ),
                    ],
                    onChanged: (v) => setState(() => originFilter = v.toString()),
                  ),
                ),
              ),
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
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => typeFilter = v.toString()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AVAILABILITY FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField(
              value: availabilityFilter,
              decoration: const InputDecoration(
                labelText: "Availability",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "all", child: Text("All")),
                DropdownMenuItem(value: "available", child: Text("Available")),
                DropdownMenuItem(
                  value: "not_available",
                  child: Text("Not Available"),
                ),
              ],
              onChanged: (v) => setState(() => availabilityFilter = v.toString()),
            ),
          ),

          const SizedBox(height: 10),

          // LIST
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = (data["name"] ?? "").toString().toLowerCase();
                    final type = (data["type"] ?? "").toString().toLowerCase();
                    final location =
                        (data["location"] ?? "").toString().toLowerCase();
                    final origin = data["origin"] ?? "";

                    // tags
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

                    // ORIGIN FILTER
                    if (originFilter != "all" && originFilter != origin) {
                      return const SizedBox.shrink();
                    }

                    // TYPE FILTER
                    if (typeFilter != "all" && typeFilter != data["type"]) {
                      return const SizedBox.shrink();
                    }

                    // AVAILABILITY FILTER BASED ON QUANTITY
                    final int quantity =
                        (data["quantity"] is int) ? data["quantity"] as int : int.tryParse("${data["quantity"]}") ?? 0;

                    final isAvailable = quantity > 0;
                    final isNotAvailable = quantity == 0;

                    if (availabilityFilter == "available" && !isAvailable) {
                      return const SizedBox.shrink();
                    }
                    if (availabilityFilter == "not_available" && !isNotAvailable) {
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
                          "Origin: ${data["origin"]}\n"
                          "Price/Day: ${data["rentalPrice"]} BD",
                        ),
                        trailing: const Icon(Icons.info_outline),
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
