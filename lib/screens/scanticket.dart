import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanTicket extends StatefulWidget {
  final String ticketId;
  const ScanTicket({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanTicketState();
}

class _ScanTicketState extends State<ScanTicket> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Scan Ticket')),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                'Result: ${result!.code}',
                style: TextStyle(fontSize: 20),
              )
                  : Text('Scan a QR code', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      // Check if the scanned result matches the ticketId
      if (result?.code == widget.ticketId) {
        _showAlert(context, 'Ticket Scanned', 'Ticket ID: ${widget.ticketId}');
      }
    });
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
