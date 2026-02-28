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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contract Template:',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Name A: ${contractA.name}\nName B: ${contractB.name}\nTimestamp: ${contractA.timestamp}\nTimestamp: ${contractB.timestamp}',
            ),
            const SizedBox(height: 32),
            Text('Signatures:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            // Row(
            //   children: [
            //     Expanded(
            //       child: contractA.signatureData.isNotEmpty
            //           ? Image.memory(
            //               // decode base64 or load file
            //               // Uint8List.fromList(base64Decode(contractA.signatureData)),
            //               // For now, placeholder
            //               const [],
            //               height: 80,
            //               fit: BoxFit.contain,
            //             )
            //           : const Text('No Signature'),
            //     ),
            //     Expanded(
            //       child: contractB.signatureData.isNotEmpty
            //           ? Image.memory(
            //               // decode base64 or load file
            //               // Uint8List.fromList(base64Decode(contractB.signatureData)),
            //               // For now, placeholder
            //               const [],
            //               height: 80,
            //               fit: BoxFit.contain,
            //             )
            //           : const Text('No Signature'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
