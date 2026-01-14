import 'package:flutter/material.dart';
import 'widgets/common/loading/loading_indicator_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Loading Indicator Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoadingIndicatorDemo(),
    );
  }
}