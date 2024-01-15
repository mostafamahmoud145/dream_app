import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/rate_bloc/cuibt/states.dart';

import '../../../config/assets_manager.dart';

class RateCubit extends Cubit<RateStates> {
  RateCubit(super.RateInitialState);

  static RateCubit get(context) => BlocProvider.of(context);

  List<Map<String, dynamic>> reactions = [
    {AssetsManager.happy : 5},
    {AssetsManager.smile : 4},
    {AssetsManager.regular : 3},
    {AssetsManager.sad : 2},
    {AssetsManager.angry : 1}
  ];

  Map<String, dynamic>? selected;

  void changeSelected(Map<String, dynamic> _selected){
    selected = _selected;
    emit(ChangedReactionState());
  }
}
