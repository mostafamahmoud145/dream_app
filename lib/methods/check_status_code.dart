
import 'package:flutter/cupertino.dart';
import 'package:grocery_store/methods/show_failed_snackbar.dart';

import '../enums/http_reponse_status.dart';
import '../localization/localization_methods.dart';
import '../models/failure_model.dart';


/// check the error type of the http response,
/// and display the error message to user.
///
void checkStatusCode(FailureModel failureModel, BuildContext context){
  switch(failureModel.responseStatus){

    case HttpResponseStatus.noInternet:
      showFailedSnackBar(getTranslated(context, 'noInternet'));
    case HttpResponseStatus.success:
      showFailedSnackBar(getTranslated(context, 'otpSend'));
    case HttpResponseStatus.unAuthorized:
      showFailedSnackBar(getTranslated(context, 'failed'));
    case HttpResponseStatus.invalidData:
      showFailedSnackBar(failureModel.message!);
    case HttpResponseStatus.failure:
      showFailedSnackBar(getTranslated(context, 'failed'));
  }
}