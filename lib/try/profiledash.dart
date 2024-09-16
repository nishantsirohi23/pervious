import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perwork/screens/costumer/homescreen.dart';
import 'package:perwork/screens/userbooking.dart';




class EventMainPage extends StatefulWidget {
  final int bookingCount;
  const EventMainPage({Key? key,required this.bookingCount}) : super(key: key);

  @override
  State<EventMainPage> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<EventMainPage> {
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
                MaterialPageRoute(builder: (context) =>   UserBooking()),
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
                                fontSize: mqWidth*0.07,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>   CustomerHomeScreen(initialIndex: 4,)),
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
                      Text("Works",
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
                      child:  Stack(
                        children: [
                          Container(
                            width: 54.0,
                            height: 54.0,
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: DecorationImage(
                                image: NetworkImage('https://cdn.dribbble.com/userupload/13205324/file/original-bcf6aab18864b9a505acb74f56551f98.jpg?resize=2048x1556'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all( Radius.circular(50.0)),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 32),
                            width: 54.0,
                            height: 54.0,
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: DecorationImage(
                                image: NetworkImage('https://cdn.dribbble.com/users/928524/screenshots/15505238/media/245dd2bdfe0159997cccda5f230e4cb2.jpg?resize=1600x1200&vertical=center'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all( Radius.circular(50.0)),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 58),
                            width: 54.0,
                            height: 54.0,
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: DecorationImage(
                                image: NetworkImage('https://cdn.dribbble.com/userupload/4524540/file/original-1618c78c064c5c31069694e98fecce07.png?resize=2048x1536&vertical=center'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all( Radius.circular(50.0)),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
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
