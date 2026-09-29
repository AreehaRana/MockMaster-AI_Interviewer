import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mockmaster/data/repositories/user/user_repository.dart';
import 'package:mockmaster/features/authentication/screens/login/login.dart';
import 'package:mockmaster/features/authentication/screens/onboarding.dart';
import 'package:mockmaster/features/authentication/screens/signup/verify_email.dart';
import 'package:mockmaster/features/home/screens/home_screen.dart';
import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/utils/exceptions/auth_exception.dart';
import 'package:mockmaster/utils/exceptions/firebase_exceptions.dart';
import 'package:mockmaster/utils/exceptions/format_exceptions.dart';
import 'package:mockmaster/utils/exceptions/platform_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  /// Called from main.dart on app launch
  @override
  void onReady() {
    try {
      FlutterNativeSplash.remove();
    } catch (e) {
      debugPrint('Splash remove failed: $e');
    }

    screenRedirect();

    super.onReady();
  }

  /// Function to show relevant screen
  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      // Refresh the cached user object so emailVerified is accurate,
      // not stale from a previous session.
      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        /// Already logged in and verified -> go straight to the dashboard
        Get.offAll(() => const HomeScreen());
      } else {
        /// Logged in but not verified -> back to the verify-email screen
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
      return;
    }

    /// No user signed in -> decide between OnBoarding and Login
    deviceStorage.writeIfNull('IsFirstTime', true);
    final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;

    if (isFirstTime) {
      /// Redirect to OnBoarding Screen if it's the first time
      Get.offAll(() => OnBoardingScreen());
    } else {
      /// Redirect to Login Screen if it's not the first time
      Get.offAll(() => const LoginScreen());
    }
  }

  // ============================================================
  //                    EMAIL & PASSWORD SIGN-IN
  // ============================================================

  /// [EmailAuthentication] - Sign In
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw MAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MFormatException();
    } on PlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailVerification] - SEND EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw MAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MFormatException();
    } on PlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Register
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw MAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MFormatException();
    } on PlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw MAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MFormatException();
    } on PlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // ============================================================
  //                    GOOGLE SIGN-IN
  // ============================================================

  /// [GoogleAuthentication] - Sign in with Google, the traditional flow:
  /// account picker -> Google tokens -> Firebase credential -> Firebase
  /// sign-in. If this is the very first time this Google account has
  /// signed in, a Firestore user record is created automatically (same
  /// shape as the email/password signup flow), so Google users show up
  /// in "Users" just like everyone else.
  ///
  /// Returns null (not an error) if the user closes the account picker
  /// without choosing an account.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // STEP 1: let the user pick/confirm their Google account.
      // NOTE: google_sign_in's API changed shape between major versions
      // (v6's GoogleSignIn().signIn() vs v7+'s GoogleSignIn.instance /
      // .authenticate()). This is written for the v6.x API -- if it
      // doesn't compile, check which major version pub resolved and
      // match its README example.
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the picker -- not an error, just abort quietly.
        return null;
      }

      // STEP 2: exchange the Google account for auth tokens.
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // STEP 3: sign in to Firebase Authentication with that credential.
      final userCredential = await _auth.signInWithCredential(credential);

      // STEP 4: brand-new Google account -> create its Firestore user
      // record, the same way registerWithEmailAndPassword's caller does.
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final fbUser = userCredential.user!;
        final nameParts = (fbUser.displayName ?? '').trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        final email = fbUser.email ?? '';
        final username =
            email.contains('@') ? email.split('@').first : fbUser.uid;

        final newUser = UserModel(
          id: fbUser.uid,
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          phoneNumber: '',
        );

        final userRepository = Get.put(UserRepository());
        await userRepository.saveUserRecord(newUser);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw MAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MFormatException();
    } on PlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [LogoutUser] - Valid for any authentication method.
  Future<void> logout() async {
    // Google sign-out is best-effort only. On web (or if the Google
    // Sign-In plugin isn't fully configured -- e.g. no client ID meta
    // tag), calling GoogleSignIn().isSignedIn()/.signOut() can throw
    // even for users who never signed in with Google (email/password
    // users, for example). That shouldn't block the actual Firebase
    // sign-out below, so any failure here is swallowed silently.
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('Google sign-out skipped: $e');
    }

    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw MAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MFormatException();
    } on PlatformException catch (e) {
      throw MPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [DeleteUser] - Remove user Auth and Firestore Account.
}