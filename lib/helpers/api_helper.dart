import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'constans.dart';

class ApiHelper{
  
  static Future<Response> getProcedures(String token) async{

    var url = Uri.parse('${Constans.apiUrl}/api/Procedures');
    var response = await http.get(
      url, 
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer $token'
      }
    );

    var body = response.body;
    if(response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    List<Procedure> list = [];
    var decodedJson = jsonDecode(body);
    if(decodedJson != null){
      for(var procedure in decodedJson){
        list.add(Procedure.fromJson(procedure));
      }   
    }

    return Response(isSuccess: true, result: list);
  }

  static Future<Response> put(
    String controller, 
    String id, 
    Map<String, dynamic> request, 
    String token) async{

    var url = Uri.parse('${Constans.apiUrl}/api/$controller$id');
    var response = await http.put(
      url, 
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer $token'
      },
      body: jsonEncode(request)
    );

    if(response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static Future<Response> post(
    String controller, 
    Map<String, dynamic> request, 
    String token) async{

    var url = Uri.parse('${Constans.apiUrl}/api/$controller');
    var response = await http.post(
      url, 
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer $token'
      },
      body: jsonEncode(request)
    );

    if(response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static Future<Response> delete(
    String controller, 
    String id, 
    Map<String, dynamic> request, 
    String token) async{

    var url = Uri.parse('${Constans.apiUrl}/api/$controller$id');
    var response = await http.delete(
      url, 
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer $token'
      }
    );

    if(response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }
  
}