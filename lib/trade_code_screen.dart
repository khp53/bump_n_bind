import 'package:bump_n_bind/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'contract_model.dart';
import 'package:hive/hive.dart';
import 'signature_screen.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

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

  Future<void> startNfcAndExchange() async {
    NfcAvailability availability = await NfcManager.instance
        .checkAvailability();
    if (availability != NfcAvailability.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC not available on this device.')),
      );
      return;
    }
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (NfcTag tag) async {
        print('NFC Tag discovered: $tag');
        final ndef = Ndef.from(tag);
        if (ndef == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No NDEF data found.')));
          NfcManager.instance.stopSession();
          return;
        }
        // Read peer's code
        final message = ndef.cachedMessage;
        String? receivedCode;
        String? peerSignature;
        if (message != null && message.records.isNotEmpty) {
          final record = message.records.first;
          receivedCode = String.fromCharCodes(
            record.payload,
          ); // Simplified decoding
          // Optionally decode peer signature from additional record
          if (message.records.length > 1) {
            peerSignature = String.fromCharCodes(message.records[1].payload);
          }
          print('Received NDEF message with ${message.records.first} records');
        }
        if (receivedCode == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not decode code.')),
          );
          NfcManager.instance.stopSession();
          return;
        }
        if (receivedCode == handshakeKey) {
          // Check Hive for signature
          var box = await Hive.openBox('signatures');
          final mySignature = box.get('signature');
          if (mySignature == null) {
            // No signature, show alert and navigate
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
                        MaterialPageRoute(
                          builder: (_) => const SignatureScreen(),
                        ),
                      );
                    },
                    child: const Text('Go'),
                  ),
                ],
              ),
            );
            NfcManager.instance.stopSession();
            return;
          }
          // If peerSignature is not present, fallback to dummy or error
          final peerSig = peerSignature ?? 'peer_signature_data';
          final contract = ContractModel(
            name: 'User Name',
            timestamp: DateTime.now(),
            signatureData: '$mySignature|$peerSig',
          );
          // Optionally, write contract to NFC or send to peer
          // Navigate to success page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SuccessScreen(
                contractA: contract,
                contractB: contract, // For demo, using same contract
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Codes do not match. Received: $receivedCode'),
            ),
          );
        }
        NfcManager.instance.stopSession();
      },
    );
  }

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
                ElevatedButton(
                  onPressed: handshakeKey.length == 6
                      ? startNfcAndExchange
                      : null,
                  child: const Text('Start NFC Scanning'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
