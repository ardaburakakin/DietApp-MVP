import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/dietitian/dietitian_dashboard_screen.dart';

class DietApp extends StatelessWidget {
  const DietApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diyet App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: _buildHome(auth),
    );
  }

  Widget _buildHome(AuthProvider auth) {
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    if (auth.currentUser!.isDietitian) {
      return const DietitianDashboardScreen();
    } else {
      return const PatientDashboardScreen();
    }
  }
}
