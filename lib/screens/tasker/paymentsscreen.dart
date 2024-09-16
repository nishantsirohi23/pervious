import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/tasker/withdrawscreen.dart';

import '../../api/apis.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  double walletaount = 0;

  void getdate() {
    FirebaseFirestore.instance.collection('prof').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        walletaount = snapshot['walletamount'] ?? 0;

      });
    });
  }
  @override
  void initState() {
    super.initState();
    getdate();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Payments'),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/rupee.png",width: 40,height: 40,),
                        Text(walletaount.toString(),style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500
                        ),)
                      ],
                    ),
                  ),

                  GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>   WithdrawScreen()),
                        );
                      },
                      child:Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Colors.pink,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Withdraw -",style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('prof')
                  .doc(APIs.me.id)
                  .collection('payment')
                  .orderBy('time',descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>> payments = snapshot.data!.docs.map((doc) => doc.data()).toList();
                  return ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> payment = payments[index];
                      bool add = payment['add'] ?? false;
                      String name = payment['workname'] ?? '';
                      String type = payment['type'] ?? '';
                      int amount = payment['payable'] ?? 0;
                      DateTime dateTime = payment['time'].toDate();
                      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                      Color backgroundColor = add ? Colors.green : Colors.red;

                      return Container(
                        height: 85,
                        padding: EdgeInsets.only(left: 9, right: 9),
                        margin: EdgeInsets.only(left: 12, right: 12,bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Visibility(
                                  visible: add,
                                  child: Image.asset("assets/plus.png", height: 45, width: 45),
                                ),
                                Visibility(
                                  visible: !add,
                                  child: Image.asset("assets/minus.png", height: 45, width: 45),
                                ),
                              ],
                            ),
                            SizedBox(width: 9,),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align text at the start
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )),
                            Row(
                              children: [
                                Text(
                                  "₹" + amount.toString(),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Image.asset("assets/rupee.png", height: 30, width: 30),
                              ],
                            )
                          ],
                        ),
                      )
                      ;
                    },
                  );
                } else {
                  return Center(
                    child: Text('No payments found'),
                  );
                }
              },
            ))
          ],
        )
    );

  }
}
