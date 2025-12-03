import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './database/database_helper.dart';
import './screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Testar criação do banco
  await DatabaseHelper.instance.testDatabase();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Cadastro de Tarefas - RA 202310405',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          secondary: Colors.lightBlueAccent,
        ),
        useMaterial3: true,
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),

      home: const HomeScreen(),
    );
  }
}
