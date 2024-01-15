import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/supportReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/playVideoWidget.dart';
import 'package:grocery_store/widget/playrecordWidget.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../config/assets_manager.dart';
import '../config/colorsFile.dart';

class AppointChatMessageItem extends StatefulWidget {
  final SupportMessage message;
  final GroceryUser user;

  const AppointChatMessageItem({
    required this.message,
    required this.user,
  });

  @override
  State<AppointChatMessageItem> createState() => _AppointChatMessageItemState();

  static Widget chatImage(BuildContext context, String chatContent, bool type,
      bool? isRead, bool? isReceived) {
    return Container(
        padding: EdgeInsets.only(
            left: AppPadding.p14_5,
            right: AppPadding.p14_5,
            top: AppPadding.p10,
            bottom: AppPadding.p10),
        child: Align(
          alignment: (type ? Alignment.topLeft : Alignment.topRight),
          child: Row(
            children: [
              if (type)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w4.w),
                  child: Icon(
                    isRead == true || isReceived == true
                        ? Icons.done_all
                        : Icons.done,
                    size: AppSize.w25.r,
                    color: isRead == true ? AppColors.blue : AppColors.grey,
                  ),
                ),
              Container(
                child: ElevatedButton(
                    child: Material(
                      child: kIsWeb
                          ? widgetShowImages(chatContent, 250)
                          : widgetShowImages(chatContent, 150), //100
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppRadius.r5)),
                      //clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () async {
                      // launchURL(chatContent);
                      var url = chatContent;
                      if (!url.contains('http')) {
                        url = 'https://$url';
                      }
                      await launch(url);
                    },
                    style:
                        ElevatedButton.styleFrom(padding: EdgeInsets.all(0.0))),
                margin: type
                    ? EdgeInsets.only(
                        bottom: AppPadding.p10, right: AppPadding.p10)
                    : EdgeInsets.only(left: AppPadding.p10),
              ),
            ],
          ),
        ));
  }

  // Show Images from network
  static Widget widgetShowImages(String imageUrl, double imageSize) {
    return FadeInImage.assetNetwork(
      placeholder: AssetsManager.purple_logo,
      placeholderScale: 0.5,
      imageErrorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported,
        size: AppSize.w50,
      ),
      height: imageSize,
      width: imageSize,
      image: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
      fadeInCurve: Curves.easeInOut,
      fadeOutDuration: Duration(milliseconds: AppConstants.milliseconds150),
      fadeOutCurve: Curves.easeInOut,
    );
  }
}

