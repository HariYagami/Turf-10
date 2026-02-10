import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:TURF_TOWN_/src/services/bluetooth_service.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage>
    with SingleTickerProviderStateMixin {
  bool isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? readCharacteristic;

  final String serviceUUID = "ABCD";
  final String characteristicUUID = "1234";

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _initBluetooth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    connectedDevice?.disconnect();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();

    if (await FlutterBluePlus.isSupported == false) {
      _showSnackBar('Bluetooth not supported by this device', Colors.red);
      return;
    }

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        debugPrint('Bluetooth is ON');
      } else {
        debugPrint('Bluetooth is OFF');
        _showSnackBar('Please turn on Bluetooth', Colors.orange);
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 31) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.location,
          ].request();

          if (statuses.values.any((status) => !status.isGranted)) {
            _showSnackBar('Bluetooth permissions are required', Colors.red);
            return;
          }
        } else {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetooth,
            Permission.location,
          ].request();

          if (statuses.values.any((status) => !status.isGranted)) {
            _showSnackBar('Bluetooth permissions are required', Colors.red);
            return;
          }
        }
      } catch (e) {
        debugPrint('Error requesting permissions: $e');
        _showSnackBar('Error requesting permissions', Colors.red);
      }
    }
  }

  void startSearching() async {
    await _requestPermissions();

    if (Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        debugPrint('Error turning on Bluetooth: $e');
      }
    }

    setState(() {
      isSearching = true;
      scanResults.clear();
    });
    _animationController.repeat();

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            scanResults = results;
          });
        }
      });

      _showSnackBar('Scanning for BLE devices...', Colors.blue);

      await Future.delayed(const Duration(seconds: 15));
      await FlutterBluePlus.stopScan();

      if (mounted) {
        setState(() {
          isSearching = false;
        });
        _animationController.stop();
        _animationController.reset();

        if (scanResults.isEmpty) {
          _showSnackBar(
            'No devices found. Make sure your ESP32 is powered on.',
            Colors.orange,
          );
        } else {
          _showSnackBar(
            'Found ${scanResults.length} device(s). Tap to connect.',
            Colors.green,
          );
        }
      }
    } catch (e) {
      debugPrint('Error during scanning: $e');
      _showSnackBar('Error scanning for devices: $e', Colors.red);
      if (mounted) {
        setState(() {
          isSearching = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

 Future<void> _connectToDevice(BluetoothDevice device) async {
  try {
    _showSnackBar('Connecting to ${device.platformName}...', Colors.blue);

    // Cancel any existing connection attempts
    try {
      await device.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('No previous connection to cancel');
    }

    // Attempt connection with proper timeout and auto-connect disabled
    await device.connect(
      timeout: const Duration(seconds: 15),
      autoConnect: false, // Critical fix for Android
    );

    // Verify connection state before proceeding
    final connectionState = await device.connectionState.first;
    if (connectionState != BluetoothConnectionState.connected) {
      throw Exception('Device not in connected state');
    }

    setState(() {
      connectedDevice = device;
    });

    // ✅ FIXED: Removed duplicate connection listener
    // BleManagerService.initialize() already sets up connection state listening
    // Having two listeners on same stream causes immediate disconnect

    _showSnackBar('Connected! Discovering services...', Colors.green);

    // Request MTU increase
    try {
      await device.requestMtu(512);
      debugPrint('✅ MTU increased to 512');
    } catch (e) {
      debugPrint('⚠️ Could not increase MTU: $e');
    }

    // Small delay before service discovery
    await Future.delayed(const Duration(milliseconds: 500));

    // Discover services
    List<BluetoothService> services = await device.discoverServices();
    debugPrint('Found ${services.length} services');

    bool serviceFound = false;

    for (BluetoothService service in services) {
      debugPrint('Service UUID: ${service.uuid}');

      // Match service UUID (case-insensitive)
      if (service.uuid.toString().toUpperCase().contains(serviceUUID.toUpperCase())) {
        serviceFound = true;
        debugPrint('✅ Target service found!');

        for (BluetoothCharacteristic characteristic in service.characteristics) {
          debugPrint('Characteristic UUID: ${characteristic.uuid}');
          final charUuidStr = characteristic.uuid.toString().toUpperCase();

          // Find write characteristic
          if (charUuidStr.contains("1234")) {
            if (characteristic.properties.write ||
                characteristic.properties.writeWithoutResponse) {
              setState(() {
                writeCharacteristic = characteristic;
              });
              debugPrint('✅ Write characteristic found');
            }
          }

          // Find read/notify characteristic
          if (charUuidStr.contains("5678")) {
            if (characteristic.properties.read ||
                characteristic.properties.notify) {
              setState(() {
                readCharacteristic = characteristic;
              });
              debugPrint('✅ Read characteristic found');
            }
          }
        }

        if (writeCharacteristic != null) {
          debugPrint('╔════════════════════════════════════════╗');
          debugPrint('║  ✅ BLUETOOTH CONNECTION SUCCESSFUL ✅  ║');
          debugPrint('╠════════════════════════════════════════╣');
          debugPrint('║  Device: ${device.platformName.padRight(28)}║');
          debugPrint('║  Status: Ready to receive commands     ║');
          debugPrint('╚════════════════════════════════════════╝');

          _showSnackBar('✅ Connected! Ready to send data', Colors.green);

          // Initialize BLE Manager Service
          BleManagerService().initialize(
            device: device,
            writeCharacteristic: writeCharacteristic!,
            readCharacteristic: readCharacteristic,
            statusCallback: _showSnackBar,
            disconnectCallback: () {
              if (mounted) {
                setState(() {
                  connectedDevice = null;
                  writeCharacteristic = null;
                  readCharacteristic = null;
                });
              }
            },
          );

          return;
        } else {
          throw Exception('Write characteristic not found in service');
        }
      }
    }

    if (!serviceFound) {
      throw Exception('Service UUID $serviceUUID not found on device');
    }

  } on TimeoutException {
    debugPrint('❌ Connection timeout');
    _showSnackBar('Connection timeout - device not responding', Colors.red);
    
    if (mounted) {
      setState(() {
        connectedDevice = null;
        writeCharacteristic = null;
        readCharacteristic = null;
      });
    }
  } catch (e) {
    debugPrint('❌ Error connecting to device: $e');
    
    String errorMessage = 'Connection failed';
    if (e.toString().contains('133')) {
      errorMessage = 'Connection error - try resetting Bluetooth';
    } else if (e.toString().contains('62')) {
      errorMessage = 'Device not accepting connections - check ESP32';
    } else if (e.toString().contains('Service')) {
      errorMessage = 'Service not found - check ESP32 firmware';
    }
    
    _showSnackBar(errorMessage, Colors.red);

    // Clean disconnect on error
    try {
      await device.disconnect();
    } catch (_) {}

    if (mounted) {
      setState(() {
        connectedDevice = null;
        writeCharacteristic = null;
        readCharacteristic = null;
      });
    }
  }
}

  Future<void> _disconnectDevice() async {
    if (connectedDevice == null) return;

    try {
      _showSnackBar('Disconnecting...', Colors.orange);
      
      await BleManagerService().disconnect();

      if (mounted) {
        setState(() {
          connectedDevice = null;
          writeCharacteristic = null;
          readCharacteristic = null;
        });
      }

      _showSnackBar('Device disconnected', Colors.orange);
    } catch (e) {
      debugPrint('Error disconnecting device: $e');
      _showSnackBar('Error disconnecting device', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('esp32') ||
        name.contains('matrix') ||
        name.contains('led')) {
      return Icons.developer_board;
    } else if (name.contains('score') || name.contains('cricket')) {
      return Icons.sports_cricket;
    } else {
      return Icons.bluetooth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A5C), Color(0xFF000000)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Cricket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Scorer',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: isSearching
                    ? RotationTransition(
                        turns: _animation,
                        child: const Icon(
                          Icons.bluetooth_searching,
                          size: 100,
                          color: Colors.blueAccent,
                        ),
                      )
                    : Icon(
                        connectedDevice == null
                            ? Icons.bluetooth_disabled
                            : Icons.bluetooth_connected,
                        size: 100,
                        color: connectedDevice == null
                            ? Colors.grey
                            : Colors.greenAccent,
                      ),
              ),
              Text(
                connectedDevice == null
                    ? (isSearching ? 'Searching...' : 'Not Connected')
                    : 'Connected to ${connectedDevice!.platformName}',
                style: TextStyle(
                  color: connectedDevice == null
                      ? Colors.white70
                      : Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: connectedDevice == null
                      ? (isSearching ? null : startSearching)
                      : _disconnectDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: connectedDevice == null
                        ? Colors.blueAccent
                        : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    connectedDevice == null
                        ? (isSearching ? 'Searching...' : 'Start Scanning')
                        : 'Disconnect',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: scanResults.isEmpty
                    ? const Center(
                        child: Text(
                          'No devices found',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: scanResults.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final result = scanResults[index];
                          final device = result.device;
                          
                          final deviceName = device.platformName.isEmpty
                              ? 'Unknown Device'
                              : device.platformName;

                          return Card(
                            color: const Color(0xFF1E1E2E),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getDeviceIcon(deviceName),
                                color: Colors.blueAccent,
size: 36,
),
title: Text(
deviceName,
style: const TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
subtitle: Text(
device.remoteId.toString(),
style: const TextStyle(
color: Colors.white54,
fontSize: 12,
),
),
trailing: result.rssi != 0
? Container(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 4,
),
decoration: BoxDecoration(
color: Colors.blueAccent.withOpacity(0.2),
borderRadius: BorderRadius.circular(8),
),
child: Text(
'${result.rssi} dBm',
style: const TextStyle(
color: Colors.blueAccent,
fontSize: 12,
),
),
)
: null,
onTap: () => _connectToDevice(device),
),
);
},
),
),
],
),
),
),
);
}
}