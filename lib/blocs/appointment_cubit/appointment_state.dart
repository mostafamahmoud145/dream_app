part of 'appointment_cubit.dart';

@immutable
abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}
class AppointmentUpdateOrders extends AppointmentState {}
class AppointmentUpdateOrdersLoading extends AppointmentState {}
class AppointmentUpdateOrdersError extends AppointmentState {}
