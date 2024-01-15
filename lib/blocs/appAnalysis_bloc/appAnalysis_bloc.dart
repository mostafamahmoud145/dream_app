

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/appAnalysis.dart';
import '../../repositories/user_data_repository.dart';

part 'appAnalysis_event.dart';
part 'appAnalysis_state.dart';

class AppAnalysisBloc extends Bloc<AppAnalysisEvent, AppAnalysisState> {
  final UserDataRepository userDataRepository;
  StreamSubscription? appAnalysisSubscription;

  AppAnalysisBloc({required this.userDataRepository}) : super(AppAnalysisInitialState());

  AppAnalysisState get initialState => AppAnalysisInitialState();

  @override
  Future<void> close() {
    appAnalysisSubscription?.cancel();
    return super.close();
  }

  Stream<AppAnalysisState> mapEventToState(
      AppAnalysisEvent event,
      ) async* {

    if (event is UpdateAppAnalysisEvent) {
      yield* mapUpdateProductAnalyticsEventToState(event.appAnalysis);
    }

  }



  Stream<AppAnalysisState> mapUpdateProductAnalyticsEventToState(
      AppAnalysis appAnalysis) async* {
    yield GetAppAnalysisCompletedState(appAnalysis: appAnalysis);
  }

}
