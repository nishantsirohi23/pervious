
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as auth;

class PushNotificationService{

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "perwork",
      "private_key_id": "1723ffaa932695fd866def12b47555567b6d3fd4",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDZyQQXo5WvC4KK\nlgwjRd3hm1TqtBnAx+OHd53w1FL+mmu2jKSzl+hYLq6892i5I7+Yyhjtzb1tn44G\na8IGlgfnqO7csd+HeFcJXYeH0iQz79/sPEvOZkHwkQAcA7+VJ5cSurUWo2De0+9J\nAlyXvsr474vTefKcFigV6AzTv46H0vZkqa9kIT3gmknUKBEfoQxOzVT2wyWkVgmh\nZ1WzSyVVz8ncY7B+kFhIXqkorrgpFoCMOlbtGuvQ1pytcPiZKyiGwX1NJjGGfkLa\n+J9Ny3JTFEn0LLkaKwo4IQE2Y5HQ4C2842nS+pMfBGyuafea3YzhlL99REP018Zt\n414rIVLPAgMBAAECggEADRg5j0ROOTardDK+axaF101UJ0KJ893w79HA5NyXWuil\nBlZhhszg8wBnkEQd/1fHauPn6NCAjclUrE0pXuUBd6vgJNPrGUWikhUWE5QOijLn\nl1guxKvAVjsZsxWEnO7C9iTUw5YyOmOq1Qx3zcXyhVI96YrBDCKG6X5I2yh+5Oqt\ncX1MyuFpCK+PRZkzALvdPkzcKUDM48BQqFKiWMmPRKsycSGDTfkLxCmDxI6zGvo8\ng0h7SXq7ykSRp2ARMvr8t+95qT7NRv7W13KMHLuYQH6M8Gyp50dne7I8YDHysHjG\nU5bqxa1CLFR9GzYvff6sVVM6GC7O2upCAbNb7kY/9QKBgQDuv5ut2mq8GNxx1IaN\n4XaKfmhNZMOQsQ7LRgWUPyC7assmjZQdIhT6R/eVRTriQ9Yh0zPUa1u0c1XwGqzX\nW1OxdiY0ZKJVOoxmdjFkbXzZe90f2ph1nI7IBjBp39TX/XueOqhl9z1ujt7OacGH\ntE3Hxali8XwuYvtkaj2ulXrRswKBgQDphaCuiBuqR9ETmE3DsZ6zcAr0yaUCalDd\nUhruamTx4Lkjyj/4vgGSexsao+rgNrJzm7GHerJeLrxqcO/QnX4XRufoB3EE0P0D\nYylK+DvSn1tz1p/nX0BIGbnBPvQlWa4+3J2Lqho/19v7pPOfWMtSo29xgOfyosb7\nRcqs+iyUdQKBgQCpKhLAqJYgGO15qkB8n1hC4TY+QDthdlMpLMAfPmuO4Ch5dK+R\nxOhgPkXq+layo6ZB6Ug8JqWfwmkN65i0Lv2qLDD9xqBPC2EX6H8uzXU9FEqlm1mT\nXA6/I8OCARrqv6yrfJx9QyXABHNShhSedt71wdQ3SyvWIkRF7hEudrPDiQKBgQDi\nPgqMzWUwNmADgf1laUJ+SkDzJCFwE5zAr/lTn1SpWrVETYBo930Cc66wwrqd+6As\njV0UCvWgddsprL1K+irdVl7716nRpsBadcndzl33E1lBA2DsgsX+lJ348YsMXLSK\nRqeEVosT64g/Z3J4oUhridhAuUj/NGFftCBGMiLauQKBgGXePdKIXUctYF+2bpiN\nlKDt++o+eygVm3rB7xiFKZqLXE5BO6eLoOmNmBY8aMKZZ6iWOWg3kEdAPy5NV8CK\ncMsQOBBwnVYDICoaBb6UbPsUxWTOlanbvDZ/UNxLnpnPj6fqcCrlYu2Sq2HA24HX\nqiQTMGFf0oByklj06GLoTnWR\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-7mxj9@perwork.iam.gserviceaccount.com",
      "client_id": "107363919906962387080",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-7mxj9%40perwork.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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