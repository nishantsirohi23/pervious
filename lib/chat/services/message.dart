import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perwork/api/apis.dart';
import 'package:perwork/onboding/components/custom_sign_in_dialog.dart';

import '../model/message.dart';
import '../model/service_response.dart';
import '../utils/app_util.dart';
import '../utils/constant.dart';

class MessageService {
  MessageService(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;
  final _database = FirebaseFirestore.instance;


  Future<ServiceResponse> sendMessage(String message, String profid) async {

    String collectid = user!.uid.toString() + "_" + profid;
    if(APIs.me.type == 'others'||APIs.me.type=='delivery'){
      collectid = profid + "_" + user!.uid.toString();
    }

    final newMessage = Message(
      userId: firebaseAuth.currentUser!.uid,
      userName: APIs.me.name ?? "N/A",
      message: message.trim(),
      messageType: MessageType.text,
      createdAt: DateTime.now(),
      roomId: collectid,
    );



    try {
      var roomRef = _database.collection(ROOM_COLLECTION).doc(collectid);
      var messageCollectionRef = roomRef.collection(MESSAGE_COLLECTION);

      // Check if the room already exists
      var roomSnapshot = await roomRef.get();
      if (!roomSnapshot.exists) {
        // Room doesn't exist, add the chat ID to the chat_user subcollection for both users
        await _addChatIdToUsers(user!.uid, profid,collectid);
        final CollectionReference collectionReference = FirebaseFirestore.instance.collection('chat');
        final String docId = collectid;

// Add your field inside the document with ID equal to 'docId'
        collectionReference.doc(docId).set({
          profid: FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
        }, SetOptions(merge: true)).then((value) {
          print("Field added successfully!");
        }).catchError((error) {
          print("Failed to add field: $error");
        });
        final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users');
        final String docId1 = profid;

// Add your field inside the document with ID equal to 'docId'
        collectionReference1.doc(docId1).set({
          "nmessage": FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
        }, SetOptions(merge: true)).then((value) {
          print("Field added successfully!");
        }).catchError((error) {
          print("Failed to add field: $error");
        });
      }
      final CollectionReference collectionReference = FirebaseFirestore.instance.collection('chat');
      final String docId = collectid;

// Add your field inside the document with ID equal to 'docId'
      collectionReference.doc(docId).set({
        profid: FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
      }, SetOptions(merge: true)).then((value) {
        print("Field added successfully!");
      }).catchError((error) {
        print("Failed to add field: $error");
      });
      final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users');
      final String docId1 = profid;

// Add your field inside the document with ID equal to 'docId'
      collectionReference1.doc(docId1).set({
        "nmessage": FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
      }, SetOptions(merge: true)).then((value) {
        print("Field added successfully!");
      }).catchError((error) {
        print("Failed to add field: $error");
      });

      // Add the message to the message collection
      await messageCollectionRef.add(newMessage.toJson());

      return ServiceResponse.fromJson({"status": true, "message": "success"});
    } on FirebaseAuthException catch (e) {
      AppUtil.debugPrint(e.message);
      return ServiceResponse.fromJson({"status": false, "message": e.message.toString()});
    }
  }
  Future<ServiceResponse> sendImageMessage(String imageurl, String profid) async {
    String collectid = user!.uid.toString() + "_" + profid;
    if(APIs.me.type == 'others'||APIs.me.type=='delivery'){
      collectid = profid + "_" + user!.uid.toString();
    }
    final newMessage = Message(
      userId: firebaseAuth.currentUser!.uid,
      userName: firebaseAuth.currentUser!.displayName ?? "N/A",
      message: imageurl,
      messageType: MessageType.image,
      createdAt: DateTime.now(),
      roomId: collectid,
    );

    try {
      var roomRef = _database.collection(ROOM_COLLECTION).doc(collectid);
      var messageCollectionRef = roomRef.collection(MESSAGE_COLLECTION);

      // Check if the room already exists
      var roomSnapshot = await roomRef.get();
      if (!roomSnapshot.exists) {
        // Room doesn't exist, add the chat ID to the chat_user subcollection for both users
        await _addChatIdToUsers(user!.uid, profid,collectid);
        final CollectionReference collectionReference = FirebaseFirestore.instance.collection('chat');
        final String docId = collectid;

// Add your field inside the document with ID equal to 'docId'
        collectionReference.doc(docId).set({
          profid: FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
        }, SetOptions(merge: true)).then((value) {
          print("Field added successfully!");
        }).catchError((error) {
          print("Failed to add field: $error");
        });
        final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users');
        final String docId1 = profid;

// Add your field inside the document with ID equal to 'docId'
        collectionReference1.doc(docId1).set({
          "nmessage": FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
        }, SetOptions(merge: true)).then((value) {
          print("Field added successfully!");
        }).catchError((error) {
          print("Failed to add field: $error");
        });
      }
      final CollectionReference collectionReference = FirebaseFirestore.instance.collection('chat');
      final String docId = collectid;

// Add your field inside the document with ID equal to 'docId'
      collectionReference.doc(docId).set({
        profid: FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
      }, SetOptions(merge: true)).then((value) {
        print("Field added successfully!");
      }).catchError((error) {
        print("Failed to add field: $error");
      });
      final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users');
      final String docId1 = profid;

// Add your field inside the document with ID equal to 'docId'
      collectionReference1.doc(docId1).set({
        "nmessage": FieldValue.increment(1), // Replace 'fieldName' and 'fieldValue' with your field name and value
      }, SetOptions(merge: true)).then((value) {
        print("Field added successfully!");
      }).catchError((error) {
        print("Failed to add field: $error");
      });


      // Add the message to the message collection
      await messageCollectionRef.add(newMessage.toJson());

      return ServiceResponse.fromJson({"status": true, "message": "success"});
    } on FirebaseAuthException catch (e) {
      AppUtil.debugPrint(e.message);
      return ServiceResponse.fromJson({"status": false, "message": e.message.toString()});
    }
  }

  Future<void> _addChatIdToUsers(String userId, String profid,String collectid) async {
    final querySnapshot = await _database
        .collection("users")
        .doc(user!.uid)
        .collection("chat_user")
        .where("chatId", isEqualTo: collectid)
        .get();
    APIs.addMessageNotification(profid,ROOM_COLLECTION,profid);


// If no document with the same chatId exists, add the document
    if (querySnapshot.docs.isEmpty) {
      await _database
          .collection("users")
          .doc(user!.uid)
          .collection("chat_user")
          .add({
        "chatId": collectid,
        user!.uid: true,
        profid: false

      });
    } else {
      // Handle the case where the chatId already exists
      print("Document with the same chatId already exists.");
    }
    final querySnapshot2 = await _database
        .collection("users")
        .doc(profid)
        .collection("chat_user")
        .where("chatId", isEqualTo: collectid)
        .get();

// If no document with the same chatId exists, add the document
    if (querySnapshot2.docs.isEmpty) {
      await _database
          .collection("users")
          .doc(profid)
          .collection("chat_user")
          .add({
        "chatId": collectid,
        user!.uid: true,
        profid: false
      });
    } else {
      // Handle the case where the chatId already existsR
      print("Document with the same chatId already exists.");
    }
  }




  Stream<QuerySnapshot> loadStreamMessage(int limit,String  collectid) {
    print(collectid);
    return _database
        .collection(ROOM_COLLECTION)
        .doc(collectid)
        .collection(MESSAGE_COLLECTION)
        .orderBy('createdAt')
        .snapshots();
  }
}
