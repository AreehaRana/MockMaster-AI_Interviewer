import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/utils/local_storage/storage_utility.dart';

/// Keeps track of the signed-in user so screens like the Dashboard/Drawer
/// can display a personalized greeting.
///
/// Source of truth is Firestore (`Users/{uid}`). Local storage (GetStorage)
/// is only used as an instant fallback so the UI isn't blank while the
/// Firestore fetch is in flight.
class UserController
    extends
        GetxController {
  static UserController
  get instance =>
      Get.find();

  static const _storageKey =
      'local_user';

  final Rx<
    UserModel
  >
  user =
      UserModel.empty().obs;

  @override
  void
  onInit() {
    super.onInit();
    _loadFromStorage(); // instant fallback from cache
    fetchUserFromFirestore(); // real data from Firestore
  }

  void
  _loadFromStorage() {
    final stored =
        MLocalStorage().readData<
          Map<
            String,
            dynamic
          >
        >(
          _storageKey,
        );
    if (stored !=
        null) {
      user.value = UserModel(
        id:
            stored['id'] ??
            '',
        firstName:
            stored['firstName'] ??
            '',
        lastName:
            stored['lastName'] ??
            '',
        username:
            stored['username'] ??
            '',
        email:
            stored['email'] ??
            '',
        phoneNumber:
            stored['phoneNumber'] ??
            '',
        role:
            stored['role'] ??
            'user',
      );
    }
  }

  /// Fetches the current user's document from Firestore
  /// (collection: `Users`, doc id: Firebase Auth uid) and updates
  /// the observable + local cache.
  ///
  /// Call this:
  ///  - in onInit() (covers app restart when auth state is already resolved)
  ///  - immediately after a successful login/signup, since onInit() may
  ///    run before FirebaseAuth.instance.currentUser is set
  Future<
    void
  >
  fetchUserFromFirestore() async {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;
    if (uid ==
        null)
      return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(
            'Users',
          )
          .doc(
            uid,
          )
          .get();

      if (!doc.exists)
        return;

      final model = UserModel.fromSnapshot(
        doc,
      );
      user.value = model;
      await _persist(
        model,
      );
    } catch (
      e
    ) {
      // Swallow errors so a Firestore hiccup doesn't crash the app;
      // local-storage fallback (or defaults) will still show.
      // Replace with your logger if you have one, e.g. MLogger.error(e).
    }
  }

  /// Saves a name/email pair as the active user (used e.g. right after
  /// registration, before Firestore data is fetched) and persists it.
  Future<
    void
  >
  saveUser({
    required String
    name,
    required String
    email,
  }) async {
    final parts = UserModel.nameParts(
      name,
    );
    final model = UserModel(
      id: user.value.id,
      firstName: parts.isNotEmpty
          ? parts[0]
          : '',
      lastName:
          parts.length >
              1
          ? parts[1]
          : '',
      username: user.value.username, // don't wipe out a fetched username
      email: email,
      phoneNumber: user.value.phoneNumber,
      role: user.value.role,
    );
    user.value =
        model;
    await _persist(
      model,
    );
  }

  Future<
    void
  >
  _persist(
    UserModel
    model,
  ) async {
    await MLocalStorage().saveData(
      _storageKey,
      {
        'id': model.id,
        'firstName': model.firstName,
        'lastName': model.lastName,
        'username': model.username,
        'email': model.email,
        'phoneNumber': model.phoneNumber,
        'role': model.role,
      },
    );
  }

  Future<
    void
  >
  clearUser() async {
    user.value =
        UserModel.empty();
    await MLocalStorage().removeData(
      _storageKey,
    );
  }

  /// Best display name for greetings: prefers the Firestore username,
  /// falls back to full name, then email prefix, then "Guest".
  String
  get displayName {
    if (user.value.username.trim().isNotEmpty) {
      return user.value.username.trim();
    }
    if (user.value.firstName.trim().isNotEmpty) {
      return user.value.fullName.trim();
    }
    if (user.value.email.trim().isNotEmpty) {
      return user.value.email
          .split(
            '@',
          )
          .first;
    }
    return 'Guest';
  }
}
