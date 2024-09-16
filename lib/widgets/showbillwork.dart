import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../screens/BookingTicket.dart';

class ShowBillWork extends StatefulWidget {
  final String finalworkeramount;
  final String gst;
  final String platformfee;
  final String grandtotal;


  const ShowBillWork({Key? key,required this.platformfee,required this.gst,required this.finalworkeramount,required this.grandtotal,}) : super(key: key);

  @override
  State<ShowBillWork> createState() => _ShowBillState();
}

class _ShowBillState extends State<ShowBillWork> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("Bill Details:",
            style: TextStyle(
                color: Colors.pink,
                fontSize: MediaQuery.of(context).size.height*0.025
            ),),
          SizedBox(height: 8,),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order Amount",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height*0.021
                      ),),
                    Text("Rs. "+widget.finalworkeramount.toString(),
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: MediaQuery.of(context).size.height*0.021
                      ),),
                  ],
                ),
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 10),
                  painter: DashedLinePainter(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Platform Fee",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height*0.019
                      ),),
                    Text("Rs. "+widget.platformfee.toString(),
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: MediaQuery.of(context).size.height*0.019
                      ),),
                  ],
                ),
                Visibility(
                  visible: APIs.me.havepremium,
                  child: Container(
                    child: Text("You got 25% off on platform fees",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7)
                      ),),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("GST",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height*0.019
                      ),),
                    Text("Rs. "+widget.gst.toString(),
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: MediaQuery.of(context).size.height*0.019
                      ),),
                  ],
                ),


                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 10),
                  painter: DashedLinePainter(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height*0.021
                      ),),
                    Text("Rs. "+widget.grandtotal.toString(),
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: MediaQuery.of(context).size.height*0.021
                      ),),
                  ],
                ),


              ],
            ),
            // Add child widgets here if needed
          ),
          SizedBox(height: 5,),


        ],
      ),
    );
  }
}
