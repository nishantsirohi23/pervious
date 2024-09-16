
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:perwork/api/apis.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:perwork/screens/super/super2.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SuperScreen1 extends StatefulWidget {
  const SuperScreen1({Key? key}) : super(key: key);

  @override
  State<SuperScreen1> createState() => _SuperScreen1State();
}

class _SuperScreen1State extends State<SuperScreen1> {
  int selectedContainerIndex = 2;
  late Razorpay _razorpay;
  bool usepoints = false;
  @override
  void initState() {
    super.initState();
    // Initialize the Future to fetch the work details
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);


  }
  bool _isPaymentInProgress = false;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {
      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    int months= 0;
    if(selectedContainerIndex==0){
      months =1;

    }
    else if(selectedContainerIndex==1){
      months =2;

    }
    else{
      months =3;
    }
    APIs.deletesuperpoints();
    APIs.BuySuper(months);
    APIs.getSelfInfo();

    MotionToast.success(
      title:  const Text("Payment Successful"),
      description:  const Text("You Successfully unlocked Super Genie"),
    ).show(context);
    Navigator.pop(context);  // Show the dialog

  }


  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    MotionToast.error(
      title:  const Text("Payment Failed"),
      description:  const Text("You Failed to unlock Super Genie"),
    ).show(context);


  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response);
    setState(() {
      _isPaymentInProgress = false; // Payment completed (via external wallet), so set the flag to false
    });
  }

  void _openCheckout(int amount) {
    var options = {
      'key': 'rzp_live_ymUGpkKEgzMtUI',

      'amount': amount * 100, // amount in the smallest currency sub-unit
      'name': 'PerPenny',
      'description': "",
      'prefill': {
        'contact': '9000090000',
        'email': 'gaurav.kumar@example.com'
      }
    };
    try {
      setState(() {
        _isPaymentInProgress = true; // Payment process started, so set the flag to true
      });
      // Show loading indicator

      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isPaymentInProgress = false; // Payment process failed, so set the flag to false
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
  int costonemonth  = 99;
  int originalCostOneMonth =99;
  int costtwomonth  = 189;
  int originalCostTwoMonth  = 189;

  int costthreemonth  = 249;
  int originalCostThreeMonth  = 249;


  void usersuperpoints() {
    setState(() {
      print("fiunction called");
      usepoints = !usepoints;
      if (usepoints) {
        print("true called");
        int discount = APIs.me.points ~/ 100;

        costonemonth -= discount;
        costtwomonth -= discount;
        costthreemonth -= discount;
      } else {
        print("false called");
        // Restore original costs if discount is not used
        // You need to define the original costs or fetch them from somewhere
        // For demonstration, let's assume original costs are stored in variables originalCostOneMonth, originalCostTwoMonth, originalCostThreeMonth
        costonemonth = originalCostOneMonth;
        costtwomonth = originalCostTwoMonth;
        costthreemonth = originalCostThreeMonth;
      }
    });
  }

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
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/supermainback.png'),
            fit: BoxFit.cover
          )
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0,),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: screenHeight*0.12),
                  width: screenWidth * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Get",
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
                        "Genie",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.05,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  "Enjoy 25% off on platform fees and best Professionals",
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.019,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSubscriptionContainer(screenWidth, "1", costonemonth.toString(), "199", 0),
                    _buildSubscriptionContainer(screenWidth, "2", costtwomonth.toString(), "289", 1),
                    _buildSubscriptionContainer(screenWidth, "3", costthreemonth.toString(), "399", 2),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: screenHeight*0.06,),
                    Text(
                      "Start your First Plan Now",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * 0.021,
                      ),
                    ),
                    SizedBox(height: 10,),

                    GestureDetector(
                      onTap: () {
                        if(selectedContainerIndex==0){
                          _openCheckout(costonemonth);
                        }
                        else if (selectedContainerIndex==1){
                          _openCheckout(costtwomonth);
                        }
                        else{
                          _openCheckout(costthreemonth);
                        }
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/backofwork.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Center(
                          child: Text(
                            'Buy Super Genie',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 21,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight*0.06),

                    Text(
                      "Explore all other features",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * 0.021,
                      ),
                    ),

                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>   SuperScreen2()),
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
                            Icons.arrow_forward,
                            color: Colors.pink,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
             Positioned(
               top: 60,
                 right: 10,
                 child: GestureDetector(
                   onTap: (){
                   },
                   child: Container(
                       padding: EdgeInsets.all(6),
                       decoration: BoxDecoration(
                           border: Border.all(color: usepoints ? Color(0xFF5ca5d8): Colors.transparent,width: 2),
                           color: Color(0xFF16161D),
                           borderRadius: BorderRadius.all(Radius.circular(10))
                       ),
                       child: GestureDetector(
                         onTap: (){
                           usersuperpoints();

                         },
                         child: Column(
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 Image.asset("assets/reward.png",height: 30,width: 30,),
                                 SizedBox(width: 5,),
                                 Text("Use Points : "+APIs.me.points.toString(),
                                   style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 18
                                   ),)
                               ],
                             ),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [

                                 Text("Use Discount : ₹"+(APIs.me.points ~/ 100).toString(),
                                   style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 18
                                   ),)
                               ],
                             ),
                           ],
                         ),
                       )

                   ),
                 )
             )
          ],
        )
      ),
    );
  }

  Widget _buildSubscriptionContainer(double screenWidth, String duration, String price, String old, int index) {
    bool isSelected = selectedContainerIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedContainerIndex = index;
        });
      },
      child: Container(
        width: screenWidth * 0.28,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Color(0xFF5ca5d8): Colors.transparent,width: 2),
          borderRadius: BorderRadius.circular(10.0),
          color: isSelected ? Color(0xFF16161D) : Color(0xFFf8e6b4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              duration,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 25.0,
              ),
            ),
            Text(
              "months",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 10.0),
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text(
                    "₹$old",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Divider(
                    color: isSelected ? Colors.blue : Colors.pink,
                    thickness: 2,
                    indent: 15,
                    endIndent: 15,
                  ),
                )
              ],
            ),
            Text(
              "₹$price",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
