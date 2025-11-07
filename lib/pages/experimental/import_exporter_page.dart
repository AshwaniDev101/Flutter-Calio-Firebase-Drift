import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/diet_food.dart';


class ImportExporterPage extends StatelessWidget {
  ImportExporterPage({super.key});

  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Exported'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(onPressed: () {
                        // readyData();
                        uploadHistoryToFirebase();
                      }, child: Text('Ready Data')),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            calorieDataExported();
                          },
                          child: Text('Export')),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: textEditingController,
                      readOnly: true,
                      showCursor: false,
                      expands: true,
                      maxLines: null,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                        fontSize: 8,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void calorieDataExported() async {
    final db = FirebaseFirestore.instance;

    // /users/user1/history/2025/10
    final ref =
    db.collection('users')
        .doc('user1')
        .collection('history')
        .doc('2025')
        .collection('11');

    final snapshot = await ref.get();

    print("=========== Exported Data =================");
    for (var doc in snapshot.docs) {
      final data = doc.data();

      textEditingController.text += 'id:${doc.id.toString()} ${data.toString()}\n';

      print('id:${doc.id.toString()} ${data.toString()}\n');
    }
  }


  void calorieDataImporter() async {




    final db = FirebaseFirestore.instance;

    // /users/user1/history/2025/10
    final ref =
    db.collection('users')
        .doc('user1')
        .collection('history')
        .doc('2025')
        .collection('11');

    final snapshot = await ref.get();

    print("=========== Imported Data =================");
    for (var doc in snapshot.docs) {
      final data = doc.data();

      textEditingController.text += 'id:${doc.id.toString()} ${data.toString()}\n';

      print('id:${doc.id.toString()} ${data.toString()}\n');
    }
  }


 // Upload whole food list
  void readyData() {
    // Example JSON (already valid)
    final jsonString = '''
[
  {
    "foodStats": {"carbohydrates": 0, "minerals": 0, "vitamins": 0, "fats": 0, "proteins": 3, "calories": 200},
    "name": "Mini Parle-G (45g)",
    "time": "2025-10-14T09:33:18.069034"
  },
  {
    "foodStats": {"carbohydrates": 0, "minerals": 0, "vitamins": 0, "fats": 0, "proteins": 0, "calories": 162},
    "name": "Mini Marie Lite Biscuit (35g)",
    "time": "2025-10-25T00:42:50.265276"
  },
  
]

''';

    // Step 1: Parse JSON into a list of maps
    final data = jsonDecode(jsonString) as List;

    // Step 2: Convert each map to a DietFood object
    final foods = data.map((e) => DietFood.fromJson(e)).toList();

    // Example output
    // for (var f in foods) {
    //   print('${f.name} → ${f.foodStats.calories} kcal');
    // }

    uploadFoodsToFirebase(foods);

  }

  Future<void> uploadFoodsToFirebase(List<DietFood> foods) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc('user1').collection('food_list');

    final batch = db.batch();

    for (final food in foods) {


      final docRef = ref.doc(food.id); // timestamp string as ID

      final map = food.toMap()..remove('id');
      batch.set(docRef, map);
    }

    await batch.commit();
    print('✅ Uploaded ${foods.length} foods successfully.');
  }




  // Upload whole food list
  void readyDataHistory() {
    // Example JSON (already valid)
    final jsonString = '''
[
  {
    "foodStats": {"carbohydrates": 0, "minerals": 0, "vitamins": 0, "fats": 0, "proteins": 3, "calories": 200},
    "name": "Mini Parle-G (45g)",
    "time": "2025-10-14T09:33:18.069034"
  },
  {
    "foodStats": {"carbohydrates": 0, "minerals": 0, "vitamins": 0, "fats": 0, "proteins": 0, "calories": 162},
    "name": "Mini Marie Lite Biscuit (35g)",
    "time": "2025-10-25T00:42:50.265276"
  },
  
]

''';

    // Step 1: Parse JSON into a list of maps
    final data = jsonDecode(jsonString) as List;

    // Step 2: Convert each map to a DietFood object
    final foods = data.map((e) => DietFood.fromJson(e)).toList();

    // Example output
    // for (var f in foods) {
    //   print('${f.name} → ${f.foodStats.calories} kcal');
    // }

    uploadFoodsToFirebase(foods);

  }

  Future<void> uploadHistoryToFirebase() async {
    final db = FirebaseFirestore.instance;
    final ref = db
        .collection('users')
        .doc('user1')
        .collection('history')
        .doc('2025')
        .collection('data');

    final Map<String, dynamic> foodData = {
      "16-10": {"foodStats": {"calories": 1580}},
      "17-10": {"foodStats": {"calories": 2015}},

    };

    final batch = db.batch();

    // Loop through the map entries
    foodData.forEach((id, data) {
      final docRef = ref.doc(id);
      batch.set(docRef, data);
    });

    await batch.commit();
    print('Uploaded ${foodData.length} history records successfully.');
  }





}
