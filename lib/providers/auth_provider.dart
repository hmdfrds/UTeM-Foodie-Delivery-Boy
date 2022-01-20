import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/home_screen.dart';

class AuthProvider extends ChangeNotifier {
  File? image;
  bool isPicAvail = false;
  String pickerError = "";
  String error = "";
  String mobile = "";
  String email = "";
  String shopName = "";
  bool loading = false;
  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');
  setEmail(email) {
    this.email = email;
    notifyListeners();
  }

    Future<File?> _cropImage(XFile? img) async {
      File? imageeeeeeeee;
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: img!.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1)
       
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: const IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      imageeeeeeeee = croppedFile;
    } else {
      pickerError = 'No image selected.';
    }
    return imageeeeeeeee;
  }

  Future<File?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
    final croptedFile = await _cropImage(pickedFile);

    if (croptedFile != null) {
      image = File(croptedFile.path);
    } else {
      pickerError = 'No image selected.';
    }
    notifyListeners();
    return image;
  }


  Future<UserCredential?> registerBoys(email, password) async {
    this.email = email;
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      error = e.code;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
    return userCredential;
  }

  Future<UserCredential?> loginBoys(email, password) async {
    this.email = email;
    UserCredential? userCredential;
    try {
      userCredential = await checkUserThenLogin(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.code;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
    return userCredential;
  }

    Future<UserCredential?> checkUserThenLogin(
      String email, String password) async {
    return FirebaseFirestore.instance
        .collection('boys')
        .where('email', isEqualTo: email)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        try {
          return await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
        } catch (e) {
          error = e.toString();
        }
      } else {
        error = 'Looks like you are not a delivery boy!';
      }
    });
  }

  Future<void> resetBoysPassword(email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      error = e.code;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void>? saveBoysDataToDb(
      {String? url, String? name, String? mobile, String? password, context}) {
    User? user = FirebaseAuth.instance.currentUser;

    _boys.doc(email).update({
      'uid': user!.uid,
      'name': name,
      'password': password,
      'mobile': mobile,
      'imageUrl': url,
      'accVerified': false,
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return null;
  }
}
