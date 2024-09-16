
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as auth;

class PushNotificationService{

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
     
    };
    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging'
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();

    return credentials.accessToken.data;



  }
  static sendNotificationToSelectedDriver(String deviceToken) async {
    final String serverKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/perwork/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "Nishant Sirohi",
          "body": "asdfasdf"
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>
      {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey'
      },
      body: jsonEncode(message),

    );
    if (response.statusCode == 200){
      print("Sasfdas");
    }
    else{
      print("asdfasdfa");
    }
  }

}
