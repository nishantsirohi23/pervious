import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../api/apis.dart';
import '../work/addbankaccount.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  int walletAmount = 0;
  bool bankAdded = false;

  void getData() {
    FirebaseFirestore.instance.collection('prof').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        walletAmount = snapshot['walletamount'] ?? 0;
        bankAdded = snapshot['bankadded'] ?? false;
      });
    });
  }

  bool isLoading = false;

  void withdrawAmount() {
    // Get the amount entered by the user
    int withdrawalAmount = int.tryParse(_amountController.text) ?? 0;

    // Check if the withdrawal amount is valid
    if (withdrawalAmount <= 0) {
      // Show an error message if the amount is not valid
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid withdrawal amount.'),
      ));
      return;
    }

    // Check if the withdrawal amount is greater than the available wallet amount
    if (withdrawalAmount > walletAmount) {
      // Show an error message if the withdrawal amount exceeds the available balance
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Insufficient balance.'),
      ));
      return;
    }

    // Withdraw the amount here (update Firestore, deduct from wallet, etc.)
    // For now, let's just print the withdrawal amount
    print('Withdrawal Amount: $withdrawalAmount');

    // Call the withdraw amount API
    APIs.withdrawamount(withdrawalAmount);

    // Show payment success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment successful.'),
    ));

    setState(() {
      isLoading = false;
    });

    // Clear the text field after withdrawal
    _amountController.clear();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Withdraw"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/rupee.png", width: 40, height: 40,),
                      Text("Available Amount : ", style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),),
                      Text(walletAmount.toString(), style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),),
                    ],
                  ),
                ),
                Lottie.asset(
                  'assets/lottie/amount.json',
                  width: 250,
                  height: 200,
                  repeat: false,
                ),
                Visibility(
                  visible: !bankAdded,
                  child: GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Image.asset("assets/verify.png", height: 45, width: 45,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>   BankDetailsPage()),
                                    );
                                    // Add functionality to navigate to the page where user can add bank account
                                  },
                                  child: Text(
                                    "Add Bank Account",
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1),
                                Container(
                                  child: Text(
                                    "Please add your bank account details",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    if(bankAdded){
                      setState(() {
                        isLoading = true;
                      });
                      withdrawAmount();
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please add your bank account details.'),
                      ));
                    }

                  },
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Withdraw -", style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Container(
              height: screenHeight * 0.86,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0),
                  child: Center(
                    child: Lottie.asset("assets/lottie/loading.json"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
