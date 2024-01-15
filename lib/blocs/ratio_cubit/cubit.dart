import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/ratio_cubit/states.dart';

class RatioCubit extends Cubit<RatioStates> {
  RatioCubit(super.RatioInitialState);

  static RatioCubit get(context) => BlocProvider.of(context);

  String? selectedOption;

  void changeRadio(value){
    selectedOption = value;
    emit(RatioChangedState());
  }



}
