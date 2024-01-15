import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/network_cubit/states.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkCubit extends Cubit<NetworkStates> {
  NetworkCubit(super.NetworkInitialState);

  static NetworkCubit get(context) => BlocProvider.of(context);

  late StreamSubscription<InternetConnectionStatus> listener; // Declare the listener.

  void initListener() {
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          emit(NetworkConnectedState());
          break;
        case InternetConnectionStatus.disconnected:
          emit(NetworkDisconnectedState());
          break;
      }
    });
  }

}
