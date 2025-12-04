import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/inputfileds/text_inputfiled.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/notifiers/pager_notifier.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';

class AddPagerPage extends ConsumerStatefulWidget {
  const AddPagerPage({super.key});

  @override
  ConsumerState<AddPagerPage> createState() => _AddPagerPageState();
}

class _AddPagerPageState extends ConsumerState<AddPagerPage> {
  final TextEditingController _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final pagerState = ref.watch(pagerNotifierProvider);

    ref.listen<PagerState>(pagerNotifierProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(pagerNotifierProvider.notifier).clearMessages();
        Navigator.pop(context);
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(pagerNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Pager',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppPadding.p16),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(color: AppColor.grey300, width: 1)),
        ),
        child: PrimaryButton(
          text: pagerState.isLoading ? "Creating..." : "Create Pager",
          onPressed: pagerState.isLoading ? null : _handleCreatePager,
        ),
      ),
      body: Container(
        height: 460,
        margin: EdgeInsets.symmetric(vertical: AppPadding.p24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInputField(
                controller: _labelController,
                hint: 'Enter seat number (Optional)',
                label: 'Seat Number',
              ),
              SizedBox(height: AppPadding.p24),
              Text(
                'Snap receipt photo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: AppPadding.p12),
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.grey200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.grey300, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColor.grey600,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreatePager() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final label = _labelController.text.trim();

    await ref
        .read(pagerNotifierProvider.notifier)
        .createPager(merchantId: user.uid, label: label.isEmpty ? null : label);
  }
}
