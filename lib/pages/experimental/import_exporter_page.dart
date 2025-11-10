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
                        // uploadHistoryToFirebase();
                        // calorieDataImporter();
                        readyData();
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
        .collection('food_list');
        // .doc('2025')
        // .collection('11');

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
    "version": 0,
    "id": "2025-10-14T09:33:18.069034",
    "name": "Mini Parle-G (45g)",
    "timestamp": "2025-10-14T09:33:18.069034",
    "foodStats": { "version": 0, "calories": 200.0 }
  },
  {
    "version": 0,
    "id": "2025-10-14T09:36:26.965428",
    "name": "Masala Oats (38g)",
    "timestamp": "2025-10-14T09:36:26.965428",
    "foodStats": { "version": 0, "calories": 138.0 }
  },
  {
    "version": 0,
    "id": "2025-10-14T09:40:11.969062",
    "name": "Tomato",
    "timestamp": "2025-10-14T09:40:11.969062",
    "foodStats": { "version": 0, "calories": 20.0 }
  },
  {
    "version": 0,
    "id": "2025-10-14T09:55:17.357172",
    "name": "1 Brown breed slice",
    "timestamp": "2025-10-14T09:55:17.357172",
    "foodStats": { "version": 0, "calories": 74.0 }
  },
  {
    "version": 0,
    "id": "2025-10-15T06:17:38.437938",
    "name": "Egg (Medium)",
    "timestamp": "2025-10-15T06:17:38.437938",
    "foodStats": { "version": 0, "calories": 70.0 }
  },
  {
    "version": 0,
    "id": "2025-10-15T11:13:36.455106",
    "name": "Apple (200g)",
    "timestamp": "2025-10-15T11:13:36.455106",
    "foodStats": { "version": 0, "calories": 100.0 }
  },
  {
    "version": 0,
    "id": "2025-10-15T11:14:41.056979",
    "name": "Red-mug Milk(350g)",
    "timestamp": "2025-10-15T11:14:41.056979",
    "foodStats": { "version": 0, "calories": 160.0 }
  },
  {
    "version": 0,
    "id": "2025-10-15T17:27:58.263955",
    "name": "Dahi (100g)",
    "timestamp": "2025-10-15T17:27:58.263955",
    "foodStats": { "version": 0, "calories": 100.0 }
  },
  {
    "version": 0,
    "id": "2025-10-15T17:35:25.259692",
    "name": "Steam momos",
    "timestamp": "2025-10-15T17:35:25.259692",
    "foodStats": { "version": 0, "calories": 500.0 }
  },
  {
    "version": 0,
    "id": "2025-10-16T02:37:54.821530",
    "name": "pomegranate (218g)",
    "timestamp": "2025-10-16T02:37:54.821530",
    "foodStats": { "version": 0, "calories": 135.0 }
  },
  {
    "version": 0,
    "id": "2025-10-17T06:15:48.910183",
    "name": "Roti with ghee",
    "timestamp": "2025-10-17T06:15:48.910183",
    "foodStats": { "version": 0, "calories": 150.0 }
  },
  {
    "version": 0,
    "id": "2025-10-17T06:17:09.838065",
    "name": "Chana Sag(300g approx)",
    "timestamp": "2025-10-17T06:17:09.838065",
    "foodStats": { "version": 0, "calories": 220.0 }
  },
  {
    "version": 0,
    "id": "2025-10-17T14:06:23.436204",
    "name": "Motichoor Laddu (100g)",
    "timestamp": "2025-10-17T14:06:23.436204",
    "foodStats": { "version": 0, "calories": 300.0 }
  },
  {
    "version": 0,
    "id": "2025-10-18T00:00:25.339862",
    "name": "Double egg roll",
    "timestamp": "2025-10-18T00:00:25.339862",
    "foodStats": { "version": 0, "calories": 600.0 }
  },
  {
    "version": 0,
    "id": "2025-10-19T00:20:41.719364",
    "name": "urad dal (670g)",
    "timestamp": "2025-10-19T00:20:41.719364",
    "foodStats": { "version": 0, "calories": 1000.0 }
  },
  {
    "version": 0,
    "id": "2025-10-20T18:39:28.639173",
    "name": "Banana",
    "timestamp": "2025-10-20T18:39:28.639173",
    "foodStats": { "version": 0, "calories": 72.0 }
  },
  {
    "version": 0,
    "id": "2025-10-20T18:40:35.109386",
    "name": "Rasgulla",
    "timestamp": "2025-10-20T18:40:35.109386",
    "foodStats": { "version": 0, "calories": 200.0 }
  },
  {
    "version": 0,
    "id": "2025-10-20T22:37:01.965102",
    "name": "kachori",
    "timestamp": "2025-10-20T22:37:01.965102",
    "foodStats": { "version": 0, "calories": 200.0 }
  },
  {
    "version": 0,
    "id": "2025-10-21T10:21:48.053448",
    "name": "50 kcal",
    "timestamp": "2025-10-21T10:21:48.053448",
    "foodStats": { "version": 0, "calories": 50.0 }
  },
  {
    "version": 0,
    "id": "2025-10-22T07:29:04.407405",
    "name": "100 kcal",
    "timestamp": "2025-10-22T07:29:04.407405",
    "foodStats": { "version": 0, "calories": 100.0 }
  },
  {
    "version": 0,
    "id": "2025-10-22T07:30:32.183323",
    "name": "Maggi",
    "timestamp": "2025-10-22T07:30:32.183323",
    "foodStats": { "version": 0, "calories": 400.0 }
  },
  {
    "version": 0,
    "id": "2025-10-24T09:26:08.918076",
    "name": "Dry Coconut",
    "timestamp": "2025-10-24T09:26:08.918076",
    "foodStats": { "version": 0, "calories": 600.0 }
  },
  {
    "version": 0,
    "id": "2025-10-24T13:06:06.789050",
    "name": "Single egg role",
    "timestamp": "2025-10-24T13:06:06.789050",
    "foodStats": { "version": 0, "calories": 275.0 }
  },
  {
    "version": 0,
    "id": "2025-10-25T00:42:50.265276",
    "name": "Mini Marie Lite Biscuit (35g)",
    "timestamp": "2025-10-25T00:42:50.265276",
    "foodStats": { "version": 0, "calories": 162.0 }
  },
  {
    "version": 0,
    "id": "2025-10-25T00:51:49.671926",
    "name": "Omlet Single egg",
    "timestamp": "2025-10-25T00:51:49.671926",
    "foodStats": { "version": 0, "calories": 85.0 }
  },
  {
    "version": 0,
    "id": "2025-10-25T06:04:03.529865",
    "name": "chach",
    "timestamp": "2025-10-25T06:04:03.529865",
    "foodStats": { "version": 0, "calories": 54.0 }
  },
  {
    "version": 0,
    "id": "2025-10-25T11:34:49.300757",
    "name": "Dal (256g)",
    "timestamp": "2025-10-25T11:34:49.300757",
    "foodStats": { "version": 0, "calories": 308.0 }
  },
  {
    "version": 0,
    "id": "2025-10-26T21:55:25.199656",
    "name": "500 kcal",
    "timestamp": "2025-10-26T21:55:25.199656",
    "foodStats": { "version": 0, "calories": 500.0 }
  },
  {
    "version": 0,
    "id": "2025-10-27T07:58:39.070313",
    "name": "10 kcal",
    "timestamp": "2025-10-27T07:58:39.070313",
    "foodStats": { "version": 0, "calories": 10.0 }
  },
  {
    "version": 0,
    "id": "2025-10-31T22:00:18.593686",
    "name": "Panner ki sabji(500g)",
    "timestamp": "2025-10-31T22:00:18.593686",
    "foodStats": { "version": 0, "calories": 850.0 }
  },
  {
    "version": 0,
    "id": "2025-10-31T22:02:35.546026",
    "name": "Tandoori Rotii",
    "timestamp": "2025-10-31T22:02:35.546026",
    "foodStats": { "version": 0, "calories": 120.0 }
  },
  {
    "version": 0,
    "id": "2025-11-01T17:06:53.536486",
    "name": "French fries",
    "timestamp": "2025-11-01T17:06:53.536486",
    "foodStats": { "version": 0, "calories": 320.0 }
  },
  {
    "version": 0,
    "id": "2025-11-08T03:49:23.4699",
    "name": "Samosa",
    "timestamp": "2025-11-08T03:49:23.4699",
    "foodStats": { "version": 0, "calories": 300.0 }
  },
  {
    "version": 0,
    "id": "2025-11-08T03:54:20.7920",
    "name": "Onion",
    "timestamp": "2025-11-08T03:54:20.7920",
    "foodStats": { "version": 0, "calories": 35.0 }
  },
  {
    "version": 0,
    "id": "2025-11-08T12:03:20.909",
    "name": "Biryani+Chap(667g)",
    "timestamp": "2025-11-08T12:03:20.909",
    "foodStats": { "version": 0, "calories": 1000.0 }
  },
  {
    "version": 0,
    "id": "2025-11-08T17:23:16.406",
    "name": "cake",
    "timestamp": "2025-11-08T17:23:16.406",
    "foodStats": { "version": 0, "calories": 200.0 }
  }
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
