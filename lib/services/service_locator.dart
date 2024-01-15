


import 'package:get_it/get_it.dart';
import 'package:grocery_store/app/authentication/controllers/sign_up_cubit/signup_cubit.dart';

import '../app/authentication/repositories/authentication_repository.dart';

final sl = GetIt.instance;

class ServicesLocator{
  void init(){
    //bloc
    sl.registerLazySingleton(() => SignupCubit(authenticationRepo: sl()));


    // repo
    sl.registerLazySingleton<BaseAuthenticationRepository>(() => AuthenticationRepo());

  }
}
