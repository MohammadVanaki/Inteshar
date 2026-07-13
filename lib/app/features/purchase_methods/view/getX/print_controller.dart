import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/status.dart';

class BluetoothController extends GetxController {
  final ScreenshotController screenshotController = ScreenshotController();
  RxList devicesList = [].obs;
  RxBool isConnected = false.obs;
  RxBool isLoading = false.obs;
  RxBool printed = false.obs;
  RxInt printCount = 1.obs;
  RxString deviceName = ''.obs;
  var rxRequestStatus = Status.initial.obs;

  @override
  void onInit() {
    super.onInit();
    tryAutoConnectPrinter();
  }

  // Check and request Bluetooth permissions, then turn it on if needed
  Future<void> checkAndRequestBluetooth() async {
    BluetoothAdapterState adapterState =
        await FlutterBluePlus.adapterState.first;

    if (adapterState != BluetoothAdapterState.on) {
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();

      FlutterBluePlus.turnOn();

      while (adapterState != BluetoothAdapterState.on) {
        await Future.delayed(const Duration(seconds: 1));
        adapterState = await FlutterBluePlus.adapterState.first;
      }

      Get.closeAllSnackbars();
      Get.snackbar("نجاح", "تم تشغيل البلوتوث بنجاح.");

      // بعد از روشن شدن بلوتوث دوباره تلاش کن برای اتصال
      await tryAutoConnectPrinter();
    } else {
      startScan();
    }
  }

  // Start scanning for available Bluetooth devices
  void startScan() async {
    try {
      isLoading.value = true; // Start loading indicator
      devicesList.clear(); // Clear the previous device list

      // Fetch paired Bluetooth devices
      final List<BluetoothInfo> listResult =
          await PrintBluetoothThermal.pairedBluetooths;

      // Add paired devices to the list
      if (listResult.isNotEmpty) {
        devicesList.value = listResult.map((device) {
          return BluetoothDeviceInfo(
            name: device.name,
            macAddress: device.macAdress,
          );
        }).toList();
      }

      isLoading.value = false; // Stop loading indicator

      // Show a notification based on the scan results
      if (devicesList.isEmpty) {
        // Get.closeAllSnackbars();
        // Get.snackbar(
        //     "لم يتم العثور على أجهزة", "لم يتم العثور على أي جهاز بلوتوث.");
      } else {
        Get.closeAllSnackbars();
        Get.snackbar("تم العثور على أجهزة",
            "تم العثور على ${devicesList.length} أجهزة.");
      }
    } catch (e) {
      isLoading.value = false; // Stop loading indicator on error
      // Get.closeAllSnackbars();
      // Get.snackbar("خطا", "مشکلی در اسکن دستگاه‌های بلوتوث رخ داد: $e");
    }
  }

  Future<void> tryAutoConnectPrinter() async {
    if (isLoading.value || isConnected.value) {
      return;
    }

    final savedPrinter = Constants.localStorage.read('printAddres');

    if (savedPrinter != null &&
        savedPrinter['macAddress'] != null &&
        savedPrinter['name'] != null) {
      final String macAddress = savedPrinter['macAddress'];
      final String advName = savedPrinter['name'];

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print("🔴 بلوتوث روشن نیست.");
        await checkAndRequestBluetooth();
        return;
      }

      final bool isAlreadyConnected =
          await PrintBluetoothThermal.connectionStatus;
      if (isAlreadyConnected) {
        print("✅ قبلاً متصل شده‌ایم.");
        isConnected.value = true;
        deviceName.value = advName;
        return;
      }

      try {
        await connectToDevice(macAddress, advName, isAutoConnect: true);
        print("✅ اتصال خودکار موفق بود.");
      } catch (e) {
        print("❌ خطا در اتصال خودکار: $e");
      }
    } else {
      print("ℹ️ اطلاعات پرینتر ذخیره‌شده وجود ندارد.");
    }
  }

  // Connect to a specific Bluetooth device
  Future<void> connectToDevice(String remoteId, String advName,
      {bool isAutoConnect = false}) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
      if (!connectionStatus) {
        bool connected =
            await PrintBluetoothThermal.connect(macPrinterAddress: remoteId);
        if (!connected) {
          isConnected.value = false;
          return;
        }
      }

      Constants.localStorage.write('printAddres', {
        'macAddress': remoteId,
        'name': advName,
      });
      deviceName.value = advName;
      isConnected.value = true;

      // if (!isAutoConnect) {
      //   Get.closeAllSnackbars();
      //   Get.snackbar("تم الاتصال", "تم الاتصال بـ $advName بنجاح.");
      // }
    } catch (e) {
      isConnected.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Disconnect from the current Bluetooth device
  Future<void> disconnectDevice() async {
    Constants.localStorage.remove('printAddres');
    // Get.closeAllSnackbars();
    // Get.snackbar("تم قطع الاتصال", "تم قطع الاتصال مع الجهاز.");
    isConnected.value = false;
  }
}

class BluetoothDeviceInfo {
  final String name;
  final String macAddress;

  BluetoothDeviceInfo({
    required this.name,
    required this.macAddress,
  });

  // متدی برای تبدیل به BluetoothDevice
  BluetoothDevice toBluetoothDevice() {
    return BluetoothDevice(
      remoteId: DeviceIdentifier(macAddress),
    );
  }
}
