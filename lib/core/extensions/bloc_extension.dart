import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/jitsi_meet/meet_cubit/meet_cubit.dart';

extension bloc on BuildContext {

  MeetCubit get meetCubit => BlocProvider.of<MeetCubit>(this);
}
