import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perwork/screens/super/super1.dart';

class SuperScreen2 extends StatefulWidget {
  const SuperScreen2({Key? key}) : super(key: key);

  @override
  State<SuperScreen2> createState() => _SuperScreen1State();
}

class _SuperScreen1State extends State<SuperScreen2> {
  int selectedContainerIndex = -1;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>   SuperScreen1()),
              );
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/supermainback1.png'),
                fit: BoxFit.cover
            )
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              margin: EdgeInsets.only(top: screenHeight*0.12),
              width: screenWidth * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Why",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.05,
                    ),
                  ),
                  Text(
                    "Supreme",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.05,
                    ),
                  ),
                  Text(
                    "Genie?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.05,
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildthreefeatures("assets/superdiscount.png","Platform Fee Discount","Premium users get 25% off platform fees, saving on every transaction while accessing top professionals"),
                SizedBox(height: 20,),
                _buildthreefeatures("assets/verify.png","Confirmed Bookings","Premium subscribers enjoy priority booking confirmation for seamless and efficient service"),
                SizedBox(height: 20,),
                _buildthreefeatures("assets/superbest.png","Access to Top Professionals","Premium members get exclusive access to PerPenny's top-rated professionals for high-quality service and expertise."),


              ],
            ),
            SizedBox(height: screenHeight*0.1,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  "Unlock Super Genie",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.021,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>   SuperScreen1()),
                    );
                  },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        "Why Super",
                        style: TextStyle(
                          color: Color(0xFF6aa8d5),
                          fontWeight: FontWeight.w500,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                      Icon(
                        Icons.arrow_back,
                        color: Colors.pink,
                      )
                    ],
                  ),
                ),


              ],
            )

          ],
        ),
      ),
    );
  }

  Widget _buildthreefeatures(String asset,String title,String des){
    return Container(


      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(asset,height: MediaQuery.of(context).size.height*0.06,width: MediaQuery.of(context).size.height*0.06,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                 title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                ),
              ),
              SizedBox(height: 6,),
              Container(
                width: MediaQuery.of(context).size.width*0.74,
                child: Text(
                  des,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.017,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
