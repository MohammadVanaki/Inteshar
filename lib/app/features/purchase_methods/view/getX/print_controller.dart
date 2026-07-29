import 'dart:io';
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

  // Check and request Bluetooth permissions, then turn it on if needed (with timeout)
  Future<void> checkAndRequestBluetooth() async {
    BluetoothAdapterState adapterState = BluetoothAdapterState.off;
    try {
      adapterState = await FlutterBluePlus.adapterState.first
          .timeout(const Duration(seconds: 2), onTimeout: () => BluetoothAdapterState.unknown);
    } catch (_) {}

    if (adapterState != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await Permission.bluetoothConnect.request();
        await Permission.bluetoothScan.request();
        try {
          await FlutterBluePlus.turnOn();
        } catch (_) {}
      } else if (Platform.isIOS) {
        await Permission.bluetooth.request();
      }

      int retries = 0;
      while (adapterState != BluetoothAdapterState.on && retries < 10) {
        await Future.delayed(const Duration(seconds: 1));
        try {
          adapterState = await FlutterBluePlus.adapterState.first
              .timeout(const Duration(seconds: 1), onTimeout: () => adapterState);
        } catch (_) {}
        retries++;
      }

      if (adapterState == BluetoothAdapterState.on) {
        Get.closeAllSnackbars();
        Get.snackbar("نجاح", "تم تشغيل البلوتوث بنجاح.");
        await tryAutoConnectPrinter();
      }
    } else {
      startScan();
    }
  }

  // Start scanning for available Bluetooth devices
  void startScan() async {
    try {
      isLoading.value = true;
      devicesList.clear();

      if (Platform.isIOS) {
        isLoading.value = false;
        Get.closeAllSnackbars();
        Get.snackbar(
          "معلومات",
          "طباعة البلوتوث المباشرة متوفرة عبر جهاز POS أو سیستم‌عامل اندرويد.",
        );
        return;
      }

      final List<BluetoothInfo> listResult =
          await PrintBluetoothThermal.pairedBluetooths;

      if (listResult.isNotEmpty) {
        devicesList.value = listResult.map((device) {
          return BluetoothDeviceInfo(
            name: device.name,
            macAddress: device.macAdress,
          );
        }).toList();
      }

      isLoading.value = false;

      if (devicesList.isNotEmpty) {
        Get.closeAllSnackbars();
        Get.snackbar("تم العثور على أجهزة",
            "تم العثور على ${devicesList.length} أجهزة.");
      }
    } catch (e) {
      isLoading.value = false;
      print("Error in startScan: $e");
    }
  }

  Future<void> tryAutoConnectPrinter() async {
    if (isLoading.value || isConnected.value || Platform.isIOS) {
      return;
    }

    final savedPrinter = Constants.localStorage.read('printAddres');

    if (savedPrinter != null &&
        savedPrinter['macAddress'] != null &&
        savedPrinter['name'] != null) {
      final String macAddress = savedPrinter['macAddress'];
      final String advName = savedPrinter['name'];

      BluetoothAdapterState adapterState = BluetoothAdapterState.off;
      try {
        adapterState = await FlutterBluePlus.adapterState.first
            .timeout(const Duration(seconds: 2), onTimeout: () => BluetoothAdapterState.unknown);
      } catch (_) {}

      if (adapterState != BluetoothAdapterState.on) {
        print("🔴 بلوتوث روشن نیست.");
        await checkAndRequestBluetooth();
        return;
      }

      try {
        await connectToDevice(macAddress, advName, isAutoConnect: true);
      } catch (e) {
        print("❌ خطا در اتصال خودکار: $e");
      }
    } else {
      print(
          "ℹ️ اطلاعات پرینتر ذخیره‌شده وجود ندارد. در حال بررسی پرینتر داخلی دستگاه پوز...");
      try {
        final List<BluetoothInfo> paired =
            await PrintBluetoothThermal.pairedBluetooths;
        BluetoothInfo? internalPrinter;
        for (var dev in paired) {
          final info =
              BluetoothDeviceInfo(name: dev.name, macAddress: dev.macAdress);
          if (info.isInternalPrinter) {
            internalPrinter = dev;
            break;
          }
        }

        if (internalPrinter != null) {
          print("⚡ پرینتر داخلی دستگاه پوز کشف شد: ${internalPrinter.name}");
          await connectToDevice(internalPrinter.macAdress, internalPrinter.name,
              isAutoConnect: true);
        }
      } catch (e) {
        print("خطا در شناسایی خودکار پرینتر داخلی: $e");
      }
    }
  }

  // Connect to a specific Bluetooth device with stale socket cleanup & warm-up delay
  Future<bool> connectToDevice(String remoteId, String advName,
      {bool isAutoConnect = false}) async {
    if (isLoading.value) return false;
    if (Platform.isIOS) {
      if (!isAutoConnect) {
        Get.closeAllSnackbars();
        Get.snackbar("معلومات", "طباعة البلوتوث المباشرة متوفرة لأجهزة أندرويد فقط.");
      }
      return false;
    }
    try {
      isLoading.value = true;

      // Disconnect any stale native socket first
      await PrintBluetoothThermal.disconnect;
      await Future.delayed(const Duration(milliseconds: 300));

      bool connected =
          await PrintBluetoothThermal.connect(macPrinterAddress: remoteId);

      if (connected) {
        // Wait 1 second for RFCOMM socket stream handshake to stabilize
        await Future.delayed(const Duration(milliseconds: 1000));

        Constants.localStorage.write('printAddres', {
          'macAddress': remoteId,
          'name': advName,
        });
        deviceName.value = advName;
        isConnected.value = true;
        print("✅ اتصال موفق بود به: $advName");

        if (!isAutoConnect) {
          Get.closeAllSnackbars();
          Get.snackbar("تم الاتصال", "تم الاتصال بـ $advName بنجاح.");
        }
        return true;
      } else {
        isConnected.value = false;
        print("❌ اتصال ناموفق بود.");

        if (!isAutoConnect) {
          Get.closeAllSnackbars();
          Get.snackbar(
            "فشل الاتصال",
            "تعذر الاتصال بالطابعة. تأكد من تشغيل الجهاز وأن البلوتوث يعمل بشكل صحيح.",
          );
        }
        return false;
      }
    } catch (e) {
      isConnected.value = false;
      print("❌ خطا در اتصال: $e");

      if (!isAutoConnect) {
        Get.closeAllSnackbars();
        Get.snackbar("خطأ", "حدث خطأ أثناء الاتصال بالپرينتر.");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Disconnect from the current Bluetooth device (Native disconnect + State reset)
  Future<void> disconnectDevice() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      print("خطا در قطع اتصال: $e");
    }
    Constants.localStorage.remove('printAddres');
    isConnected.value = false;
    deviceName.value = '';
  }
}

