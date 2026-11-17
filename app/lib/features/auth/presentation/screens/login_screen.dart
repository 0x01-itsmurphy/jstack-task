import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  @override
  void initState() {
    super.initState();
    if (context.read<AuthBloc>().state.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.showSnackBar('Your session has expired. Please log in again.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == LoginStatus.success,
      listener: (context, state) =>
          context.read<AuthBloc>().add(AuthLoggedIn(state.user!)),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginHeader(),
                    SizedBox(height: 32),
                    _LoginForm(),
                    SizedBox(height: 24),
                    _DemoCredentialsHint(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: 56,
          color: context.colors.primary,
        ),
        const SizedBox(height: 12),
        Text(AppConfig.appName, style: context.textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text('Sign in to continue'),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;
        final failure = state.status == LoginStatus.failure
            ? state.failure
            : null;

        return AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                AppTextField(
                  key: const Key('login_email_field'),
                  label: 'Email address',
                  controller: _emailController,
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  enabled: !isSubmitting,
                ),
                AppTextField(
                  key: const Key('login_password_field'),
                  label: 'Password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.password,
                  enabled: !isSubmitting,
                  onFieldSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    key: const Key('login_password_toggle'),
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                if (failure != null) ErrorBanner(message: failure.message),
                const SizedBox(height: 4),
                AppButton(
                  key: const Key('login_submit_button'),
                  label: 'Login',
                  icon: Icons.login_rounded,
                  isLoading: isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DemoCredentialsHint extends StatelessWidget {
  const _DemoCredentialsHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Demo: demo@jstack.co / Demo@123',
      textAlign: TextAlign.center,
      style: context.textTheme.bodySmall,
    );
  }
}
