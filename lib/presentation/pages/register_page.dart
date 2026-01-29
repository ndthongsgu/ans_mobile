import 'package:ans_mobile/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:ans_mobile/core/services/auth_service.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';
import 'package:ans_mobile/core/theme/grap_theme.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _showError(String msg) => AppToast.showError(context, msg);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(email: _emailCtrl.text.trim(), password: _passCtrl.text, displayName: _nameCtrl.text.trim());
      messenger.hideCurrentSnackBar();
      AppToast.showSuccess(context, AppLocalizations.of(context)!.registerSuccessMsg);
      navigator.pushReplacementNamed('/map');
    } catch (e) {
      messenger.hideCurrentSnackBar();
      AppToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: kGrapGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 64, height: 64, child: Image.asset('lib/assets/imgs/favicon.png')),
                      const SizedBox(height: 12),
                      const SizedBox(height: 6),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), labelText: AppLocalizations.of(context)!.fullNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              validator: (v) => (v == null || v.isEmpty) ? AppLocalizations.of(context)!.enterNameMsg : null,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: InputDecoration(prefixIcon: const Icon(Icons.email_outlined), labelText: AppLocalizations.of(context)!.emailLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.isEmpty) ? AppLocalizations.of(context)!.enterEmailMsg : null,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passCtrl,
                              decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), labelText: AppLocalizations.of(context)!.passwordLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              obscureText: true,
                              validator: (v) => (v == null || v.length < 6) ? AppLocalizations.of(context)!.passwordMinLengthMsg : null,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _register,
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Theme.of(context).colorScheme.primary),
                                child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(AppLocalizations.of(context)!.createAccount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: _loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())),
                                child: Text(
                                  AppLocalizations.of(context)!.backToLogin,
                                  style: TextStyle(decoration: TextDecoration.underline, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
