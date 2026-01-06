import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:async';

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

  final _bluetoothClassicPlugin = BluetoothClassic();
  
  List<Device> pairedDevices = [];
  List<Device> discoveredDevices = [];
  Set<String> connectingDevices = {};
  String? connectedDeviceAddress;

  StreamSubscription<Device>? _scanSubscription;
  StreamSubscription<int>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _initBluetooth();
    _listenToConnectionStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
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
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        
        if (androidInfo.version.sdkInt >= 31) {
          // Android 12+
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
          // Android 11 and below
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
    });
    _animationController.repeat();

    try {
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

      if (mounted) {
        setState(() {
          isSearching = false;
        });
        _animationController.stop();
        _animationController.reset();

        if (discoveredDevices.isEmpty) {
          _showSnackBar(
            'No new devices found. Make sure devices are discoverable.',
            Colors.orange,
          );
        } else {
          _showSnackBar(
            'Found ${discoveredDevices.length} new device(s). Tap to pair in system settings.',
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
      _showSnackBar('Device disconnected', Colors.orange);
    } catch (e) {
      debugPrint('Error disconnecting device: $e');
      _showSnackBar('Error disconnecting device', Colors.red);
    }
  }

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
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Cricket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}