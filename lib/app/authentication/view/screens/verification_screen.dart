import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/app/authentication/controllers/verification_code_cubit/verification_code_cubit.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../config/colorsFile.dart';
import '../../../../methods/convert_pt_to_px.dart';
import '../../../../widget/back_button.dart';
import '../widgets/load_text_field_shimmer.dart';

class VerificationScreen extends StatefulWidget {
  static final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final String userType;
  final String token;
  final PhoneNumber number;
  final bool withApi;

  VerificationScreen({
    required this.userType,
    required this.token,
    required this.number,
    required this.withApi,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  MaskedTextController otpController = MaskedTextController(mask: '000000');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late String smsCode = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return VerificationCodeCubit()
          ..initData(
              token: widget.token,
              number: widget.number,
              userType: widget.userType,
              context: context,
              withApi: widget.withApi);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        key: _scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: VerificationScreen._key,
              child: Column(
                children: <Widget>[
                  SafeArea(
                      child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: convertPtToPx(AppPadding.p24).w,
                        vertical: convertPtToPx(AppPadding.p15).h,
                      ),
                      child: CustomBackButton(),
                    ),
                  )),

                  Padding(
                    padding: EdgeInsets.only(
                        top: AppPadding.p149.h,
                        left: AppPadding.p200.w,
                        right: AppPadding.p200.w),
                    child: Container(
                        width: AppSize.w165.w,
                        height: AppSize.h264_5.h,
                        child: SvgPicture.asset(
                          AssetsManager.otpScreenImagePath,
                        )),
                  ),

                  BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      VerificationCodeCubit cubit =
                          VerificationCodeCubit().get(context);

                      return Padding(
                        padding: EdgeInsets.only(
                            //right: AppPadding.p73.w,
                            //left: AppPadding.p73.w,
                            top: AppPadding.p85.h,
                            bottom: AppPadding.p64.h),
                        child: Text(
                          cubit.load
                              ? getTranslated(context, "otpSending")
                              : getTranslated(context, "otpSend"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'Ithra'),
                            color: AppColors.grey,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            //fontWeight: AppFontsWeightManager.bold300,
                          ),
                        ),
                      );
                    },
                  ),

                  BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      VerificationCodeCubit cubit =
                          VerificationCodeCubit().get(context);

                      switch (cubit.load) {
                        case true:
                          return loadVerificationCode();
                        case false:
                          return Container(
                            width: AppSize.w372.w,
                            //height: AppSize.h64.h,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p25,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white6,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r).w,
                            ),
                            child: Center(
                              child: Container(
                                child: TextFormField(
                                  controller: otpController,
                                  validator: (String? val) {
                                    if (val!.isEmpty) {
                                      return getTranslated(
                                          context, "optRequired");
                                    } else if (val.length < 6) {
                                      return getTranslated(
                                          context, "invalidOtp");
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    smsCode = val;
                                    if (val.trim().length == 6) {
                                      VerificationCodeCubit()
                                          .get(context)
                                          .verifyOTP(otpCode: val);
                                    }
                                  },
                                  enableInteractiveSelection: true,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, 'Ithra'),
                                    color: AppColors.linear3,
                                    fontSize: AppFontsSizeManager.s26_6.sp,
                                    fontWeight: AppFontsWeightManager.semiBold,
                                  ),
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    helperStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      color: AppColors.grey,
                                      fontWeight: AppFontsWeightManager.bold500,
                                      letterSpacing: AppConstants.letterSpacing,
                                    ),
                                    errorStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      fontSize: AppFontsSizeManager.s14_5.sp,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                    hintStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      color: Color.fromRGBO(175, 175, 175, 1),
                                      fontSize: AppFontsSizeManager.s26_6.sp,
                                      fontWeight: AppFontsWeightManager.bold300,
                                      letterSpacing: AppConstants.letterSpacing,
                                    ),
                                    hintText: 'OTP',
                                    // labelText: 'OTP',
                                    labelStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, 'Ithralight'),
                                      color: AppColors.grey3,
                                      fontSize: AppFontsSizeManager.s26_6.sp,
                                      fontWeight: AppFontsWeightManager.bold300,
                                    ),
                                    //contentPadding: EdgeInsets.only(bottom: AppPadding.p17_3.h)
                                  ),
                                ),
                              ),
                            ),
                          );
                      }
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      right: AppPadding.p85.w,
                      left: AppPadding.p105.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        BlocConsumer<VerificationCodeCubit,
                                VerificationCodeState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              return VerificationCodeCubit()
                                          .get(context)
                                          .time ==
                                      0
                                  ? TextButton(
                                      onPressed: () {
                                        VerificationCodeCubit()
                                            .get(context)
                                            .resendOTP();
                                      },
                                      child: Text(
                                        getTranslated(context, "resendOtp"),
                                        style: TextStyle(
                                          fontFamily: getTranslated(
                                              context, 'Ithralight'),
                                          color: AppColors.darkGrey3,
                                          fontSize: AppFontsSizeManager.s16.sp,
                                          fontWeight:
                                              AppFontsWeightManager.regular,
                                        ),
                                      ),
                                    )
                                  : SizedBox();
                            }),
                        // : SizedBox(),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPadding.p20.h),
                          child: Row(
                            children: [
                              Text(
                                'sec ',
                                style: TextStyle(
                                  fontFamily: getTranslated(
                                      context, 'Montserrat-Regular'),
                                  color: AppColors.darkGrey3,
                                  fontSize: AppFontsSizeManager.s16.sp,
                                  fontWeight: AppFontsWeightManager.regular,
                                  letterSpacing: AppConstants.letterSpacing,
                                ),
                              ),
                              BlocConsumer<VerificationCodeCubit,
                                      VerificationCodeState>(
                                  listener: (context, state) {},
                                  builder: (context, state) {
                                    return Text(
                                      '${VerificationCodeCubit().get(context).time}',
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, 'Montserrat-Regular'),
                                        color: AppColors.darkGrey3,
                                        fontSize: AppFontsSizeManager.s16.sp,
                                        fontWeight:
                                            AppFontsWeightManager.regular,
                                        letterSpacing:
                                            AppConstants.letterSpacing,
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      VerificationCodeCubit cubit =
                          VerificationCodeCubit().get(context);

                      switch (cubit.load) {
                        case true:
                          return Padding(
                            padding: EdgeInsets.only(top: AppPadding.p120.h),
                            child: Center(
                                child: SizedBox(
                              height: AppSize.h30_6.h,
                              width: AppSize.w30_6.w,
                              child: LoadingIndicator(
                                indicatorType: Indicator.lineSpinFadeLoader,

                                /// Required, The loading type of the widget
                                colors: const [AppColors.pink3],

                                /// Optional, The color collections
                                strokeWidth: 1,
                              ),
                            )),
                          );
                        case false:
                          return Padding(
                            padding: EdgeInsets.only(top: AppPadding.p120.h),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                    gradient: LinearGradient(
                                        colors: [
                                          AppColors.gradiant2,
                                          AppColors.gradiant1
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                                child: textButton(
                                  onPress: () {
                                    if (smsCode.trim().length == 6) {
                                      VerificationCodeCubit()
                                          .get(context)
                                          .verifyOTP(otpCode: smsCode);
                                    } else {
                                      showFailedSnackBar(
                                          getTranslated(context, 'invalidOtp'));
                                    }
                                  },
                                  text: getTranslated(context, "activated2"),
                                  width: AppSize.w390.w,
                                  height: AppSize.h66_6.h,
                                  buttonRadius: AppRadius.r10_6.r,
                                  textSize: AppFontsSizeManager.s21_3.sp,
                                  textfont:
                                      getTranslated(context, 'Ithra_Bold'),
                                  textcolor: AppColors.white,
                                  Gradient_Color: Colors.transparent,
                                  Gradient_Color2: Colors.transparent,
                                  icon: '',
                                ),
                              ),
                            ),
                          );
                      }
                    },
                  ),
                  // buildVerificationBtn(context, load, size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
