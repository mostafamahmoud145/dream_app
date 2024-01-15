
import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthenticationServices{






  static Future<void> login(String phoneNumber,String countryCode) async {

    Uri url = Uri.parse('https://apis.dream-app.net/login');
    Map<String, dynamic> data = {
      "username": "uf+#991h0YPh",
      "password": "6*&]j50f]{L!"
    };

    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    http.Response response =
    await http.post(url, body: jsonEncode(data), headers: headers);

    if(response.statusCode==200 || response.statusCode==201){
      String token= jsonDecode(response.body)['token'];
      generateOtp(token,phoneNumber,countryCode);
      print('bbb $token');
    }else{
      /// TODO: handle error here and add try globally.
      /// error: try again.
    }
    print('============res ${response.statusCode}');
    print('============res ${response.body}');
  }



  static void generateOtp(String token,String phoneNumber,String countryCode) async {
    Uri url = Uri.parse('https://apis.dream-app.net/generate-otp');

    Map<String, dynamic> data2 = {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber
    };

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    http.Response response =
    await http.post(url, body: json.encode(data2), headers: headers);

    // setState(() {
    //   load= false;
    // });
    if(response.statusCode==200 || response.statusCode==201){

      // navigateToOtpScreen(token);
      /// otp sent successfully.
      print('otp sent successfully.');
    }else{
      /// TODO: handle error here and add try globally.
      /// error try again.
    }
  }

}
