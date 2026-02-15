import 'package:flutter/material.dart';
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
<<<<<<< HEAD
import 'package:TURF_TOWN_/src/CommonParameters/Validators.dart';
=======
>>>>>>> recovered-20260202
import 'package:TURF_TOWN_/src/services/Otp.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isAgreed = false;
<<<<<<< HEAD
  bool _isPhoneValid = false;

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _formKey.currentState?.validate() ?? false;
    });
  }
=======
>>>>>>> recovered-20260202

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      resizeToAvoidBottomInset: false,
=======
>>>>>>> recovered-20260202
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: Appbg1.mainGradient,
            ),
          ),
          Positioned(
<<<<<<< HEAD
            top: 200,
            left: 0,
            right: 0,
            child: Text(
              'Enter your Phone\nNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.3,
=======
            top: 230,
            left: 100,
            child: Text(
              'Enter your Phone \nNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
>>>>>>> recovered-20260202
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
<<<<<<< HEAD
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Color(0xFF00C4FF).withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          prefixText: '+91 ',
                          prefixStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: Color(0xFFC6C3C3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF00C4FF).withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.red.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        validator: PhoneValidator.validate,
                        onChanged: (value) {
                          _validatePhone();
                          if (!_isPhoneValid && _isAgreed) {
                            setState(() {
                              _isAgreed = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: _isAgreed,
                          onChanged: _isPhoneValid
                              ? (value) {
                                  setState(() {
                                    _isAgreed = value ?? false;
                                  });
                                }
                              : null,
                          activeColor: Color(0xFF00C4FF),
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: _isPhoneValid
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'By entering your number, you are agreeing to our Terms of Service & Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isPhoneValid
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: _isAgreed ? 40 : -100,
            right: 30,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isAgreed ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00C4FF).withOpacity(0.3),
                      Color(0xFF0094FF).withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00C4FF).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isAgreed
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpVerification(
                                    phoneNumber: _phoneController.text,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Enter Valid Phone Number')),
                              );
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 28,
=======
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Phone Number',
                    prefixText: '+91 ',
                    filled: true,
                    fillColor: Color(0xFFC6C3C3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: 30,
            right: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _isAgreed,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAgreed = value ?? false;
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Color(0xFF0094FF),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'By entering your number, you\'re agreeing to our Terms of service & Privacy Policy',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
>>>>>>> recovered-20260202
                      ),
                    ),
                  ),
                ),
<<<<<<< HEAD
              ),
            ),
          ),
=======
              ],
            ),
          ),
          Positioned(
            bottom: 55,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isAgreed
                    ? LinearGradient(
                        colors: [
                          Color(0xFF00C4FF).withOpacity(0.3),
                          Color(0xFF0094FF).withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _isAgreed ? null : Colors.grey.withOpacity(0.3),
                boxShadow: _isAgreed
                    ? [
                        BoxShadow(
                          color: Color(0xFF00C4FF).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isAgreed
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerification(
                                phoneNumber: _phoneController.text,
                              ),
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward,
                      color: _isAgreed ? Colors.white : Colors.white54,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          )
>>>>>>> recovered-20260202
        ],
      ),
    );
  }
<<<<<<< HEAD
=======

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
>>>>>>> recovered-20260202
}