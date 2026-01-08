import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/core/utils/locale_notifier.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/navigation/main_layout.dart';
import 'package:inves_tracker/views/auth/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        _showError(l10n.invalidEmailOrPassword);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.danger3,
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = context.watch<LocaleNotifier>();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      resizeToAvoidBottomInset: true,

      // ✅ Language selector safely placed in AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: _buildLanguageSelector(localeNotifier, context),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.h),

                  // Welcome Text
                  Text(
                    l10n.welcome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Logo
                  Image.asset(
                    'assets/img/splash/logo.png',
                    height: 152.h,
                    width: 152.w,
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'InvesTracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary(context),
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      context,
                      label: l10n.email,
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!value.contains('@')) {
                        return l10n.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      context,
                      label: l10n.password,
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterPassword;
                      }
                      if (value.length < 8) {
                        return l10n.passwordMustBeAtLeast8Characters;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.login,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),

                  SizedBox(height: 16.h),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.dontHaveAnAccount),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.register,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =======================
  // Widgets
  // =======================

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.foreground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  Widget _buildLanguageSelector(
    LocaleNotifier localeNotifier,
    BuildContext context,
  ) {
    final currentLocale =
        localeNotifier.locale ?? Localizations.localeOf(context);
    final isEnglish = currentLocale.languageCode == 'en';

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.foreground(context),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            flagAsset: 'assets/img/flags/gbp.png',
            isSelected: isEnglish,
            onTap: () => localeNotifier.setLocale(const Locale('en')),
          ),
          SizedBox(width: 4.w),
          _LanguageButton(
            flagAsset: 'assets/img/flags/try.png',
            isSelected: !isEnglish,
            onTap: () => localeNotifier.setLocale(const Locale('tr')),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flagAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flagAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary(context).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary(context),
                  width: 2.w,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.asset(
            flagAsset,
            height: 24.h,
            width: 24.w,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
