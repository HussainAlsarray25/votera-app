import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';

// Telegram brand color
const _telegramBlue = Color(0xFF2CA5E0);

/// A button that triggers the Telegram bot login flow.
///
/// Tapping it asks the cubit for a deep link, then the listener opens the
/// Telegram app automatically. The button switches to a disabled "waiting"
/// state while polling is in progress.
class TelegramLoginButton extends StatelessWidget {
  const TelegramLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDivider(context),
        const SizedBox(height: AppSpacing.md),
        BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (_, state) =>
              state is AuthTelegramAwaitingUser || state is AuthError,
          listener: (context, state) {
            if (state is AuthTelegramAwaitingUser) {
              // ignore: discarded_futures -- BlocListener is synchronous; errors are handled inside _openTelegramLink
              _openTelegramLink(state.link);
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: context.colors.error,
                ),
              );
            }
          },
          buildWhen: (_, state) =>
              state is AuthTelegramAwaitingUser ||
              state is AuthLoading ||
              state is AuthInitial ||
              state is AuthError,
          builder: (context, state) {
            final isWaiting = state is AuthTelegramAwaitingUser;
            final isLoading = state is AuthLoading;

            return _buildButton(
              context: context,
              label: isWaiting
                  ? 'Waiting for Telegram...'
                  : 'Continue with Telegram',
              isDisabled: isLoading || isWaiting,
              onTap: () => context.read<AuthCubit>().loginWithTelegram(),
            );
          },
        ),
      ],
    );
  }

  /// Tries to open the native Telegram app via the tg:// scheme.
  /// Falls back to the HTTPS web link if the app is not installed.
  Future<void> _openTelegramLink(String tgLink) async {
    final nativeUri = Uri.parse(tgLink);
    try {
      final opened = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        await launchUrl(
          _toWebLink(nativeUri),
          mode: LaunchMode.externalApplication,
        );
      }
    } on Exception catch (_) {
      await launchUrl(
        _toWebLink(nativeUri),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /// Converts tg://resolve?domain=bot&start=token → https://t.me/bot?start=token
  Uri _toWebLink(Uri tgUri) {
    final domain = tgUri.queryParameters['domain'] ?? '';
    final start = tgUri.queryParameters['start'] ?? '';
    return Uri.https(
      't.me',
      '/$domain',
      start.isNotEmpty ? {'start': start} : null,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or continue with',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textHint,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDisabled
                ? _telegramBlue.withValues(alpha: 0.4)
                : _telegramBlue,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              color: isDisabled
                  ? _telegramBlue.withValues(alpha: 0.4)
                  : _telegramBlue,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isDisabled
                    ? _telegramBlue.withValues(alpha: 0.4)
                    : _telegramBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
