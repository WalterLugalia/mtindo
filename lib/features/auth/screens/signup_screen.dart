import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Every field's validator runs, including the password match. The old
    // snackbar check is gone: the mismatch now shows under its own field.
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mtindo', style: AppTextStyles.brandWordmark),
                const SizedBox(height: AppSpacing.xl),
                Text('Make it yours.', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Keep the looks you love, all in one place.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  label: 'Name',
                  hintText: 'Your name',
                  controller: _nameController,
                  validator: (value) => Validators.notEmpty(value, 'name'),
                ),
                const SizedBox(height: AppSpacing.md),

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
                  hintText: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Confirm password',
                  hintText: 'Enter it once more',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  // Reads the first password's text at the moment of
                  // checking, so it always compares against what is
                  // currently typed there.
                  validator: (value) =>
                      Validators.matches(value, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.sm),

                if (authState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      authState.error.toString(),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),

                AppButton(
                  label: 'Create account',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),

                Center(
                  child: Wrap(
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Log in', style: AppTextStyles.linkAccent),
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
}