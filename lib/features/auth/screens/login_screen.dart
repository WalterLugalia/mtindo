import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() runs every field's validator inside the Form, shows each
    // error under its field, and returns true only if all of them pass.
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Leave this screen once sign-in succeeds. canPop() guards against
    // popping when there is nothing to go back to.
    // ref.listen(authControllerProvider, (previous, next) {
    //   if (next.hasValue && !next.isLoading && previous?.isLoading == true) {
    //     if (context.canPop()) {
    //       context.pop();
    //     }
    //   }
    // });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            // After the person has touched a field, keep re-checking it as
            // they type, so an error disappears as soon as it is fixed.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mtindo', style: AppTextStyles.brandWordmark),
                const SizedBox(height: AppSpacing.xl),
                Text('Welcome back.', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pick up where your eye left off.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  // Only "not empty" at login. The length rule applies when
                  // choosing a password, not when using an existing one.
                  validator: (value) => Validators.notEmpty(value, 'password'),
                ),
                const SizedBox(height: AppSpacing.xs),

                if (authState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      _errorMessage(authState.error),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // Forgot password flow: a later task
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.linkAccent,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                AppButton(
                  label: 'Log in',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),

                Center(
                  child: Wrap(
                    children: [
                      Text('New to Mtindo? ', style: AppTextStyles.bodyMedium),
                      GestureDetector(
                        onTap: () => context.push(RouteConstants.signup),
                        child: Text(
                          'Create account',
                          style: AppTextStyles.linkAccent,
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
    );
  }

  String _errorMessage(Object? error) {
    if (error == null) return 'Something went wrong.';
    // Failure overrides toString() to return its message.
    return error.toString();
  }
}