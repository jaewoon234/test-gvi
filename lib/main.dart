import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_page.dart';
import 'project_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'G-VISION',
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff4CAF50)),
        ),
        home: MyPage(),
      ),
    );
  }
}
