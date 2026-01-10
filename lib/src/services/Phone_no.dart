import 'package:flutter/material.dart';
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import 'package:TURF_TOWN_/src/CommonParameters/Validators.dart';
import 'package:TURF_TOWN_/src/services/Otp.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: Appbg1.mainGradient,
            ),
          ),
          Positioned(
            top: 230,
            left: 100,
            child: Text(

              'Enter your Phone \nNumber',
               textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    label: Text('Phone Number'),
                    prefixText: '+91 ',
                    filled: true,
                    fillColor: Color(0xFFC6C3C3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: PhoneValidator.validate,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 10,
            child: Text(
              'By entering your number, you’re\n agreeing to our Terms of service & \nPrivacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 55,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_forward),
              color: Colors.white,
              iconSize: 40.0,
              tooltip: 'Continue',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // ✅ Valid phone number
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>OtpVerification(phoneNumber: _phoneController.text,)));
                  // Navigate or perform next action here
                } else {
                  // ❌ Invalid phone number
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Enter Valid Phone Number')),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}