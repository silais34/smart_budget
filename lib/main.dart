import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter engine hazır değilse beklet

  // Türkçe tarih formatları için initialize
  await initializeDateFormatting('tr_TR', null);

  // Uygulamayı başlat
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider ile birden fazla state yönetimi sağlayıcı ekliyoruz
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Tema yönetimi
        ChangeNotifierProvider(create: (_) => TransactionProvider()), // İşlem yönetimi
      ],
      // Consumer ile ThemeProvider'ı dinleyip tema değişikliklerini uygula
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SmartBudget',
            debugShowCheckedModeBanner: false, // Sağ üstteki debug banner'ı gizle
            theme: ThemeData(
              useMaterial3: true, // Material 3 tasarımını kullan
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue, // Tema renklerini mavi tonlarında belirle
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(), // Poppins fontu
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: themeProvider.themeMode, // light/dark mod seçimi
            home: const HomeScreen(), // Ana ekran
          );
        },
      ),
    );
  }
}
