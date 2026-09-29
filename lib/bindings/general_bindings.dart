
import'package:get/get.dart';
import'package:mockmaster/utils/network_manager/network_manager.dart';
class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Register the NetworkManager as a singleton
    Get.put(MNetworkManager());
  }
}