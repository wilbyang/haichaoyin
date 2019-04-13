import 'package:flutter/material.dart';
import 'package:haichaoyin/player/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(title: "海潮音")//MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
