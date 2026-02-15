import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:async';
=======
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'dart:async';
import 'package:TURF_TOWN_/src/Menus/setting.dart';
import 'package:TURF_TOWN_/src/services/bluetooth_service.dart';
>>>>>>> recovered-20260202

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

<<<<<<< HEAD
  final _bluetoothClassicPlugin = BluetoothClassic();
  
  List<Device> pairedDevices = [];
  List<Device> discoveredDevices = [];
  Set<String> connectingDevices = {};
  String? connectedDeviceAddress;

  StreamSubscription<Device>? _scanSubscription;
  StreamSubscription<int>? _connectionSubscription;
=======
  List<ScanResult> scanResults = [];

  final String serviceUUID = "ABCD";
  final String characteristicUUID = "1234";

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // 🔥 NEW: Store connected device ID for highlighting
  String? _connectedDeviceId;
>>>>>>> recovered-20260202

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _initBluetooth();
<<<<<<< HEAD
    _listenToConnectionStatus();
=======

    // 🔥 NEW: Check if already connected on page load
    _checkExistingConnection();
  }
  
  // 🔥 NEW: Check for existing connection when page loads
  void _checkExistingConnection() {
    final bleService = BleManagerService();
    if (bleService.isConnected && bleService.connectedDevice != null) {
      setState(() {
        _connectedDeviceId = bleService.connectedDevice!.remoteId.toString();
      });
    }
>>>>>>> recovered-20260202
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanSubscription?.cancel();
<<<<<<< HEAD
    _connectionSubscription?.cancel();
=======
    _adapterStateSubscription?.cancel();
>>>>>>> recovered-20260202
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
<<<<<<< HEAD
    await _getPairedDevices();
  }

  void _listenToConnectionStatus() {
    _connectionSubscription = _bluetoothClassicPlugin.onDeviceStatusChanged().listen((status) {
      debugPrint('Connection status changed: $status');
      
      if (status == 1) { // Connected
        _showSnackBar('Device connected successfully', Colors.green);
        _getPairedDevices();
      } else if (status == 0) { // Disconnected
        _showSnackBar('Device disconnected', Colors.orange);
        setState(() {
          connectedDeviceAddress = null;
          connectingDevices.clear();
        });
        _getPairedDevices();
=======

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
>>>>>>> recovered-20260202
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
<<<<<<< HEAD
        
        if (androidInfo.version.sdkInt >= 31) {
          // Android 12+
=======

        if (androidInfo.version.sdkInt >= 31) {
>>>>>>> recovered-20260202
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
<<<<<<< HEAD
          // Android 11 and below
=======
>>>>>>> recovered-20260202
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

<<<<<<< HEAD
  Future<void> _getPairedDevices() async {
    try {
      final devices = await _bluetoothClassicPlugin.getPairedDevices();
      
      if (mounted) {
        setState(() {
          pairedDevices = devices;
        });
      }
      
      debugPrint('Found ${devices.length} paired devices');
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      _showSnackBar('Error getting paired devices', Colors.red);
    }
  }

  void startSearching() async {
    await _requestPermissions();

    setState(() {
      isSearching = true;
      discoveredDevices.clear();
=======
  void startSearching() async {
    // 🔥 NEW: Prevent scanning if already connected
    final bleService = BleManagerService();
    if (bleService.isConnected) {
      _showSnackBar('Already connected. Disconnect first to scan again.', Colors.orange);
      return;
    }

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
>>>>>>> recovered-20260202
    });
    _animationController.repeat();

    try {
<<<<<<< HEAD
      // Initialize permissions (this also checks and requests Bluetooth enable)
      await _bluetoothClassicPlugin.initPermissions();

      // Cancel previous subscription if exists
      await _scanSubscription?.cancel();

      // Start discovery
      _scanSubscription = _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (device) {
          if (mounted && device.address != null) {
            setState(() {
              // Avoid duplicates and don't add already paired devices
              if (!discoveredDevices.any((d) => d.address == device.address) &&
                  !pairedDevices.any((d) => d.address == device.address)) {
                discoveredDevices.add(device);
              }
            });
            debugPrint('Discovered device: ${device.name ?? "Unknown"} - ${device.address}');
          }
        },
        onError: (error) {
          debugPrint('Discovery error: $error');
        },
      );

      await _bluetoothClassicPlugin.startScan();
      _showSnackBar('Scanning for devices...', Colors.blue);

      // Scan for 15 seconds
      await Future.delayed(const Duration(seconds: 15));

      await _bluetoothClassicPlugin.stopScan();
=======
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
>>>>>>> recovered-20260202

      if (mounted) {
        setState(() {
          isSearching = false;
        });
        _animationController.stop();
        _animationController.reset();

<<<<<<< HEAD
        if (discoveredDevices.isEmpty) {
          _showSnackBar(
            'No new devices found. Make sure devices are discoverable.',
=======
        if (scanResults.isEmpty) {
          _showSnackBar(
            'No devices found. Make sure your ESP32 is powered on.',
>>>>>>> recovered-20260202
            Colors.orange,
          );
        } else {
          _showSnackBar(
<<<<<<< HEAD
            'Found ${discoveredDevices.length} new device(s). Tap to pair in system settings.',
=======
            'Found ${scanResults.length} device(s). Tap to connect.',
>>>>>>> recovered-20260202
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

<<<<<<< HEAD
  // Open system Bluetooth settings for manual pairing
  Future<void> _openBluetoothSettings(Device device) async {
    try {
      _showSnackBar(
        'Please pair with "${device.name ?? "device"}" in system settings',
        Colors.blue,
      );
      
      // Note: Opening settings requires platform channel implementation
      // For now, we'll just show a dialog with instructions
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A4A),
            title: const Text(
              'Pairing Required',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'To connect to "${device.name ?? "Unknown Device"}", please:\n\n'
              '1. Go to your device\'s Bluetooth settings\n'
              '2. Find and tap on "${device.name ?? "Unknown Device"}"\n'
              '3. Complete the pairing process\n'
              '4. Return to this app and try connecting again',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Color(0xFF00BCD4))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing pairing instructions: $e');
    }
  }

  Future<void> _connectToDevice(Device device) async {
    if (device.address == null) {
      _showSnackBar('Invalid device address', Colors.red);
      return;
    }

    final deviceAddress = device.address!;

    // Check if device is paired first
    final isPaired = pairedDevices.any((d) => d.address == deviceAddress);
    if (!isPaired) {
      _showSnackBar(
        'Device must be paired first. Opening pairing instructions...',
        Colors.orange,
      );
      await _openBluetoothSettings(device);
      return;
    }

    if (connectingDevices.contains(deviceAddress)) {
      _showSnackBar('Already connecting to this device...', Colors.orange);
      return;
    }

    setState(() {
      connectingDevices.add(deviceAddress);
    });

    try {
      _showSnackBar('Connecting to ${device.name ?? "device"}...', Colors.blue);

      // Connect to the device with standard SPP UUID
      await _bluetoothClassicPlugin.connect(
        deviceAddress, 
        "00001101-0000-1000-8000-00805f9b34fb"
      );
      
      debugPrint('Connection successful');

      _showSnackBar(
        'Successfully connected to ${device.name ?? "device"}',
        Colors.green,
      );
      
      setState(() {
        connectedDeviceAddress = deviceAddress;
      });

    } catch (e) {
      debugPrint('Error connecting to device: $e');
      
      String errorMessage = 'Connection failed';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.toString().contains('refused')) {
        errorMessage = 'Connection refused. Device may be busy or not ready.';
      } else if (e.toString().contains('not paired') || e.toString().contains('bond')) {
        errorMessage = 'Device is not properly paired. Please pair in system settings.';
        await _openBluetoothSettings(device);
      } else {
        errorMessage = 'Connection failed: ${e.toString().split(':').last}';
      }
      
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          connectingDevices.remove(deviceAddress);
        });
      }
    }
  }

  Future<void> _disconnectDevice(Device device) async {
    if (device.address == null) return;
    
    try {
      _showSnackBar('Disconnecting...', Colors.orange);
      await _bluetoothClassicPlugin.disconnect();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        connectedDeviceAddress = null;
      });
      
      await _getPairedDevices();
=======
  Future<void> _connectToDevice(BluetoothDevice device) async {
    // 🔥 NEW: Prevent connecting to other devices if already connected
    final bleService = BleManagerService();
    if (bleService.isConnected) {
      _showSnackBar('Already connected to a device. Disconnect first.', Colors.orange);
      return;
    }
    
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
        autoConnect: false,
      );

      // Verify connection state before proceeding
      final connectionState = await device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        throw Exception('Device not in connected state');
      }

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

        if (service.uuid.toString().toUpperCase().contains(serviceUUID.toUpperCase())) {
          serviceFound = true;
          debugPrint('✅ Target service found!');

          BluetoothCharacteristic? foundWriteCharacteristic;
          BluetoothCharacteristic? foundReadCharacteristic;

          for (BluetoothCharacteristic characteristic in service.characteristics) {
            debugPrint('Characteristic UUID: ${characteristic.uuid}');
            final charUuidStr = characteristic.uuid.toString().toUpperCase();

            if (charUuidStr.contains("1234")) {
              if (characteristic.properties.write ||
                  characteristic.properties.writeWithoutResponse) {
                foundWriteCharacteristic = characteristic;
                debugPrint('✅ Write characteristic found');
              }
            }

            if (charUuidStr.contains("5678")) {
              if (characteristic.properties.read ||
                  characteristic.properties.notify) {
                foundReadCharacteristic = characteristic;
                debugPrint('✅ Read characteristic found');
              }
            }
          }

          if (foundWriteCharacteristic != null) {
            debugPrint('╔════════════════════════════════════════╗');
            debugPrint('║  ✅ BLUETOOTH CONNECTION SUCCESSFUL ✅  ║');
            debugPrint('╠════════════════════════════════════════╣');
            debugPrint('║  Device: ${device.platformName.padRight(28)}║');
            debugPrint('║  Status: Ready to receive commands     ║');
            debugPrint('╚════════════════════════════════════════╝');

            _showSnackBar('✅ Connected! Ready to send data', Colors.green);

            // 🔥 NEW: Store connected device ID for UI highlighting
            setState(() {
              _connectedDeviceId = device.remoteId.toString();
            });

            BleManagerService().initialize(
              device: device,
              writeCharacteristic: foundWriteCharacteristic,
              readCharacteristic: foundReadCharacteristic,
              statusCallback: _showSnackBar,
              disconnectCallback: () {
                if (mounted) {
                  setState(() {
                    // 🔥 NEW: Clear highlighted device on disconnect
                    _connectedDeviceId = null;
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

      try {
        await device.disconnect();
      } catch (_) {}
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

      try {
        await device.disconnect();
      } catch (_) {}
    }
  }

  Future<void> _disconnectDevice() async {
    final bleService = BleManagerService();

    if (!bleService.isConnected) return;

    try {
      _showSnackBar('Disconnecting...', Colors.orange);

      await bleService.disconnect();

      if (mounted) {
        setState(() {
          // 🔥 NEW: Clear connected device ID on manual disconnect
          _connectedDeviceId = null;
        });
      }

>>>>>>> recovered-20260202
      _showSnackBar('Device disconnected', Colors.orange);
    } catch (e) {
      debugPrint('Error disconnecting device: $e');
      _showSnackBar('Error disconnecting device', Colors.red);
    }
  }

<<<<<<< HEAD
  // Show instructions to unpair from system settings
  Future<void> _showUnpairInstructions(Device device) async {
    if (device.address == null) return;
    
    try {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A4A),
            title: const Text(
              'Unpair Device',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'To unpair "${device.name ?? "Unknown Device"}":\n\n'
              '1. Go to your device\'s Bluetooth settings\n'
              '2. Find "${device.name ?? "Unknown Device"}"\n'
              '3. Tap the settings icon next to it\n'
              '4. Select "Forget" or "Unpair"\n\n'
              'Note: Unpairing must be done through system settings.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Color(0xFF00BCD4))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing unpair instructions: $e');
    }
  }

=======
>>>>>>> recovered-20260202
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

<<<<<<< HEAD
  IconData _getDeviceIcon(Device device) {
    final name = (device.name ?? '').toLowerCase();
    if (name.contains('laptop') || name.contains('pc') || name.contains('computer')) {
      return Icons.laptop;
    } else if (name.contains('phone') || name.contains('iphone') || name.contains('android')) {
      return Icons.phone_iphone;
    } else if (name.contains('watch')) {
      return Icons.watch;
    } else if (name.contains('headphone') || name.contains('airpod') || name.contains('buds')) {
      return Icons.headphones;
    } else if (name.contains('speaker')) {
      return Icons.speaker;
    } else if (name.contains('car') || name.contains('bt')) {
      return Icons.directions_car;
=======
  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('esp32') ||
        name.contains('matrix') ||
        name.contains('led')) {
      return Icons.developer_board;
    } else if (name.contains('score') || name.contains('cricket')) {
      return Icons.sports_cricket;
>>>>>>> recovered-20260202
    } else {
      return Icons.bluetooth;
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    final bleService = BleManagerService();
    final isConnected = bleService.isConnected;
    final deviceName = bleService.deviceName;

>>>>>>> recovered-20260202
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
<<<<<<< HEAD
              // Header
=======
>>>>>>> recovered-20260202
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
<<<<<<< HEAD
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
=======
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
>>>>>>> recovered-20260202
                          'Cricket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
<<<<<<< HEAD
                        const SizedBox(width: 8),
                        const Padding(
=======
                        SizedBox(width: 8),
                        Padding(
>>>>>>> recovered-20260202
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
<<<<<<< HEAD
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.headphones, color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bluetooth Icon
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: isSearching
                    ? RotationTransition(
                        turns: _animation,
                        child: const Icon(Icons.bluetooth_searching, color: Color(0xFF40C4FF), size: 50),
                      )
                    : const Icon(Icons.bluetooth, color: Color(0xFF40C4FF), size: 50),
              ),

              // Device Lists
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // My Device Container (Paired & Connected Devices)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'My Devices',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                // Find New Devices button in header
                                TextButton.icon(
                                  onPressed: isSearching ? null : startSearching,
                                  icon: Icon(
                                    isSearching ? Icons.search : Icons.search,
                                    color: isSearching ? Colors.white38 : const Color(0xFF00BCD4),
                                    size: 18,
                                  ),
                                  label: Text(
                                    isSearching ? 'Searching...' : 'Find New',
                                    style: TextStyle(
                                      color: isSearching ? Colors.white38 : const Color(0xFF00BCD4),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            if (pairedDevices.isNotEmpty) ...[
                              ...pairedDevices.map((device) => _buildMyDeviceCard(device)),
                            ] else ...[
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'No paired devices',
                                    style: TextStyle(color: Colors.white54, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Other Devices Container
                      if (discoveredDevices.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A4A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Available Devices',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap a device to pair it in system settings',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              ...discoveredDevices.map((device) => _buildOtherDeviceCard(device)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
=======
                IconButton(
  icon: const Icon(
    Icons.settings,
    color: Colors.white,
    size: 24,
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  },
),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: isSearching || isConnected
                      ? SizedBox(
                          key: const ValueKey('animation'),
                          width: 200,
                          height: 200,
                          // 🔥 Lottie animation with smooth transition
                          child: Lottie.asset(
                            'assets/images/balls.json',
                            fit: BoxFit.contain,
                            repeat: isSearching || isConnected,
                          ),
                        )
                      : Icon(
                          key: const ValueKey('icon'),
                          Icons.bluetooth_disabled,
                          size: 140,
                          color: Colors.grey,
                        ),
                ),
              ),
              Text(
                isConnected
                    ? 'Connected to $deviceName'
                    : 'Not Connected',
                style: TextStyle(
                  color: isConnected
                      ? Colors.greenAccent
                      : Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? _disconnectDevice
                      : (isSearching ? null : startSearching),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    isConnected
                        ? 'Disconnect'
                        : (isSearching ? 'Searching...' : 'Start Scanning'),
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
                          
                          // 🔥 NEW: Check if this device is currently connected
                          final isThisDeviceConnected = _connectedDeviceId == device.remoteId.toString();

                          return Card(
                            color: isThisDeviceConnected 
                                ? const Color(0xFF2E4E3E) // 🔥 NEW: Green tint for connected device
                                : const Color(0xFF1E1E2E),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              // 🔥 NEW: Green border for connected device
                              side: isThisDeviceConnected
                                  ? const BorderSide(color: Colors.greenAccent, width: 2)
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              leading: Icon(
                                isThisDeviceConnected
                                    ? Icons.bluetooth_connected // 🔥 NEW: Connected icon
                                    : _getDeviceIcon(deviceName),
                                color: isThisDeviceConnected
                                    ? Colors.greenAccent // 🔥 NEW: Green for connected
                                    : Colors.blueAccent,
                                size: 36,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      deviceName,
                                      style: TextStyle(
                                        color: isThisDeviceConnected
                                            ? Colors.greenAccent // 🔥 NEW: Green text for connected
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // 🔥 NEW: "CONNECTED" badge
                                  if (isThisDeviceConnected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.greenAccent,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'CONNECTED',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                device.remoteId.toString(),
                                style: TextStyle(
                                  color: isThisDeviceConnected
                                      ? Colors.greenAccent.withOpacity(0.7) // 🔥 NEW: Green subtitle
                                      : Colors.white54,
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
                                        color: isThisDeviceConnected
                                            ? Colors.greenAccent.withOpacity(0.2) // 🔥 NEW: Green RSSI badge
                                            : Colors.blueAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${result.rssi} dBm',
                                        style: TextStyle(
                                          color: isThisDeviceConnected
                                              ? Colors.greenAccent // 🔥 NEW: Green RSSI text
                                              : Colors.blueAccent,
                                          fontSize: 12,
                                        ),
                                        
                                      ),
                                    )
                                  : null,
                              // 🔥 NEW: Disable tap if already connected (unless it's this device)
                              onTap: isConnected && !isThisDeviceConnected
                                  ? () {
                                      _showSnackBar(
                                        'Already connected. Disconnect first.',
                                        Colors.orange,
                                      );
                                    }
                                  : () => _connectToDevice(device),
                            ),
                          );
                        },
                      ),
>>>>>>> recovered-20260202
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildMyDeviceCard(Device device) {
    final isConnected = connectedDeviceAddress == device.address;
    final isConnecting = connectingDevices.contains(device.address);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFF1E3A5F) : const Color(0xFF1F1F3F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? const Color(0xFF4CAF50) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFF4C4CFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isConnecting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : Icon(_getDeviceIcon(device), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name ?? 'Unknown Device',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected ? const Color(0xFF4CAF50) : Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnecting ? 'Connecting...' : (isConnected ? 'Connected' : 'Paired'),
                      style: TextStyle(
                        color: isConnecting 
                            ? const Color(0xFF00BCD4) 
                            : (isConnected ? const Color(0xFF4CAF50) : Colors.white54),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              if (isConnected) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.link_off, color: Colors.redAccent, size: 20),
                    onPressed: () => _disconnectDevice(device),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Disconnect',
                  ),
                ),
              ] else if (!isConnecting) ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.link, color: Color(0xFF00BCD4), size: 20),
                    onPressed: () => _connectToDevice(device),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Connect',
                  ),
                ),
              ],
              const SizedBox(width: 8),
              // Unpair button
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.orangeAccent, size: 20),
                  onPressed: () => _showUnpairInstructions(device),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  tooltip: 'Unpair',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherDeviceCard(Device device) {
    final deviceAddress = device.address ?? '';
    final deviceName = device.name ?? 'Unknown Device';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openBluetoothSettings(device),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4C4CFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getDeviceIcon(device), color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deviceAddress,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.settings_bluetooth,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
                onPressed: () => _openBluetoothSettings(device),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                tooltip: 'Pair in Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }
=======
>>>>>>> recovered-20260202
}