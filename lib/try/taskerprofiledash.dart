import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perwork/screens/costumer/homescreen.dart';
import 'package:perwork/screens/userbooking.dart';
import 'package:perwork/screens/work/bookingihavetodo.dart';

import '../api/apis.dart';
import '../screens/tasker/paymentsscreen.dart';




class TaskerEventMainPage extends StatefulWidget {
  final int bookingCount;
  const TaskerEventMainPage({Key? key,required this.bookingCount}) : super(key: key);

  @override
  State<TaskerEventMainPage> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<TaskerEventMainPage> {
  double walletamount = 0;

  void getdate() {
    FirebaseFirestore.instance.collection('prof').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {

        walletamount = snapshot['walletamount'] ?? 0;

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

    double mqHeight = MediaQuery.of(context).size.height;
    double mqWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(left: 15,right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>   BookingIHaveToDo()),
              );

            },
            child: Container(

                width: mqWidth*0.45,
                decoration: BoxDecoration(
                  color: const Color(0xff2c21ab).withOpacity(1),
                  borderRadius: BorderRadius.all( Radius.circular(43.0)),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20,top: 33),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all( Radius.circular(30.0)),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Text("${widget.bookingCount}+",
                              style: TextStyle(
                                color: const Color(0xff59b37d),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.none,

                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20,top: 10),
                          child: Text("Upcoming Booking",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: mqWidth*0.072,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,

                            ),
                          ),
                        ),
                        SizedBox(height: 10,)
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 110,top: 20),
                      child: Image.network("https://cdn-icons-png.flaticon.com/512/616/616490.png"
                        ,height: 40,width: 40,),
                    )
                  ],
                )
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>   PaymentsScreen()),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,

                  ),
                ),
                Row(
                  children: [
                    Text("Balance",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,

                      ),
                    ),
                    Image.asset('assets/down.png',height: 30,)

                  ],
                ),
                SizedBox(height: 10,),
                Container(
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
                        Text(walletamount.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w500
                        ),)
                      ],
                    )
                  ),
                ),
              ],
            ),
          )
        ],
      ),


    );
  }
}
