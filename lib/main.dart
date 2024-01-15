// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_smartlook/flutter_smartlook.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/network_cubit/cuibt.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/config/app_fonts.dart';
import 'package:grocery_store/config/app_shadow.dart';
import 'package:grocery_store/config/app_values.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/constants.dart';
import 'package:grocery_store/methods/change_user_call_state.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:grocery_store/screens/forceUpdateScreen.dart';
import 'package:grocery_store/screens/languageScreen.dart';
import 'package:grocery_store/screens/noInternet.dart';
import 'package:grocery_store/screens/onBoardingScreen.dart';
import 'package:grocery_store/screens/registerType.dart';
import 'package:grocery_store/app/authentication/view/screens/sign_up_screen.dart';
import 'package:grocery_store/screens/splash_screen.dart';
import 'package:grocery_store/screens/startCallScreen.dart';
import 'package:grocery_store/screens/welcomeScreen.dart';
import 'package:grocery_store/services/bloc_observer.dart';
import 'package:grocery_store/services/service_locator.dart';
import 'package:grocery_store/shared%20preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Utils/app_life_cycle-observer.dart';
import 'blocs/jitsi_meet/call_cubit/call_cubit.dart';
import 'blocs/network_cubit/states.dart';
import 'localization/language_constants.dart';
import 'localization/set_localization.dart';
import 'models/DefaultFirebaseConfig.dart';
import 'screens/home_screen.dart';
import 'services/app_flyer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await Firebase.initializeApp();
  //Bloc.observer = MyBlocObserver();

  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();
  if (!kIsWeb) {
    await AppFlyerService().init(FirebaseAuth.instance.currentUser?.uid);
  }
  await CashHelper.init();
  AppLifecycleObserver appLifecycleObserver = AppLifecycleObserver();
  appLifecycleObserver.initialize();

  ServicesLocator().init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
          create: (context) => SignupBloc(
            authenticationRepository: authenticationRepository,
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<SigninBloc>(
          create: (context) => SigninBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),
        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider(
          create: (context) =>
              NetworkCubit(NetworkInitialState())..initListener(),
        ),
      ],
      child: MyApp(initialLink),
    ),
  );
}

class MyApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;

  const MyApp(
    this.initialLink, {
    Key? key,
  }) : super(key: key);

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isSet = false;
  Locale? _local;
  bool firstLansh = false;
  bool _isCall = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setLocale(Locale locale) {
    setState(() {
      _local = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _local = locale;
      });
    });
    getFirstLanch().then((ss) {
      setState(() {
        firstLansh = ss;
      });
    });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    // getNotificationPermission();

    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseDatabase.instance
          .ref('userCallState')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('callState')
          .onDisconnect()
          .set('closed');
    }
    WidgetsBinding.instance.addObserver(this);
    //Check call when open app from terminated
    checkAndNavigationCallingPage(null);
  }

  Future<dynamic> getCurrentCall() async {
    //check current call from pushkit if possible
    //var calls = await CallKeep.instance.activeCalls();
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls.isNotEmpty) {
      return calls[0];
    } else {
      if (FirebaseAuth.instance.currentUser != null) {
        await changeUserState(
            userId: FirebaseAuth.instance.currentUser!.uid, state: 'closed');
      }
      return null;
    }
  }

  Future<void> checkAndNavigationCallingPage(BuildContext? contexts) async {
    var currentCall = await getCurrentCall();
    if (_isCall) {
      _isCall = false;
    } else {
      if (currentCall != null) {
        _isCall = true;
        //navigatorKey.currentState!.pushNamed('/startCallScreen');

        if (Platform.isIOS == true) {
          if (navigatorKey.currentState == null) {
            Navigator.pushNamed(contexts!, '/startCallScreen');
          }
        } else {
          if (contexts != null) {
            Navigator.pushNamed(contexts, '/startCallScreen');
          } else if (navigatorKey.currentState == null) {
            navigatorKey.currentState!.pushNamed('/startCallScreen');
          }
        }
      }
    }
  }

  void endCall() {
    _isCall = false;
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   print(state);
  //   if (state == AppLifecycleState.resumed) {
  //     //Check call when open app from background
  //     checkAndNavigationCallingPage(null);
  //   }
  // }

  // void updatePreferences(PermissionStatus status) async {

  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   if(status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
  //     prefs.setBool("notificationPermission", false);
  //   } else {
  //     prefs.setBool("notificationPermission", true);
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initSmartlook() async {
    setState(() {
      isSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    if (_local == null) {
      return Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[800]!)),
      );
    } else {
      return ScreenUtilInit(
        designSize: const Size(573, 1242),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return BlocConsumer<NetworkCubit, NetworkStates>(
            listener: (context, state) {
              if (state is NetworkDisconnectedState) {
                navigatorKey.currentState!.pushNamed('/noConnectionScreen');
              } else if (state is NetworkConnectedState) {
                if (navigatorKey.currentState != null)
                  {
                    if (navigatorKey.currentState!.canPop()) {
                      navigatorKey.currentState!.pop();
                    }
                  }
              }
            },
            builder: (context, state) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'DREAM',
                // navigatorKey: locator<NavigationService>().navigatorKey,
                locale: _local,
                supportedLocales: const [
                  Locale('ar', 'AR'),
                  Locale('en', 'US'),
                  Locale('fr', 'FR'),
                  Locale('id', 'ARB')
                ],
                localizationsDelegates: const [
                  SetLocalization.localizationsDelegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (deviceLocal, supportedLocales) {
                  // if (!supportedLocales.contains(deviceLocal)) {
                  //   _local = supportedLocales.first;
                  // }
                  return _local;
                },
                theme: ThemeData(
                  primaryColor: AppColors.pink2,
                  colorScheme: ColorScheme.light(primary: AppColors.pink2),
                  buttonTheme:
                      const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                navigatorKey: navigatorKey,
                initialRoute: _isCall ? '/startCallScreen' : '/',
                routes: {
                  '/': (context) => _isCall
                      ? HomeScreen()
                      : firstLansh
                          ? LanguageScreen()
                          : SplashScreen(widget.initialLink),
                  '/welcome': (context) => WelcomeScreen(),
                  '/startCallScreen': (context) {
                    print('start call route');
                    endCall();
                    return BlocProvider(
                      create: (context) => CallCubit(),
                      child: startCallScreen(),
                    );
                  },
                  '/RegisterTypeScreen': (context) => RegisterTypeScreen(),
                  '/home': (context) => HomeScreen(),
                  '/sign_up': (context) => SignUpScreen(),
                  '/Register_Type': (context) => RegisterTypeScreen(),
                  '/ForceUpdateScreen': (context) =>
                      ForceUpdateScreen(), //const ForceUpdateScreen(),
                  '/OnBoardingScreen': (context) => const OnBoardingScreen(),
                  '/noConnectionScreen': (context) => const NoInternet(),
                },
              );
            },
          );
        },
      );
    }
  }
}

mayAppCheckCall({BuildContext? contexts}) {
  _MyAppState().checkAndNavigationCallingPage(contexts);
}

mayAppChangIsCall() {
  _MyAppState().endCall();
}

BuildContext? getHomeContext() => _MyAppState().navigatorKey.currentContext;
