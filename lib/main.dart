import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/media_provider.dart';
import 'screens/media_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaProvider()..loadMedia(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Short Video FE',
        theme: AppTheme.lightTheme,
        home: const MediaListScreen(),
      ),
    );
  }
}
