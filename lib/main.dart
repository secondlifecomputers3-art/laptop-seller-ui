import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/laptop_provider.dart';
import './pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LaptopProvider()..loadLaptops(),
      child: MaterialApp(
        title: 'Second Life Computers - Renewed And Ready To Use',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}