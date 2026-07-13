import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/approval/approval_provider.dart';
import 'features/directory/directory_provider.dart';
import 'features/services/services_provider.dart';
import 'features/dashboard/dashboard_provider.dart';
import 'shell/app_shell.dart';

// ═══════════════════════════════════════════════════════════════
// HELPI ADMIN VAULT — Entry Point
// ═══════════════════════════════════════════════════════════════

void main() {
  runApp(const HelpiAdminVault());
}

class HelpiAdminVault extends StatelessWidget {
  const HelpiAdminVault({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ApprovalProvider()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
      ],
      child: MaterialApp(
        title: 'Helpi Admin Vault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(
            AppTheme.darkTheme.textTheme,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return const AppShell();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
