import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/analysis_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/loading_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'AI Tespit Sistemi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF667eea),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AppWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Uygulama başlangıcında kullanıcı bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUserFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: 'Giriş yapılıyor...',
          child: authProvider.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}
