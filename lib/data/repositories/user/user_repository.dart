import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/utils/exceptions/firebase_exceptions.dart';
import 'package:mockmaster/utils/exceptions/format_exceptions.dart';
import 'package:mockmaster/utils/exceptions/platform_exceptions.dart';

/// Repository class for user related operations
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data to Firebase
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection('Users').doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on MFormatException {
      throw const MFormatException();
    } on MPlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to fetch user data from Firebase
  Future<UserModel?> fetchUserDetails(String userId) async {
    try {
      final documentSnapshot =
          await _db.collection('Users').doc(userId).get();

      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      }

      return null;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on MFormatException {
      throw const MFormatException();
    } on MPlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update user details
  Future<void> updateUserDetails(UserModel user) async {
    try {
      await _db.collection('Users').doc(user.id).update(user.toJson());
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on MFormatException {
      throw const MFormatException();
    } on MPlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update a single user field
  Future<void> updateSingleField(
    String userId,
    Map<String, dynamic> json,
  ) async {
    try {
      await _db.collection('Users').doc(userId).update(json);
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on MFormatException {
      throw const MFormatException();
    } on MPlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to delete user record
  Future<void> deleteUserRecord(String userId) async {
    try {
      await _db.collection('Users').doc(userId).delete();
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on MFormatException {
      throw const MFormatException();
    } on MPlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}