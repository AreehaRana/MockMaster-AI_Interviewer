import 'package:get_storage/get_storage.dart';

class MLocalStorage {
  static final MLocalStorage _instance = MLocalStorage._internal();

  factory MLocalStorage() {
    return _instance;
  }

  MLocalStorage._internal();

  final _storage = GetStorage();

  // Generic method to save data
  Future<void> saveData<M>(String key, M value) async {
    await _storage.write(key, value);
  }

  // Generic method to read data
  M? readData<M>(String key) {
    return _storage.read<M>(key);
  }

  // Generic method to remove data
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  // Clear all data in storage
  Future<void> clearAll() async {
    await _storage.erase();
  }
}