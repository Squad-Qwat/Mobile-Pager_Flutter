import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';

class AuthenticationPage extends StatelessWidget 
{
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) 
  {
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
                _buildGoogleSignInButton(context),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildCustomerSignInButton(context),
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

  Widget _buildGoogleSignInButton(BuildContext context) 
  {
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
          onTap: () {
            _handleGoogleSignIn(context);
            Navigator.pushNamed(context, AppRoutes.home);
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

  Widget _buildDivider() 
  {
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

  Widget _buildCustomerSignInButton(BuildContext context) 
  {
    return PrimaryButton(
      text: 'Sign in as Customer',
      icon: Iconsax.user,
      onPressed: () {
        _handleCustomerSignIn(context);
      },
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
      height: 56,
    );
  }

  Widget _buildTermsAndPrivacy() 
  {
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

  void _handleGoogleSignIn(BuildContext context) 
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google Sign In clicked', style: GoogleFonts.inter()),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  void _handleCustomerSignIn(BuildContext context)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer Sign In clicked', style: GoogleFonts.inter()),
        backgroundColor: AppColor.primary,
      ),
    );
  }
}