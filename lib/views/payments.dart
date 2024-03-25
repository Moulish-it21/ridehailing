import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taxi/utils/app_colors.dart';
import 'package:taxi/widgets/intro.dart';

import '../controller/authController.dart';
import 'add_payment_card_screen.dart';
import 'add_payments_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String cardNumber = '5555 55555 5555 4444';
  String expiryDate = '12/25';
  String cardHolderName = 'Osama Qureshi';
  String cvvCode = '123';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: Get.width,
        height: Get.height,
        child: Stack(
          children: <Widget>[
            greenIntroWidgetWithoutLogos(title: 'My Card'),

            Positioned(
                top: 120,
                left: 0,
                right: 0,
                bottom: 80,
                child: ListView.builder(
                  shrinkWrap: true,
                    itemBuilder: (ctx,i)=> CreditCardWidget(
                      cardBgColor: Colors.black,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: '',
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                ),itemCount: 10,),
                ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Add new card",style: GoogleFonts.poppins(fontSize: 18,fontWeight: FontWeight.bold,color: AppColors.greenColor),),
                  SizedBox(width: 10,),

                  FloatingActionButton(onPressed: (){
                    Get.to(()=> AddPaymentCardScreen());
                  },child: Icon(Icons.arrow_forward,color: Colors.white,), backgroundColor: AppColors.greenColor,)
                ],
              ),
            )
                  ],
                ),
            ),

        );

  }
}
