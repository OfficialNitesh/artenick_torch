import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/user_service.dart';
import 'screens/onboarding/username_screen.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ArtenickApp());
}

class ArtenickApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artenick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.red,
          surface: Color(0xFF1A1A1A),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Color(0xFF1A1A1A),
          elevation: 4,
        ),
      ),
      home: FutureBuilder<bool>(
        future: UserService().hasCompletedOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          return snapshot.data! ? MainNavigation() : UsernameScreen();
        },
      ),
    );
  }
}