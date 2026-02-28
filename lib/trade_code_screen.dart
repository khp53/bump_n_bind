import 'package:bump_n_bind/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'contract_model.dart';
import 'package:hive/hive.dart';
import 'signature_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:nearby_connections/nearby_connections.dart';

class TradeCodeScreen extends StatefulWidget {
  const TradeCodeScreen({Key? key}) : super(key: key);

  @override
  State<TradeCodeScreen> createState() => _TradeCodeScreenState();
}

class _TradeCodeScreenState extends State<TradeCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(
    8,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(8, (_) => FocusNode());
  String handshakeKey = '';
  ContractModel? receivedContract;
  bool _isLoading = false;
  bool _isDiscovering = false;

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Future<void> startNfcAndExchange() async {
  //   NfcAvailability availability = await NfcManager.instance
  //       .checkAvailability();
  //   if (availability != NfcAvailability.enabled) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('NFC not available on this device.')),
  //     );
  //     return;
  //   }
  //   NfcManager.instance.startSession(
  //     pollingOptions: {NfcPollingOption.iso14443},
  //     onDiscovered: (NfcTag tag) async {
  //       print('NFC Tag discovered: $tag');
  //       final ndef = Ndef.from(tag);
  //       if (ndef == null) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(const SnackBar(content: Text('No NDEF data found.')));
  //         NfcManager.instance.stopSession();
  //         return;
  //       }
  //       // Read peer's code
  //       final message = ndef.cachedMessage;
  //       String? receivedCode;
  //       String? peerSignature;
  //       if (message != null && message.records.isNotEmpty) {
  //         final record = message.records.first;
  //         receivedCode = String.fromCharCodes(
  //           record.payload,
  //         ); // Simplified decoding
  //         // Optionally decode peer signature from additional record
  //         if (message.records.length > 1) {
  //           peerSignature = String.fromCharCodes(message.records[1].payload);
  //         }
  //         print('Received NDEF message with ${message.records.first} records');
  //       }
  //       if (receivedCode == null) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Could not decode code.')),
  //         );
  //         NfcManager.instance.stopSession();
  //         return;
  //       }
  //       if (receivedCode == handshakeKey) {
  //         // Check Hive for signature
  //         var box = await Hive.openBox('signatures');
  //         final mySignature = box.get('signature');
  //         if (mySignature == null) {
  //           // No signature, show alert and navigate
  //           showDialog(
  //             context: context,
  //             builder: (context) => AlertDialog(
  //               title: const Text('No Signature Found'),
  //               content: const Text(
  //                 'You do not have any saved signature on the device. Go to signature screen?',
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: const Text('Cancel'),
  //                 ),
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                     Navigator.of(context).push(
  //                       MaterialPageRoute(
  //                         builder: (_) => const SignatureScreen(),
  //                       ),
  //                     );
  //                   },
  //                   child: const Text('Go'),
  //                 ),
  //               ],
  //             ),
  //           );
  //           NfcManager.instance.stopSession();
  //           return;
  //         }
  //         // If peerSignature is not present, fallback to dummy or error
  //         final peerSig = peerSignature ?? 'peer_signature_data';
  //         final contract = ContractModel(
  //           name: 'User Name',
  //           timestamp: DateTime.now(),
  //           signatureData: '$mySignature|$peerSig',
  //         );
  //         // Optionally, write contract to NFC or send to peer
  //         // Navigate to success page
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => SuccessScreen(
  //               contractA: contract,
  //               contractB: contract, // For demo, using same contract
  //             ),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Codes do not match. Received: $receivedCode'),
  //           ),
  //         );
  //       }
  //       NfcManager.instance.stopSession();
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2196F3), // Blue
                Color(0xFF001F54), // Navy Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Enter Handshake Key",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 8-digit separated PIN code field
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Expanded(
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          cursorColor: Colors.white,
                          controller: _pinControllers[i],
                          focusNode: _pinFocusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            focusColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && i < 7) {
                              _pinFocusNodes[i + 1].requestFocus();
                            } else if (value.isEmpty && i > 0) {
                              _pinFocusNodes[i - 1].requestFocus();
                            }
                            setState(() {
                              handshakeKey = _pinControllers
                                  .map((c) => c.text)
                                  .join();
                              _controller.text = handshakeKey;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isLoading || handshakeKey.length != 6)
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await startNearbySharing();
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Start NFC Scanning'),
                      ),
                    ),
                    if (_isDiscovering || _isLoading)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: IconButton(
                          icon: const Icon(Icons.stop, color: Colors.red),
                          tooltip: 'Stop Discovery',
                          onPressed: () async {
                            await Nearby().stopDiscovery();
                            await Nearby().stopAdvertising();
                            setState(() {
                              _isDiscovering = false;
                              _isLoading = false;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> startNearbySharing() async {
    setState(() {
      _isDiscovering = true;
    });
    // 1. Check for signature in Hive first
    var box = await Hive.openBox('signatures');
    final mySignature = box.get('signature');
    final userName = box.get('user_name') ?? 'User Name';
    if (mySignature == null || (mySignature is List && mySignature.isEmpty)) {
      // No signature, show alert and navigate
      setState(() {
        _isDiscovering = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Signature Found'),
          content: const Text(
            'You do not have any saved signature on the device. Go to signature screen?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignatureScreen()),
                );
              },
              child: const Text('Go'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Permissions (as before)
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
    if (!await Permission.location.serviceStatus.isEnabled) {
      final location = loc.Location();
      bool serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location service is required.')),
        );
        return;
      }
    }
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    bool bluetoothGranted = !(await Future.wait([
      Permission.bluetooth.isGranted,
      Permission.bluetoothAdvertise.isGranted,
      Permission.bluetoothConnect.isGranted,
      Permission.bluetoothScan.isGranted,
    ])).any((element) => element == false);
    if (!bluetoothGranted) {
      await [
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();
    }
    if (!await Permission.bluetooth.serviceStatus.isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth service is required.')),
      );
      return;
    }
    await Permission.nearbyWifiDevices.request();

    // 3. Nearby Connections logic
    final Strategy strategy = Strategy.P2P_CLUSTER;
    final String serviceId = "com.yourdomain.appname";

    // Start advertising
    try {
      bool advertising = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: (String id, ConnectionInfo info) {
          // Called whenever a discoverer requests connection
          // Accept connection and set up payload handlers
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endpointId, payload) async {
              // Handle received payload (e.g., handshakeKey, signature)
              if (payload.type == PayloadType.BYTES) {
                final data = String.fromCharCodes(payload.bytes!);
                // Expecting: handshakeKey|peerSignature|peerName
                final parts = data.split('|');
                if (parts.length == 2 && parts[0] == handshakeKey) {
                  final peerSignature = parts[1];
                  final contractA = ContractModel(
                    name: userName,
                    timestamp: DateTime.now(),
                    signatureData: '$mySignature',
                  );
                  final contractB = ContractModel(
                    name: parts[2],
                    timestamp: DateTime.now(),
                    signatureData: peerSignature,
                  );
                  // Stop advertising/discovery after success
                  Nearby().stopAdvertising();
                  Nearby().stopDiscovery();
                  setState(() {
                    _isDiscovering = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuccessScreen(
                        contractA: contractA,
                        contractB: contractB,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Handshake failed or invalid data.'),
                    ),
                  );
                }
              }
            },
            onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
          );
        },
        onConnectionResult: (String id, Status status) {
          // Called when connection is accepted/rejected
          if (status == Status.CONNECTED) {
            // Send handshakeKey and mySignature to peer
            final payload = '$handshakeKey|$mySignature|$userName';
            Nearby().sendBytesPayload(
              id,
              Uint8List.fromList(payload.codeUnits),
            );
          }
        },
        onDisconnected: (String id) {
          // Called whenever a discoverer disconnects from advertiser
        },
        serviceId: serviceId,
      );
      if (!advertising) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start advertising.')),
        );
        setState(() {
          _isDiscovering = false;
        });
      }
    } catch (exception) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nearby error: $exception')));
      setState(() {
        _isDiscovering = false;
      });
    }

    // Start discovery
    try {
      bool discovering = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (String id, String userName, String serviceId) {
          // Called when an advertiser is found
          // Request connection
          try {
            Nearby().requestConnection(
              userName,
              id,
              onConnectionInitiated: (id, info) {
                // Accept connection
                Nearby().acceptConnection(
                  id,
                  onPayLoadRecieved: (endpointId, payload) async {
                    if (payload.type == PayloadType.BYTES) {
                      final data = String.fromCharCodes(payload.bytes!);
                      // Expecting: handshakeKey|peerSignature
                      final parts = data.split('|');
                      if (parts.length == 2 && parts[0] == handshakeKey) {
                        final peerSignature = parts[1];
                        final contract = ContractModel(
                          name: 'User Name',
                          timestamp: DateTime.now(),
                          signatureData: '$mySignature|$peerSignature',
                        );
                        Nearby().stopAdvertising();
                        Nearby().stopDiscovery();
                        setState(() {
                          _isDiscovering = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SuccessScreen(
                              contractA: contract,
                              contractB:
                                  contract, // For demo, using same contract
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Handshake failed or invalid data.'),
                          ),
                        );
                      }
                    }
                  },
                  onPayloadTransferUpdate:
                      (endpointId, payloadTransferUpdate) {},
                );
              },
              onConnectionResult: (id, status) {
                if (status == Status.CONNECTED) {
                  // Send handshakeKey and mySignature to peer
                  final payload = '$handshakeKey|$mySignature';
                  Nearby().sendBytesPayload(
                    id,
                    Uint8List.fromList(payload.codeUnits),
                  );
                }
              },
              onDisconnected: (id) {},
            );
          } catch (exception) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nearby request error: $exception')),
            );
          }
        },
        onEndpointLost: (String? id) {},
        serviceId: serviceId,
      );
      if (!discovering) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start discovery.')),
        );
        setState(() {
          _isDiscovering = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nearby error: $e')));
      setState(() {
        _isDiscovering = false;
      });
    }
  }
}
