import 'package:ShipRyd_app/features/auth/domain/usescases/login_with_phone.dart';
import 'package:ShipRyd_app/features/auth/domain/usescases/verify_otp.dart';
import 'package:ShipRyd_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load .env (API keys, etc.)
    await dotenv.load(fileName: ".env");

    // 2. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Initialize Dependency Injection
    await di.init();

    // 4. Run the app
    runApp(const MyApp());
  } catch (e) {
    // Critical: If Firebase or DI fails, show error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'App failed to start: $e',
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginWithPhone: di.sl<LoginWithPhone>(),
            verifyOtp: di.sl<VerifyOtp>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'EV Ride App',
        theme: ThemeData(
          primarySwatch: Colors.black, // EV green theme
          useMaterial3: true,
        ),
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
