import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/note_manager.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const SaynoteApp());
}

class SaynoteApp extends StatelessWidget {
  const SaynoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteManager(),
      child: MaterialApp(
        title: 'Saynote - AI Not Asistanı',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4285F4),
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
