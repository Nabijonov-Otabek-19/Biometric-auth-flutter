import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biometric auth"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final isAuthenticated = await authenticate();

            if (isAuthenticated) {
              navigateToHome();
            } else {
              showMessage();
            }
          },
          child: const Text("Authenticate"),
        ),
      ),
    );
  }

  void navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void showMessage() {
    const snackBar = SnackBar(content: Text('Auth Failed'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

//Check if biometric auth is available
  Future<bool> hasBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print("PlatformError = $e");
      return false;
    }
  }

//Check type of biometric auth available (Eg - Face ID, fingerprint)
  Future<void> checkBiometricType() async {
    final availableBiometrics = await _localAuth.getAvailableBiometrics();
    print('Available biometrics: $availableBiometrics');
  }

  //Authenticate using biometric
  Future<bool> authenticate() async {
    final hasBiometric = await hasBiometrics();

    if (hasBiometric) {
      return await _localAuth.authenticate(
        localizedReason: "Your message here",
        options: const AuthenticationOptions(
          //Shows error dialog for system-related issues
          useErrorDialogs: true,
          //If true, auth dialog is show when app open from background
          stickyAuth: true,
          //Prevent non-biometric auth like such as pin, passcode.
          biometricOnly: true,
        ),
      );
    } else {
      return false;
    }
  }
}
