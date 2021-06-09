import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

///
///
///
class OcrTextDetail extends StatefulWidget {
  final OcrText ocrText;

  OcrTextDetail(this.ocrText);

  @override
  _OcrTextDetailState createState() => _OcrTextDetailState();
}

///
///
///
class _OcrTextDetailState extends State<OcrTextDetail> {
  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          'Vision',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
        actions: <Widget>[

        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(widget.ocrText.language.toUpperCase()),
            subtitle: const Text('Language'),

          ),
          Divider(
            color: Colors.black,
          ),
          ListTile(
            title: Text(widget.ocrText.value),
            subtitle: const Text('Text scanned'),
          ),

        ],
      ),
    );
  }
}
