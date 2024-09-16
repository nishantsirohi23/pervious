import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/apis.dart';
import '../../try/swithch.dart';

class RequestPayment extends StatefulWidget {
  final String type;
  final String fid;
  final String amount;
  const RequestPayment({Key? key,required this.type,required this.fid,required this.amount}) : super(key: key);

  @override
  State<RequestPayment> createState() => _RequestPaymentState();
}

class _RequestPaymentState extends State<RequestPayment> {
  @override
  Widget build(BuildContext context) {
    Future<void> takecash(double amount) async {
      try {
        CollectionReference users = FirebaseFirestore.instance.collection(
            'prof');

        // Update data in Firestore
        await users.doc(APIs.me.id).update({
          'walletamount': FieldValue.increment(-amount.toInt()),
        });
        CollectionReference paymentcollection = FirebaseFirestore.instance
            .collection('prof');
        await paymentcollection
            .doc(APIs.me.id)
            .collection('payment')
            .add({
          'add': false,
          'payable':amount.toInt(),
          'finalamount':amount.toInt(),
          'workID': widget.fid,
          'workname': "Cash from Worker",
          'type': "Cash",
          'time':DateTime.now()
        });

        await APIs.getSelfInfo();
      }
      catch (e) {
        print("error");
        print(e);
      }
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Payment"),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              GestureDetector(
                onTap: (){

                },
                child: Container(
                  width: 140,
                  height: 90,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/rupee.png",height: 50,width: 50,),
                          Text(widget.amount.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.w500
                            ),)
                        ],
                      )
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15,right: 15),
                padding: EdgeInsets.only(left: 5,right: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300,width: 1),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: PickedUpItemSwitch(
                  text: 'Cash Payment Done',
                  onSwitchChanged: (value) {
                    if(value){
                      print('Switch is on');
                      takecash(double.parse(widget.amount));
                      if(widget.type=='work'){
                        APIs.makePayment(widget.fid,'cash');
                      }
                      else if(widget.type=='food'){
                        APIs.makefoodPayment(widget.fid,'cash');
                      }
                      else{
                        APIs.makeBookingPayment(widget.fid,'cash');
                      }

                    }
                    // Your function call here

                  },
                ),
              ),

              SizedBox(height: 20,),


            ],
          )
      ),
    );
  }
}
