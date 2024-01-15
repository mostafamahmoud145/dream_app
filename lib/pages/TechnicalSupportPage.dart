import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/screens/supportMessagesScreen.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/account_bloc/account_bloc.dart';
import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/SupportList.dart';
import '../../models/user.dart';
import '../../screens/nameSearchScreen.dart';
import '../../widget/supportListItem.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_fonts.dart';

class TechnicalSupportPage extends StatefulWidget {
  @override
  _TechnicalSupportPageState createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage>
    with AutomaticKeepAliveClientMixin<TechnicalSupportPage> {
  final TextEditingController searchController = new TextEditingController();
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  late String theme = "light";
  late AccountBloc accountBloc;
  GroceryUser? user;
  bool _new = true, _pending = false, _all = false, loadingSupportList = true;
  SupportList? supportList;

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      getSupportList();
    });
  }

  Future<void> getUser() async {
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          if (state is GetLoggedUserInProgressState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetLoggedUserCompletedState) {
            user = state.user;
            return Container(
             // height: 888,
              child: Column(
                children: <Widget>[
                  Visibility(
                      visible: user!.userType == "SUPPORT",
                      child: supportWidget(size)),
                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                      visible: _new && user!.userType == "SUPPORT",
                      child: list(size, initiateSearch("_new"))),
                  Visibility(
                      visible: _pending && user!.userType == "SUPPORT",
                      child: list(size, initiateSearch("_pending"))),
                  Visibility(
                      visible: _all && user!.userType == "SUPPORT",
                      child: list(size, initiateSearch("_all"))),
                  loadingSupportList == false
                      ? Visibility(
                          visible: user!.userType != "SUPPORT",
                          child: Expanded(
                              child: //userAndConsultChat(context),
                                  SupportMessageScreen(
                            item: supportList!,
                            user: user!,
                            theme: theme,
                          ))
                          //list(size, initiateSearch("")),
                          )
                      : Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> getSupportList() async {
    final QuerySnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('SupportList')
            .where('userUid', isEqualTo: user!.uid)
            .limit(1)
            .orderBy('messageTime', descending: true)
            .get();

    if (documentSnapshot.docs.isNotEmpty) {
      print("documentSnapshot isNotEmpty ^^^ ");
      supportList = SupportList.fromMap(documentSnapshot.docs[0].data());
      setState(() {
        loadingSupportList = false;
      });
    } else if (documentSnapshot.docs.isEmpty) {
      print("documentSnapshot isEmpty 333 ");
      String supportListId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection("SupportList")
          .doc(supportListId)
          .set({
        'supportListId': supportListId,
        'chatStatus': false,
        'messageTime': FieldValue.serverTimestamp(),
        'owner': user!.userType,
        'supportListStatus': false,
        'userName': user!.name,
        'userUid': user!.uid,
        'lastMessage': "",
        'userMessageNum': 0,
        'supportMessageNum': 0,
        'consultMessageNum': 0,
      });

      var documentSnapshot = await FirebaseFirestore.instance
          .collection("SupportList")
          .doc(supportListId)
          .get();
      supportList = SupportList.fromMap(documentSnapshot.data() as Map);
      setState(() {
        loadingSupportList = false;
      });
    } else {
      throw Exception('No documents found');
    }
  }

  Widget list(Size size, Query _query) {
    return Expanded(
      child: PaginateFirestore(
        separator: Container(
          height: AppSize.w2.w,
          width: double.infinity,
          color: AppColors.separatorColor,
        ),
        itemBuilderType: PaginateBuilderType.listView,
        padding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            bottom: AppPadding.p16,
            top: AppPadding.p16),
        //Change types accordingly
        itemBuilder: (context, documentSnapshot, index) {
          return SupportListItem(
            size: size,
            item: SupportList.fromMap(documentSnapshot[index].data() as Map),
            user: user!,
          );
        },
        query: _query,
        isLive: true,
      ),
    );
  }

  supportWidget(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50.h,
                width: size.width * .7,
                padding:
                    const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [AppShadow.primaryShadow],
                ),
                child: Center(
                  child: TextField(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NameSearchScreen(
                            loggedUser: user!,
                          ),
                        ),
                      );
                    },
                    keyboardType: TextInputType.text,
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    enableInteractiveSelection: true,
                    readOnly: false,
                    style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      fontSize: AppFontsSizeManager.s14_5.sp,
                      color: AppColors.black1,
                      letterSpacing: AppConstants.letterSpacing,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 5.0.h, vertical: 8.0.w),
                      prefixIcon:
                          Icon(Icons.search, size: 25.r, color: AppColors.pink),
                      suffixIcon: InkWell(
                          child: Icon(Icons.send_rounded, size: 25.r),
                          onTap: () {}),
                      border: InputBorder.none,
                      hintText: getTranslated(context, "name"),
                      hintStyle: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: 14.5.sp,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 35.h,
                width: size.width * .15,
                decoration: new BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                    child: Icon(
                      Icons.wifi_protected_setup,
                      size: 25.r,
                      color: AppColors.pink,
                    ),
                    onTap: () {
                      closeAll();
                    }),
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _new = true;
                      _pending = false;
                      _all = false;
                      initiateSearch("_new");
                    });
                  },
                  child: Container(
                    height: 35.h,
                    width: size.width * .25,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _new
                          ? Theme.of(context).primaryColor
                          : AppColors.lightPink,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "_new"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: _new
                              ? AppColors.white
                              : Theme.of(context).primaryColor,
                          fontSize: 14.0.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.green.withOpacity(0.6),
                  onTap: () {
                    setState(() {
                      _new = false;
                      _pending = true;
                      _all = false;
                      initiateSearch("_pending");
                    });
                  },
                  child: Container(
                    height: 35.h,
                    width: size.width * .25,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _pending
                          ? Theme.of(context).primaryColor
                          : AppColors.lightPink,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "_pending"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: _pending
                              ? AppColors.white
                              : Theme.of(context).primaryColor,
                          fontSize: 14.0.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.green.withOpacity(0.6),
                  onTap: () {
                    setState(() {
                      _new = false;
                      _pending = false;
                      _all = true;
                      initiateSearch("_all");
                    });
                  },
                  child: Container(
                    height: 35.h,
                    width: size.width * .25,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _all
                          ? Theme.of(context).primaryColor
                          : AppColors.lightPink,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "_all"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: _all
                              ? AppColors.white
                              : Theme.of(context).primaryColor,
                          fontSize: 14.0.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  closeAll() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .where('openingStatus', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.supportListPath)
            .doc(doc.id)
            .update({
          'openingStatus': false,
        });
      }
    } catch (e) {}
  }

  Query initiateSearch(String val) {
    if (user!.userType == "SUPPORT" && val == "_new")
      return FirebaseFirestore.instance
          .collection('SupportList')
          .where('supportMessageNum', isGreaterThan: 0)
          // .where('userLang', isEqualTo: getTranslated(context, 'lang'))
          .orderBy('supportMessageNum', descending: true);
    else if (user!.userType == "SUPPORT" && val == "_pending")
      return FirebaseFirestore.instance
          .collection('SupportList')
          .where('pending', isEqualTo: true)
          // .where('userLang', isEqualTo: getTranslated(context, 'lang'))
          .orderBy('messageTime', descending: true);
    else if (user!.userType == "SUPPORT" && val == "_all")
      return FirebaseFirestore.instance
          .collection('SupportList')
          //.where('userLang', isEqualTo: getTranslated(context, 'lang'))
          .orderBy('messageTime', descending: true);
    else
      return FirebaseFirestore.instance
          .collection('SupportList')
          .where('userUid', isEqualTo: user!.uid)
          .orderBy('messageTime', descending: true);
  }

  @override
  bool get wantKeepAlive => true;
}
