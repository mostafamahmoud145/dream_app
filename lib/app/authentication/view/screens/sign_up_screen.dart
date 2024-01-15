import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/app/authentication/repositories/authentication_repository.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';
import 'package:grocery_store/screens/privecy_screen.dart';
import 'package:grocery_store/widget/TextButton.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../config/colorsFile.dart';
import '../../../../methods/convert_pt_to_px.dart';
import '../../../../methods/get_phone_without_country_code.dart';
import '../../../../services/service_locator.dart';
import '../../../../widget/back_button.dart';
import '../../controllers/sign_up_cubit/signup_cubit.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key, this.userType});

  final String? userType;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  static final GlobalKey<FormState> _key = GlobalKey<FormState>();
  SignupCubit cubit= sl<SignupCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        key: _scaffoldKey,
        body: SafeArea(
          child: Form(
            key: _key,
            child: ListView(
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: convertPtToPx(AppPadding.p24).w,
                    ),
                    child: CustomBackButton(),
                  ),
                ),
                SizedBox(
                  height: AppSize.h16.h,
                ),
                Container(
                  width: double.infinity,
                  height: AppSize.h1.h,
                  color: AppColors.lightGray,
                ),
                SizedBox(height: AppSize.h228.h),
                /*SizedBox(height: AppSize.h195.h),
              Spacer(),*/
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 192.w),
                  child: Center(
                      child: SvgPicture.asset(
                    AssetsManager.dreamImagePath,
                    width: AppSize.w218_6.w,
                    height: AppSize.h56_6.h,
                  )),
                ),
                SizedBox(height: AppSize.h150_2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                  child: Text(
                    getTranslated(context, "loginText"),
                    maxLines: AppConstants.maxLines,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: AppColors.warmGrey,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      //fontWeight: FontWeight.normal
                    ),
                  ),
                ),
                SizedBox(height: AppSize.h102_6.h),
                BlocConsumer<SignupCubit, SignupStates>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    // SignupCubit cubit = SignupCubit().get(context);

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
                      child: InternationalPhoneNumberInput(
                        textAlignVertical: TextAlignVertical.top,
                        textStyle: TextStyle(
                          fontSize: AppFontsSizeManager.s24.sp,
                        ),
                        searchBoxDecoration: InputDecoration(
                          counterStyle: TextStyle(
                            height: double.minPositive,
                          ),
                          counterText: "",

                          labelStyle: TextStyle(
                              fontFamily: getTranslated(context, "Ithralight"),
                              color: AppColors.grey,
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              fontWeight: AppFontsWeightManager.bold),
                          // fillColor: AppColors.white,filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            borderSide: BorderSide(
                              width: 1,
                              color: AppColors.lightGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            borderSide: BorderSide(
                              width: AppSize.w2.w,
                              color: AppColors.grey3,
                            ),
                          ),
                          contentPadding: EdgeInsets.only(
                              left: AppPadding.p16.w,
                              right: AppPadding.p21_3.w),
                          helperStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.pureBlack.withOpacity(0.65),
                            letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithralight"),
                            color: Colors.grey, //[400],
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            //letterSpacing: AppConstants.letterSpacing,
                          ),
                          labelText: getTranslated(context, "countrySearch"),
                          hintText: getTranslated(context, 'enterMobile'),
                        ),
                        inputDecoration: InputDecoration(
                          counterStyle: TextStyle(
                              //height: double.minPositive,
                              ),
                          counterText: "",
                          border: InputBorder.none,
                          contentPadding: getTranslated(context, "lang") == "ar"
                              ? EdgeInsets.only(
                                  bottom: AppSize.h10.h,
                                  right: AppSize.w32.w,
                                  // left: AppSize.w60.w
                                )
                              : EdgeInsets.only(
                                  //bottom: AppSize.h20.h,
                                  left: AppSize.w32.w,
                                  right: AppSize.w60.w),
                          hintStyle: TextStyle(
                            fontFamily: getTranslated(context, "Ithralight"),
                            color: AppColors.darkGrey3,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            //letterSpacing: AppConstants.letterSpacing,
                          ),
                          hintText: getTranslated(context, 'enterMobile'),
                        ),
                        onInputChanged: (PhoneNumber number) {
                          cubit.onChangePhoneNumber(number);
                        },
                        onInputValidated: (bool value) {},
                        locale: getTranslated(context, 'lang'),
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          trailingSpace: false,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(
                          color: AppColors.grey7,
                          fontFamily:
                              getTranslated(context, 'Montserrat-Regular'),
                          fontSize: AppFontsSizeManager.s24.sp,
                        ),
                        initialValue: cubit.number,
                        textFieldController: controller,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputBorder: OutlineInputBorder(),
                        onSaved: (PhoneNumber number) {},
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSize.h158_6.h),
                BlocConsumer<SignupCubit, SignupStates>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    // SignupCubit cubit = SignupCubit().get(context);

                    return ConditionalBuilder(
                        condition: state is LoginLoadingState ||
                            state is GenerateOTPLoadingState,
                        builder: (context) => Center(
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
                        fallback: (context) => Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p97_3.w),
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
                                    onPress: () async {
                                      print(cubit.number.phoneNumber);
                                      if (cubit.number.phoneNumber == null) {
                                        showFailedSnackBar(
                                            getTranslated(context, "enterAll"));
                                      } else {
                                        String phoneNum =
                                            getPhoneWithoutCountryCode(
                                                cubit.number.phoneNumber!,
                                                cubit.number.dialCode!);
                                        if (phoneNum.trim().isEmpty) {
                                          showFailedSnackBar(getTranslated(
                                              context, "enterAll"));
                                        } else {
                                          cubit.login(
                                              context: context,
                                              userType: userType!);
                                        }
                                      }
                                    },
                                    text: getTranslated(context, "sendCode"),
                                    width: double.infinity,
                                    height: AppSize.h66_6.h,
                                    buttonRadius: AppRadius.r10_6.r,
                                    textSize: AppFontsSizeManager.s21_3.sp,
                                    textfont: getTranslated(context, 'Ithra'),
                                    textcolor: AppColors.white,
                                    Gradient_Color: Colors.transparent,
                                    Gradient_Color2: Colors.transparent,
                                    icon: '',
                                  ),
                                ),
                              ),
                            ));
                  },
                ),
                SizedBox(height: AppSize.h100.h),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          getTranslated(context, "registerNote1"),
                          style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra_Bold'),
                              color: AppColors.grey,
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          height: AppSize.h14_6.h,
                        ),
                        InkWell(
                          splashColor: Colors.blue.withOpacity(0.6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrivecyScreen(), //TermScreen(),
                              ),
                            );
                          },
                          child: Text(
                            getTranslated(context, "registerNote2"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithralight'),
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.pink,
                              decorationThickness: AppSize.w2.w,
                              color: AppColors.pink,
                              //fontWeight: AppFontsWeightManager.semiBold,
                              fontSize: AppFontsSizeManager.s18_6.sp,
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 1,
                        // ),
                        InkWell(
                          splashColor: Colors.blue.withOpacity(0.6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivecyScreen(),
                              ),
                            );
                          },
                          child: Text(
                            getTranslated(context, "registerNote3"),
                            style: TextStyle(
                                fontFamily:
                                    getTranslated(context, 'Ithralight'),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.pink,
                                decorationThickness: AppSize.w2.w,
                                color: AppColors.pink,
                                //fontWeight: AppFontsWeightManager.semiBold,
                                fontSize: AppFontsSizeManager.s18_6.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