class _AppointChatMessageItemState extends State<AppointChatMessageItem> {
  bool adding = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String x = new DateFormat('a')
        .format(DateTime.parse(widget.message.messageTimeUtc!).toLocal());
    String getTime() {
      if (x == "AM") {
        return getTranslated(context, "AM");
      } else {
        return getTranslated(context, "PM");
      }
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
              left: AppPadding.p32.w,
              right: AppPadding.p32.w,
              top: AppPadding.p20.h,
              bottom: AppPadding.p20.h),
          child: Align(
            alignment: (widget.message.userUid != widget.user.uid
                ? Alignment.topLeft
                : Alignment.topRight),
            child: widget.message.type == "image"
                ? AppointChatMessageItem.chatImage(
                    context,
                    widget.message.message!,
                    widget.message.userUid == widget.user.uid,
                    widget.message.isRead,
                    widget.message.isReceived)
                : widget.message.type == "voice"
                    ? Stack(
                        alignment: widget.message.userUid != widget.user.uid
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        children: [
                          PlayRecordWidget(
                            url: widget.message.message!,
                            owner: widget.message.userUid != widget.user.uid,
                          ),
                          if (widget.message.userUid == widget.user.uid)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: AppSize.w40.w, bottom: AppSize.h15.h),
                              child: Icon(
                                widget.message.isRead == true ||
                                        widget.message.isReceived == true
                                    ? Icons.done_all
                                    : Icons.done,
                                size: AppSize.w25.r,
                                color: widget.message.isRead == true
                                    ? AppColors.blue
                                    : AppColors.white,
                              ),
                            ),
                        ],
                      )
                    : widget.message.type == "video"
                        ? Row(
                            mainAxisAlignment:
                                widget.message.userUid == widget.user.uid
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                            children: [
                              if (widget.message.userUid == widget.user.uid)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppSize.w4.w),
                                  child: Icon(
                                    widget.message.isRead == true ||
                                            widget.message.isReceived == true
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: AppSize.w25.r,
                                    color: widget.message.isRead == true
                                        ? AppColors.blue
                                        : AppColors.grey,
                                  ),
                                ),
                              PlayVideoWidget(url: widget.message.message!),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment:
                                widget.message.userUid != widget.user.uid
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment:
                                    widget.message.userUid != widget.user.uid
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                // fit: StackFit.expand,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(AppRadius.r38_6.r),
                                        topRight:
                                            Radius.circular(AppRadius.r38_6.r),
                                        bottomLeft: Radius.circular(
                                            widget.message.userUid !=
                                                    widget.user.uid
                                                ? 0.0
                                                : AppRadius.r38_6.r),
                                        bottomRight: Radius.circular(
                                            widget.message.userUid !=
                                                    widget.user.uid
                                                ? AppSize.w26_5.w
                                                : 0.0),
                                      ),
                                      color: (widget.message.userUid !=
                                              widget.user.uid
                                          ? AppColors.lightgrey5
                                          : AppColors.linear3),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: widget.message.userUid !=
                                                widget.user.uid
                                            ? AppPadding.p10_6.w
                                            : AppPadding.p39_4.w,
                                        right: widget.message.userUid !=
                                                widget.user.uid
                                            ? AppPadding.p39_4.w
                                            : AppPadding.p10_6.w,
                                        top: AppPadding.p12.h,
                                        bottom: AppPadding.p12.h),
                                    child: _createTextMessage(context, size),
                                  ),
                                  if (widget.message.userUid == widget.user.uid)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppSize.w10_6.w),
                                      child: Icon(
                                        widget.message.isRead == true ||
                                                widget.message.isReceived ==
                                                    true
                                            ? Icons.done_all
                                            : Icons.done,
                                        size: AppSize.w16.r,
                                        color: widget.message.isRead == true
                                            ? AppColors.blue
                                            : AppColors.white,
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSize.w16.w),
                                    child: Icon(
                                      widget.message.isRead == true ||
                                              widget.message.isReceived == true
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: AppSize.w26_6.r,
                                      color: widget.message.isRead == true
                                          ? AppColors.blue
                                          : AppColors.linear2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSize.h5_5.h),
                              widget.message.messageTimeUtc != null
                                  ? Row(
                                      mainAxisAlignment:
                                          widget.message.userUid ==
                                                  widget.user.uid
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.end,
                                      children: [
                                        // if (widget.message.userUid ==
                                        //     widget.user.uid)
                                        //   Padding(
                                        //     padding: EdgeInsets.symmetric(
                                        //         horizontal: AppSize.w4.w),
                                        //     child: Icon(
                                        //       widget.message.isRead == true ||
                                        //               widget.message
                                        //                       .isReceived ==
                                        //                   true
                                        //           ? Icons.done_all
                                        //           : Icons.done,
                                        //       size: AppSize.w25.r,
                                        //       color:
                                        //           widget.message.isRead == true
                                        //               ? AppColors.blue
                                        //               : Color.fromRGBO(
                                        //                   167, 165, 165, 1),
                                        //     ),
                                        //   ),
                                        Text(
                                          // ' ${new DateFormat('a' == "AM" ? getTranslated(context, "AM") : getTranslated(context, "PM")).format(DateTime.parse(widget.message.messageTimeUtc!).toLocal())}',
                                          // DateTime.parse(widget.message.messageTimeUtc!).toLocal().toString(),
                                          ' ${new DateFormat('h:mm').format(DateTime.parse(widget.message.messageTimeUtc!).toLocal())}' +
                                              ' ' +
                                              getTime(),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontFamily: getTranslated(
                                                context, "Ithralight"),
                                            fontSize:
                                                AppFontsSizeManager.s16.sp,
                                            color: AppColors.grey,
                                            fontWeight:
                                                AppFontsWeightManager.bold300,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        // if (widget.message.userUid ==
                                        //     widget.user.uid)
                                        //   Padding(
                                        //     padding: EdgeInsets.symmetric(horizontal: AppSize.w4.w),
                                        //     child: Icon(
                                        //       widget.message.isRead == true ||
                                        //           widget.message.isReceived ==
                                        //               true
                                        //           ? Icons.done_all
                                        //           : Icons.done,
                                        //       size: AppSize.w25.r,
                                        //       color: widget.message.isRead == true
                                        //           ? AppColors.blue
                                        //           : Color.fromRGBO(
                                        //           167, 165, 165, 1),
                                        //     ),
                                        //   ),
                                      ],
                                    )
                                  : SizedBox(),
                            ],
                          ),
          ),
        ),
        SizedBox(
          height: AppSize.h5,
        ),
      ],
    );
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(AppMargin.m8),
      borderRadius: BorderRadius.circular(AppRadius.r7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: AppConstants.milliseconds300),
      isDismissible: true,
      boxShadows: [AppShadow.primaryShadow],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds1500),
      icon: Icon(
        Icons.error,
        color: AppColors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: AppFontsSizeManager.s14,
          fontWeight: AppFontsWeightManager.bold500,
          letterSpacing: 0.3,
          color: AppColors.white,
        ),
      ),
    )..show(context);
  }

  launchURL(String url) async {
    if (!url.contains('http')) url = 'https://$url';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // showSnakbar('Could not launch $url', false);

      throw 'Could not launch $url';
    }
  }

  Widget _createTextMessage(context, Size size) {
    return (widget.message.message != null &&
            widget.message.message!.contains('https://'))
        ? InkWell(
            splashColor: AppColors.white.withOpacity(0.5),
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: widget.message.message.toString()));
              showSnack(getTranslated(context, "textCopy"), context);
            },
            child: widget.message.message != null
                ? LinkWell(
                    widget.message.message != null
                        ? widget.message.message!
                        : "...",
                    linkStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: Colors.blue,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: widget.message.userUid != widget.user.uid
                          ? AppColors.black1
                          : AppColors.white1,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  )
                : SizedBox(),
          )
        : InkWell(
            splashColor: AppColors.white.withOpacity(0.5),
            onTap: () {
              if (widget.message.type == "closing" &&
                  widget.user.userType != "SUPPORT") {
                rateDialog(size);
              } else {
                Clipboard.setData(
                    ClipboardData(text: widget.message.message.toString()));
                showSnack(getTranslated(context, "textCopy"), context);
              }
            },
            child: widget.message.message != null
                ? Text.rich(
                    TextSpan(
                      text: widget.message.message != null
                          ? widget.message.message
                          : "...",
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: widget.message.userUid != widget.user.uid
                            ? AppColors.black1
                            : AppColors.white1,
                        fontSize: AppFontsSizeManager.s20.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: " ",
                        ),
                        widget.message.type == "closing"
                            ? TextSpan(
                                text: getTranslated(context, "pressHere"),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 3,
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: Colors.lightBlueAccent,
                                  fontSize: AppFontsSizeManager.s20.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                ),
                              )
                            : TextSpan(
                                text: ' ',
                              ),
                      ],
                    ),
                    softWrap: true,
                    maxLines: 10,
                    textAlign: TextAlign.center,
                  )
                : SizedBox(),
          );
  }

  rateDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r20),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16,
              right: AppPadding.p16,
              top: AppPadding.p20,
              bottom: AppPadding.p10),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "supportRating"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p5,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          addReview("good");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsManager.happy_emo,
                              width: AppSize.w15,
                              height: AppSize.w15,
                              color: Colors.lightBlue,
                            ),
                            SizedBox(
                              width: AppSize.w5,
                            ),
                            Text(
                              getTranslated(context, "good"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          addReview("bad");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              AssetsManager.bad_emo,
                              width: AppSize.w15,
                              height: AppSize.h15,
                              color: Colors.lightBlue,
                            ),
                            SizedBox(
                              width: AppSize.w5,
                            ),
                            Text(
                              getTranslated(context, "bad"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p5,
                      right: AppPadding.p5,
                      top: AppPadding.p5,
                      bottom: AppPadding.p10),
                  child: Container(
                    width: size.width,
                    height: AppSize.h5,
                    color: AppColors.lightGrey1,
                  ),
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }

  Future<void> addReview(String review) async {
    setState(() {
      adding = true;
    });
    try {
      String reviewId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.supportReviewPath)
          .doc(reviewId)
          .set({
        'rating': review == 'good' ? 5 : 0,
        'review': review == "good" ? "good" : "bad",
        'reviewTime': Timestamp.now(),
        'userName': widget.user.name,
        'supportListId': widget.user.supportListId,
        'supportUid': widget.message.userUid,
        'supportName': widget.message.ownerName,
        'image': widget.user.photoUrl,
      });
      //update user review
      List<SupportReview> reviews;
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection(Paths.supportReviewPath)
            .where('supportUid', isEqualTo: widget.message.userUid)
            .get();

        reviews = List<SupportReview>.from(
          (snap.docs).map(
            (e) => SupportReview.fromMap(e.data() as Map),
          ),
        );

        if (reviews.length > 0) {
          double _rating = 0;
          for (var rev in reviews) {
            _rating = _rating + double.parse(rev.rating.toString());
          }

          _rating = _rating / reviews.length;
          _rating = double.parse((_rating.toStringAsFixed(1)));

          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(widget.message.userUid)
              .set({
            'rating': _rating,
            'reviewsCount': reviews.length,
          }, SetOptions(merge: true));
        }
        setState(() {
          adding = false;
        });

        Navigator.pop(context);
        Navigator.pop(context);
      } catch (e) {
        return null;
      }
      //return true;
    } catch (e) {}
  }
}
