import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/auth_notifier.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';

class AuthenticationPage extends ConsumerWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        // Navigate based on role
        if (next.user!.isMerchant) {
          _navigateToMerchantFlow(context, ref);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }

      // Show error if any
      if (next.errorMessage != null) {
        final errorMsg = next.errorMessage!;
        Color bgColor = Colors.red;
        
        // Check error type for appropriate color
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
        ref.read(authNotifierProvider.notifier).clearError();
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
              children: [
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

  Widget _buildWelcomeText() {
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

  Widget _buildSubtitle() {
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
      BuildContext context, WidgetRef ref, bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColor.border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => _handleGoogleSignIn(context, ref, role: 'customer'),
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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
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
      children: [
        const Expanded(child: Divider(color: AppColor.divider, thickness: 1)),
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
        const Expanded(child: Divider(color: AppColor.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildGuestSignInButton(
      BuildContext context, WidgetRef ref, bool isLoading) {
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
      BuildContext context, WidgetRef ref, bool isLoading) {
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
          children: [
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

  // Dialog: Merchant information
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

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    WidgetRef ref, {
    required String role,
  }) async {
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle(role: role);
    } catch (e) {
      // Error handled by listener
    }
  }

  // Handle Guest Sign In
  Future<void> _handleGuestSignIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).signInAsGuest();
    } catch (e) {
      // Error handled by listener
    }
  }

  // Navigate to merchant flow
  Future<void> _navigateToMerchantFlow(BuildContext context, WidgetRef ref) async {
    final isProfileComplete =
        await ref.read(authNotifierProvider.notifier).checkMerchantProfile();

    if (!context.mounted) return;

    if (isProfileComplete) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // TODO: Navigate to merchant profile setup page
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete your merchant profile',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColor.primary,
        ),
      );
    }
  }
}