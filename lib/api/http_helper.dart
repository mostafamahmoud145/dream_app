import 'dart:convert';

import 'package:http/http.dart' as http;




class HttpHelper {

 static Future<http.Response> postData(
      {required String linkUrl, required Map data, String? token}) async {

        var headers = {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json'
        };

        var response = await http.post(
          Uri.parse(linkUrl),
          body: json.encode(data),
          headers: headers,
        );

        return response;
  }


  // static Either<Failure, Map> checkStatusCode(http.Response response){
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     Map responseBody = jsonDecode(response.body);
  //     return Right(responseBody);
  //
  //   }else if (response.statusCode == 404) {
  //     return Left(ServerFailure(response.statusCode.toString()));
  //
  //   }else if (response.statusCode == 400) {
  //     return Left(ServerFailure(response.statusCode.toString()));
  //
  //   }else if (response.statusCode == 401) {
  //     return Left(ServerFailure(response.statusCode.toString()));
  //
  //   } else {
  //     return Left(ServerFailure(response.statusCode.toString()));
  //   }
  // }


  Future<http.Response> getData(
      {required String linkUrl,
        required String token,
      }) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response = await http.get(Uri.parse(linkUrl), headers: headers);

    return response;
  }



  Future<http.Response> putData(
      {required String linkUrl, required Map data, String? token}) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response =
    await http.put(Uri.parse(linkUrl), body: data, headers: headers);
    return response;
  }



  Future<http.Response> deleteData(
      {required String linkUrl, Map? data, String? token}) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response =
    await http.delete(Uri.parse(linkUrl), body: data, headers: headers);
    return response;
  }


}
