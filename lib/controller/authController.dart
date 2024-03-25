import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi/views/Drivers/car_registration/car_registration_template.dart';
import 'package:taxi/views/Drivers/profile_setup.dart';
import 'package:taxi/views/home.dart';
import 'package:taxi/views/profile_settings.dart';
import 'package:path/path.dart' as Path;
import 'package:geocoding/geocoding.dart' as geoCoding;

import '../models/userModel/usermodel.dart';



class AuthController extends GetxController {
  String userUid = '';
  var verId = '';
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;


  var isProfileUploading = false.obs;

  bool isLoginAsDriver = false;

  storeUserCard(String number, String expiry, String cvv, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});

    return true;
  }

  phoneAuth(String phone) async {
    try {
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        forceResendingToken: resendTokenId,
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occurred $e");
    }
  }
  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LoggedIn");

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    });
  }


  decideRoute(){
    User? user = FirebaseAuth.instance.currentUser;

    if(user != null){
      //check for user
      FirebaseFirestore.instance.collection('users').doc(user.uid).get()
          .then((value){
        if(isLoginAsDriver) {
          if (value.exists) {
            print("driver home");
          } else {
            Get.to(() => DriverProfileSetup());
          }
        }else {
          if (value.exists) {
            Get.to(() => HomeScreen());
          } else {
            Get.to(() => ProfileSettingScreen());
          }
        }
      });
    }
  }
  uploadImage(File image) async{
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance
        .ref()
        .child('users/$fileName');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) => {
      imageUrl = value
    },
    );
    return imageUrl;
  }

  storeUserInfo(
      File? selectedImage,
      String name,
      String home,
      String business,
      String shop,
      {String url = ''}
      ) async {

    String url_new  = url;

    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url_new,
      'name': name,
      'home_address': home,
      'business_address': business,
      'shopping_address': shop,

    }
    ).then((value) {
      isProfileUploading(false);

      Get.to(() => HomeScreen());
    });
  }

  var MyUser = UserModel().obs;

  getUserInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((event) {
      MyUser.value = UserModel.fromJson(event.data()!);
    });
  }

  storeDriverProfile(
      File? selectedImage,
      String name,
      String email, {
        String url = '',

      }) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url_new,
      'name': name,
      'email': email,
      'isDriver': true
    },SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.off(()=> CarRegistrationTemplate());
    });
  }
  
  Future<bool> uploadCarEntry(Map<String,dynamic> carData)async{
    bool isUploaded = false;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set(carData,SetOptions(merge: true));

    isUploaded = true;

    return isUploaded;
  }

}