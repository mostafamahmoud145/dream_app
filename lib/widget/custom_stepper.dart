import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/assets_manager.dart';
import 'package:grocery_store/methods/convert_pt_to_px.dart';

import '../config/colorsFile.dart';

class CustomStepper extends StatelessWidget {
  CustomStepper({Key? key, required this.progress, required this.width})
      : super(key: key);
  int progress;
  double width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Container(
            height: convertPtToPx(AppSize.h1.h),
            width: double.infinity,
            color: AppColors.lightGrey9,
          ),
          Container(
            height: convertPtToPx(AppSize.h1.h),
            width: width * progress,
            decoration: BoxDecoration(
              color: AppColors.stepperGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProgressPoint(
                iconColor: AppColors.pink,
                icon: AssetsManager.calendar_check2Path,
                state: getState(progress, 0),
                iconSize: convertPtToPx(AppSize.h20).r,
              ),
              ProgressPoint(
                icon: AssetsManager.whiteDollar2,
                state: getState(progress, 1),
                iconSize: convertPtToPx(AppSize.h10).r,
              ),
              // ProgressPoint(icon: AssetsManager.dollarIconPath, state: getState(progress, 2), iconSize: AppSize.w15,),
            ],
          ),
        ],
      ),
    );
  }

  StepperStates getState(int progress, int progressPointNumber) {
    switch (progressPointNumber) {
      case 0:
        if (progress == 0) {
          return StepperStates.reached;
        } else {
          return StepperStates.done;
        }
      case 1:
        if (progress == 0) {
          return StepperStates.notReached;
        } else if (progress == 1) {
          return StepperStates.reached;
        } else {
          return StepperStates.done;
        }
      default:
        if (progress == 0 || progress == 1) {
          return StepperStates.notReached;
        } else if (progress == 2) {
          return StepperStates.reached;
        } else {
          return StepperStates.done;
        }
    }
  }
}

class ProgressPoint extends StatelessWidget {
  ProgressPoint(
      {Key? key,
      required this.icon,
      this.iconColor = Colors.white,
      required this.state,
      this.iconSize = AppSize.w26_5})
      : super(key: key);
  String icon;
  // bool isReached;
  double iconSize;
  StepperStates state;
  Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: convertPtToPx(AppRadius.r19).r,
      backgroundColor: state == StepperStates.done
          ? AppColors.stepperGreen
          : AppColors.lightGrey9,
      child: CircleAvatar(
          radius: convertPtToPx(AppRadius.r17.r),
          backgroundColor: getStepperColor(state),
          child: SvgPicture.asset(
            icon,
            color: state == StepperStates.reached ? iconColor : AppColors.white,
            width: iconSize,
          )),
    );
  }

  Color getStepperColor(StepperStates state) {
    switch (state) {
      case StepperStates.reached:
        return AppColors.lightGrey9;

      case StepperStates.done:
        return AppColors.stepperGreen;

      case StepperStates.notReached:
        return AppColors.lightGrey9;
    }
  }
}

enum StepperStates { reached, done, notReached }
