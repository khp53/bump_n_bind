import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'contract_model.dart';

class SuccessScreen extends StatelessWidget {
  final ContractModel contractA;
  final ContractModel contractB;

  const SuccessScreen({
    super.key,
    required this.contractA,
    required this.contractB,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signed Contract')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bump Successful!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Name A: ${contractA.name}\nName B: ${contractB.name}\nTimestamp: ${contractA.timestamp}\nTimestamp: ${contractB.timestamp}',
              ),
              const SizedBox(height: 16),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc ut laoreet dictum, massa erat ultricies enim, nec dictum ex nulla ac nisi.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Text('Signatures:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: contractA.signatureData.isNotEmpty
                        ? Image.memory(
                            // decode base64 or load file
                            decodeSignature(contractA.signatureData) ??
                                Uint8List(0),
                            height: 80,
                            fit: BoxFit.contain,
                          )
                        : const Text('No Signature'),
                  ),
                  Expanded(
                    child: contractB.signatureData.isNotEmpty
                        ? Image.memory(
                            // decode base64 or load file
                            decodeSignature(contractB.signatureData) ??
                                Uint8List(0),
                            height: 80,
                            fit: BoxFit.contain,
                          )
                        : const Text('No Signature'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List? decodeSignature(dynamic data) {
    if (data == null) return null;
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    if (data is String) {
      // Try parsing as a Dart list string: "[1, 2, 3]"
      if (data.startsWith('[') && data.endsWith(']')) {
        try {
          final list = data
              .substring(1, data.length - 1)
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList();
          return Uint8List.fromList(list);
        } catch (_) {}
      }
      // Fallback: try base64
      try {
        return Uint8List.fromList(base64Decode(data));
      } catch (_) {}
    }
    return null;
  }
}
