import 'package:calio/models/food_stats_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/helpers/date_time_helper.dart';

class ImportExporterPage extends StatelessWidget {
  ImportExporterPage({super.key});

  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import Exported')),
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
                    ElevatedButton(
                      onPressed: () {
                        fixMixedAlignment();
                      },

                      child: Text('Fix ID timestamp miss-alignment'),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // readyData();
                    //     // uploadHistoryToFirebase();
                    //     // calorieDataImporter();
                    //     // readyData();
                    //     // uploadHistoryToFirebase();
                    //   },
                    //   child: Text('Ready Data'),
                    // ),
                    // SizedBox(width: 20),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // globalFoodListExporter();
                    //     // allHistoryDataExporter();
                    //   },
                    //   child: Text('Export'),
                    // ),
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
                    style: TextStyle(color: Colors.grey.shade600, fontFamily: 'monospace', fontSize: 8),
                    decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fixMixedAlignment() async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc('user1').collection('history').doc('2025').collection('data');

    final snapshot = await ref.get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = doc.id;

      // Already migrated → skip
      if (data.containsKey('createdAt') && data.containsKey('lastUpdatedAt')) {
        continue;
      }

      final Timestamp? oldTimestamp = data['timestamp'];
      if (oldTimestamp == null) {
        debugPrint('⚠️ Missing timestamp for doc $id');
        continue;
      }

      // Date from ID (authoritative)
      final DateTime idDateTime = DateTimeHelper.fromDayMonthId(id, 2025);

      // Sanity check
      // final bool isSame = DateTimeHelper.isSameDate(idDateTime, oldTimestamp.toDate());
      //
      // if (!isSame) {
      //   debugPrint('❌ Date mismatch → id=$idDateTime, timestamp=${oldTimestamp.toDate()}');
      //   continue;
      // }

      await ref.doc(id).update({
        'createdAt': Timestamp.fromDate(idDateTime),
        'lastUpdatedAt': oldTimestamp,
        // 'timestamp': FieldValue.delete(),
      });

      debugPrint('✅ Migrated doc $id');
    }
  }

  // void fixMixAlignment() async{
  //   final db = FirebaseFirestore.instance;
  //   final ref = db.collection('users').doc('user1').collection('history').doc('2025').collection('data');
  //   final snapshot = await ref.get();
  //
  //   // print(snapshot);
  //
  //     for (var doc in snapshot.docs) {
  //       final data = doc.data();
  //
  //       String id = doc.id.toString();
  //       FoodStatsEntry foodStatsEntry = FoodStatsEntry.fromMap(id, data);
  //
  //
  //       // DateTime idDatetime = foodStatsEntry.DateTimeHelper.getDateTime(2025);
  //       DateTime idDatetime = DateTimeHelper.fromDayMonthId(id,2025);
  //       DateTime timestampDateTime = foodStatsEntry.timestamp.toDate();
  //
  //       textEditingController.text += 'id:${id} ${foodStatsEntry.timestamp}';
  //       // print('id:${id} ${foodStatsEntry.timestamp}, ${dateTime}');
  //
  //       final isSame = DateTimeHelper.isSameDate(idDatetime, timestampDateTime);
  //
  //       // print('id:${id}, ${foodStatsEntry.timestamp}');
  //       print('${isSame} id:${idDatetime}, ${timestampDateTime}');
  //       if(!isSame)
  //         {
  //
  //
  //           // await ref.doc(id).set(map);
  //         }
  //
  //
  //
  //
  //       // data.
  //
  //
  //     }
  //
  // }

  // void fixTimestamp() async{
  //   final db = FirebaseFirestore.instance;
  //   final ref = db.collection('users').doc('user1').collection('user_history').doc('2025').collection('data');
  //   final snapshot = await ref.get();
  //
  //   // print(snapshot);
  //
  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //
  //     textEditingController.text += 'id:${doc.id.toString()} ${data.toString()}\n';
  //
  //     print('id:${doc.id.toString()} ${data.toString()}\n');
  //   }
  //
  //
  //   //     await ref.doc(id).set(map);
  //
  // }
  //
  // void allHistoryDataExporter() async {
  //   final db = FirebaseFirestore.instance;
  //
  //   //users/user1/user_history/2025/data/1-11
  //   final ref = db.collection('users').doc('user1').collection('user_history').doc('2025').collection('data');
  //
  //   final snapshot = await ref.get();
  //
  //   print("=========== All History Data Exporter =================");
  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //
  //     textEditingController.text += 'id:${doc.id.toString()} ${data.toString()}\n';
  //
  //     print('id:${doc.id.toString()} ${data.toString()}\n');
  //   }
  // }
  //
  // final historyList = [
  //   {
  //     "id": "1-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 1, 14, 22, 37)),
  //     "foodStats": {"version": 0, "calories": 1640.0},
  //   },
  //   {
  //     "id": "10-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 10, 11, 49, 15)),
  //     "foodStats": {"version": 0},
  //   },
  //   {
  //     "id": "16-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 16, 5, 31, 22)),
  //     "foodStats": {"version": 0, "calories": 1580.0},
  //   },
  //   {
  //     "id": "17-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 17, 18, 42, 9)),
  //     "foodStats": {"version": 0, "calories": 2015.0},
  //   },
  //   {
  //     "id": "18-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 18, 10, 55, 48)),
  //     "foodStats": {"version": 0, "calories": 1600.0},
  //   },
  //   {
  //     "id": "19-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 19, 7, 16, 30)),
  //     "foodStats": {"version": 0, "calories": 2709.0},
  //   },
  //   {
  //     "id": "2-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 2, 15, 44, 10)),
  //     "foodStats": {"version": 0, "calories": 1674.0},
  //   },
  //   {
  //     "id": "20-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 20, 9, 29, 51)),
  //     "foodStats": {"version": 0, "calories": 3422.0},
  //   },
  //   {
  //     "id": "21-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 21, 20, 12, 3)),
  //     "foodStats": {"version": 0, "calories": 3900.0},
  //   },
  //   {
  //     "id": "22-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 22, 6, 48, 56)),
  //     "foodStats": {"version": 0, "calories": 2900.0},
  //   },
  //   {
  //     "id": "23-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 23, 13, 33, 17)),
  //     "foodStats": {"version": 0, "calories": 2650.0},
  //   },
  //   {
  //     "id": "24-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 24, 21, 18, 44)),
  //     "foodStats": {"version": 0, "calories": 1150.0},
  //   },
  //   {
  //     "id": "25-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 25, 19, 27, 8)),
  //     "foodStats": {"version": 0, "calories": 2001.0},
  //   },
  //   {
  //     "id": "26-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 26, 8, 49, 30)),
  //     "foodStats": {"version": 0, "calories": 2450.0},
  //   },
  //   {
  //     "id": "27-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 27, 11, 56, 43)),
  //     "foodStats": {"version": 0, "calories": 1556.0},
  //   },
  //   {
  //     "id": "28-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 28, 16, 40, 25)),
  //     "foodStats": {"version": 0, "calories": 4430.0},
  //   },
  //   {
  //     "id": "29-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 29, 23, 2, 59)),
  //     "foodStats": {"version": 0, "calories": 50.0},
  //   },
  //   {
  //     "id": "3-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 3, 9, 33, 51)),
  //     "foodStats": {"version": 0, "calories": 1566.0},
  //   },
  //   {
  //     "id": "30-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 30, 7, 25, 19)),
  //     "foodStats": {"version": 0, "calories": 1666.0},
  //   },
  //   {
  //     "id": "31-10",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 10, 31, 12, 18, 7)),
  //     "foodStats": {"version": 0, "calories": 1460.0},
  //   },
  //   {
  //     "id": "4-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 4, 21, 40, 58)),
  //     "foodStats": {"version": 0, "calories": 1600.0},
  //   },
  //   {
  //     "id": "5-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 5, 13, 22, 36)),
  //     "foodStats": {"version": 0, "calories": 1600.0},
  //   },
  //   {
  //     "id": "6-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 6, 6, 12, 45)),
  //     "foodStats": {"version": 0, "calories": 500.0},
  //   },
  //   {
  //     "id": "7-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 7, 10, 28, 4)),
  //     "foodStats": {"version": 0, "calories": 2179.0},
  //   },
  //   {
  //     "id": "8-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 8, 17, 16, 51)),
  //     "foodStats": {"version": 0, "calories": 3400.0},
  //   },
  //   {
  //     "id": "9-11",
  //     "timestamp": Timestamp.fromDate(DateTime(2025, 11, 9, 19, 55, 20)),
  //     "foodStats": {"version": 0, "calories": 2930.0},
  //   },
  // ];
  //
  // Future<void> uploadHistoryToFirebase() async {
  //   final db = FirebaseFirestore.instance;
  //
  //   final ref = db.collection('users').doc('user1').collection('user_history').doc('2025').collection('data');
  //
  //   for (final data in historyList) {
  //     final String id = data['id'].toString() ?? ref.doc().id.toString(); // use provided ID or generate one
  //
  //     var map = data..remove('id');
  //     await ref.doc(id).set(map);
  //   }
  //
  //   print('Upload complete. ${historyList.length} documents added.');
  // }
}
