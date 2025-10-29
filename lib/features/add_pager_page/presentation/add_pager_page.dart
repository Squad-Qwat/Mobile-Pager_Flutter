<<<<<<< HEAD

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/inputfileds/text_inputfiled.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
=======
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
>>>>>>> origin/dev_darrel

class AddPagerPage extends StatelessWidget {
  const AddPagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: PrimaryButton(text: "Create Pager", onPressed: () {}),
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
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInputField(
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
}
