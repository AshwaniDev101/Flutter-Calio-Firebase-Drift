import 'package:calio/pages/calories_counter/calorie_counter_page/calories_counter_page.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/my_painter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calio Counter',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: CalorieCounterPage(pageDateTime: DateTime.now())
      home: DemoPaintWidget()
    );
  }
}


