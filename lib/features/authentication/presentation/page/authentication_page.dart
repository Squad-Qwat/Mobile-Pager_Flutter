import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/auth_notifier.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';

class AuthenticationPage extends ConsumerWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        if (next.user!.isMerchant) {
          _navigateToMerchantFlow(context, ref);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }

      if (next.errorMessage != null) {
        final errorMsg = next.errorMessage!;
        Color bgColor = Colors.red;

        if (errorMsg.contains('dibatalkan') || errorMsg.contains('cancelled')) {
          bgColor = Colors.orange;
        } else if (errorMsg.contains('sudah terdaftar sebagai')) {
          bgColor = Colors.deepOrange;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: bgColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildWelcomeText(),
                const SizedBox(height: 16),
                _buildSubtitle(),
                const SizedBox(height: 48),
                _buildGoogleSignInButton(context, ref, authState.isLoading),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildGuestSignInButton(context, ref, authState.isLoading),
                const SizedBox(height: 24),
                _buildMerchantLink(context, ref, authState.isLoading),
                const SizedBox(height: 24),
                _buildTermsAndPrivacy(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() 
  {
    return Text(
      'Welcome to Cammo',
      style: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() 
  {
    return Text(
      'Sign in to continue and manage your requests',
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGoogleSignInButton(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColor.border, 
          width: 1.5
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () => _handleGoogleSignIn(context, ref, role: 'customer'),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.primary,
                      ),
                    ),
                  )
                else
                  Icon(Iconsax.google_1, size: 28, color: AppColor.primary),
                const SizedBox(width: 12),
                Text(
                  'Sign in with Google',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(
          color: AppColor.divider, 
          thickness: 1
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(
          color: AppColor.divider, 
          thickness: 1
        )),
      ],
    );
  }

  Widget _buildGuestSignInButton(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
  ) {
    return PrimaryButton(
      text: 'Continue as Guest',
      icon: Iconsax.user,
      onPressed: isLoading ? null : () => _handleGuestSignIn(context, ref),
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
      height: 56,
    );
  }

  Widget _buildMerchantLink(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
  ) {
    return InkWell(
      onTap: isLoading ? null : () => _showMerchantDialog(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Are you a Merchant?',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColor.textSecondary,
          ),
          children: <InlineSpan>[
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMerchantDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Merchant Sign In',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.shop, size: 48, color: AppColor.primary),
            const SizedBox(height: 16),
            Text(
              'Merchants must sign in with Google to access business features and manage orders.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Sign in with Google',
                icon: Iconsax.google_1,
                onPressed: () {
                  Navigator.pop(context);
                  _handleGoogleSignIn(context, ref, role: 'merchant');
                },
                backgroundColor: AppColor.primary,
                textColor: AppColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    WidgetRef ref, {
    required String role,
  }) async {
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .signInWithGoogle(role: role);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<void> _handleGuestSignIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).signInAsGuest();
    } catch (e) {}
  }

  Future<void> _navigateToMerchantFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;

    // Navigate to home directly - merchant settings use default values if not configured
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
}
