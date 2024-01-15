import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/models/user.dart';
import 'package:meta/meta.dart';

import '../../config/paths.dart';
import '../../models/order.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit() : super(AppointmentInitial());

  AppointmentCubit get(context)=> BlocProvider.of(context);
  List<Orders> orders= [];

  bool isEmpty= false;


  void getOrders({
    required List<String> ordersIdsFromAppointments,
    required GroceryUser user})async{

    isEmpty= false;
    emit(AppointmentUpdateOrdersLoading());
    orders=[];
    Future.delayed(Duration(seconds: 3)).then((value) {

      FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where(
        'user.uid',
        isEqualTo: user.uid,
      )
          .where('orderStatus', isEqualTo: 'open')
          .get().then((value) {
        value.docs.forEach((element) {
          Orders order= Orders.fromMap(element.data());
          print('========orderr ${order.orderId}');

          if(!ordersIdsFromAppointments.contains(order.orderId)){
            if(!checkIfOrderInList(orders, order)){
              orders.add(order);
            }
          }
        });

        if(ordersIdsFromAppointments.isEmpty && orders.isEmpty){
          isEmpty= true;
        }

        orders.forEach((element) {
        });
        emit(AppointmentUpdateOrders());
      }).catchError((error){
        emit(AppointmentUpdateOrdersError());
      });
    });


  }


  bool checkIfOrderInList(List<Orders> orders, Orders order){
    for(int i=0 ; i<orders.length ; i++){
      if(orders[i].orderId==order.orderId){
        return true;
      }
    }
    return false;
  }

}
