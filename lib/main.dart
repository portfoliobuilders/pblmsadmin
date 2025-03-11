import 'package:flutter/material.dart';
import 'package:pblmsadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Portfolix LMS',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      final authProvider =
          Provider.of<AdminAuthProvider>(context, listen: false);
      authProvider.AdmincheckAuthprovider(context);
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
