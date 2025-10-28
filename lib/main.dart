import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/login_with_phone.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/verify_otp.dart';
import 'core/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
          primarySwatch: Colors.green, // EV green theme
          useMaterial3: true,
        ),
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