class BluetoothDeviceInfo {
  final String name;
  final String macAddress;

  BluetoothDeviceInfo({
    required this.name,
    required this.macAddress,
  });

  // Check if device is an internal POS thermal printer (Sunmi, Pax, iMin, Urovo, etc.)
  bool get isInternalPrinter {
    final lower = name.toLowerCase();
    return lower.contains('inner') ||
        lower.contains('builtin') ||
        lower.contains('smartpos') ||
        lower.contains('spos') ||
        lower.contains('sunmi') ||
        lower.contains('pax') ||
        lower.contains('imin') ||
        lower.contains('urovo') ||
        lower.contains('nexgo');
  }

  // Check if device name matches known thermal printer patterns
  bool get isPrinter {
    final lower = name.toLowerCase();
    return isInternalPrinter ||
        lower.contains('print') ||
        lower.contains('pos') ||
        lower.contains('thermal') ||
        lower.contains('mpt') ||
        lower.contains('rpp') ||
        lower.contains('zj') ||
        lower.contains('xp') ||
        lower.contains('btp') ||
        lower.contains('gooj') ||
        lower.contains('qs') ||
        lower.contains('epson') ||
        lower.contains('bixolon') ||
        lower.contains('zebra') ||
        lower.contains('star') ||
        lower.contains('citizen') ||
        lower.contains('hoin') ||
        lower.contains('d4');
  }

  // متدی برای تبدیل به BluetoothDevice
  BluetoothDevice toBluetoothDevice() {
    return BluetoothDevice(
      remoteId: DeviceIdentifier(macAddress),
    );
  }
}
