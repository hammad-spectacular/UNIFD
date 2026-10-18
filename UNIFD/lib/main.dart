import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/university_list_screen.dart';
import 'screens/search_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNIFD - University Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const UniversityListScreen(),
        '/search': (context) => const SearchScreen(),
        '/compare': (context) => const CompareScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
