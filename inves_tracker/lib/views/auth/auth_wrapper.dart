import 'package:flutter/material.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/core/services/version_check_service.dart';
import 'package:inves_tracker/navigation/main_layout.dart';
import 'package:inves_tracker/shared/app_update_dialog.dart';
import 'package:inves_tracker/views/auth/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // STEP 1: Check version FIRST
    final versionCheck = await VersionCheckService.checkVersion();
    
    if (!mounted) return;

    // STEP 2: Show update dialog if needed
    if (versionCheck != null && versionCheck['updateRequired'] == true) {
      await AppUpdateDialog.show(
        context,
        updateUrl: versionCheck['updateUrl'] ?? '',
        minimumVersion: versionCheck['minimumVersion'] ?? '',
        forceUpdate: versionCheck['forceUpdate'] ?? true,
      );
      
      // If force update, don't proceed
      if (versionCheck['forceUpdate'] == true) {
        setState(() => _isLoading = false);
        return;
      }
    }

    // STEP 3: Check authentication status
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user has token
    final loggedIn = await _authService.isLoggedIn();
    
    if (!loggedIn) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    // Verify token is still valid
    final isValid = await _authService.verifyToken();
    
    if (!isValid) {
      // Token expired or invalid - logout
      await _authService.logout();
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    // Token is valid
    setState(() {
      _isLoggedIn = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary(context),
              ),
              const SizedBox(height: 16),
              const Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainLayout() : const LoginScreen();
  }
}