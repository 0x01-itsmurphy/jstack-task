import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthSessionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 72,
              color: context.colors.primary,
            ),
            Text(AppConfig.appName, style: context.textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
