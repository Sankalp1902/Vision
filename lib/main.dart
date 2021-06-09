import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:vision/ocr.dart';
import 'package:flushbar/flushbar.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision',
      home: MyHomePage(title: 'Vision'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  static bool _multipleOcr = true;
  static bool _waitTapOcr = true;
  static bool _showTextOcr = true;

  Size _previewOcr;
  List<OcrText> _textsOcr = [];

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((previewSizes) => setState(() {
      _previewOcr = previewSizes[_cameraOcr].first;
    }));
  }

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
          IconButton(
            icon: _torchOcr ==true ? Icon(Icons.flash_on):Icon(Icons.flash_off),
            onPressed: () {
              setState(() {
                _torchOcr = !_torchOcr;
              });
            }),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                displayModalBottomSheet(context);
              }),
        ],
      ),
      body:
      Center(
          child:
               _getOcrScreen(context),

          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _read();
        },
        label: Text(
          'Scan',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18
          ),
        ),
        icon: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),



    );
  }

  void displayModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return bottom();// return a StatefulWidget widget
        }
        );
  }

  ///
  /// OCR Screen
  ///
  Widget _getOcrScreen(BuildContext context) {
    List<Widget> items = [];

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _textsOcr.map((ocrText) => OcrTextWidget(ocrText),
        ).toList(),
      ),
    );


    return items.isEmpty ? Center(
        child:
        Text(
          'Click on "Scan" button to add text.',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
    ) :ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// OCR Method
  ///
  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        waitTap: _waitTapOcr,
        showText: _showTextOcr,
        preview: _previewOcr,
        camera: _cameraOcr,
        fps: 2.0,
      );
     /*setState(() {
        _textValue = texts[0].value; // Getting first text block....
      });*/

     // texts.add(OcrText( texts[0].value));
    } on Exception {
      texts.add(OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
  }




}

///
/// OcrTextWidget
///
class OcrTextWidget extends StatelessWidget {
  final OcrText ocrText;

  OcrTextWidget(this.ocrText);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.title),
      title: Text(ocrText.value),
      subtitle: Text(ocrText.language),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OcrTextDetail(ocrText),
        ),
      ),
    );
  }
}


class bottom extends StatefulWidget {
  @override
  _bottomState createState() => _bottomState();
}

class _bottomState extends State<bottom> {
  bool isSwitched = false;


  void _onSwitchChanged(bool value) {
//    setState(() {
    isSwitched = value;
//    });
  }
  @override
  Widget build(BuildContext context) {

    return Row(
        children: [
       Expanded(

        //contains a single child which is scrollable
        child: SingleChildScrollView(
          child: Wrap(
            children: <Widget>[

              new SwitchListTile(
                title: const Text('Return all texts:',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                value: _MyHomePageState._multipleOcr,
                onChanged: (value) => setState(() => _MyHomePageState._multipleOcr = value),
                secondary: const Icon(Icons.lightbulb_outline),
              ),
              Divider(thickness: 0.2, color: Colors.black),
              new SwitchListTile(
                title: const Text('Capture when tap screen:',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                value: _MyHomePageState._waitTapOcr,
                onChanged: (value) => setState(() => _MyHomePageState._waitTapOcr = value),
                secondary: const Icon(Icons.touch_app_outlined),
              ),
              Divider(thickness: 0.2, color: Colors.black),
              new SwitchListTile(
                title: const Text('Show text:',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                value: _MyHomePageState._showTextOcr,
                onChanged: (value) => setState(() => _MyHomePageState._showTextOcr = value),
                secondary: const Icon(Icons.text_snippet_outlined),
              ),
              Divider(thickness: 0.2, color: Colors.black),
              ListTile(
                leading: Icon(Icons.feedback,color: Colors.grey),
                title: Text('Feedback',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                onTap: () {
                  Fluttertoast.showToast(msg: " Opening feedback page..  ",toastLength: Toast.LENGTH_SHORT);
                  gourl('http://atdepic.000webhostapp.com/feedback.php');
                },
              ),
              Divider(thickness: 0.2, color: Colors.black),
              ListTile(
                leading: Icon(Icons.supervised_user_circle,color: Colors.grey),
                title: Text('About dev',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                onTap: () {
                  Fluttertoast.showToast(msg: " Opening developer's portfolio..  ",toastLength: Toast.LENGTH_SHORT);
                  gourl('http://sankalpmishra.me');
                },
              ),
              Divider(thickness: 0.2, color: Colors.black),
              ListTile(
                leading: Icon(Icons.share,color: Colors.grey),
                title: Text('Share',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                onTap: () {
                  Fluttertoast.showToast(msg: " Please wait..  ",toastLength: Toast.LENGTH_SHORT);
                  final RenderBox box = context.findRenderObject();
                  Share.share('Hi! Check out Depic, A made in India depreciation calculator!\nTry this if you need to calculate deprecation and share your reviews and feedback.\nAs of now this app is not available on Playstore, still you can download it from its official website:\n  http://atdepic.000webhostapp.com/downloads.php', subject: 'Depic: Depreciation Calculator', sharePositionOrigin: box.localToGlobal(Offset.zero) &
                  box.size);
                },
              ),
              Divider(thickness: 0.2, color: Colors.black),
              ListTile(
                leading: Icon(Icons.system_update_alt,color: Colors.grey),
                title: Text('Check for update',style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,)),
                onTap: () {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    flushbarStyle: FlushbarStyle.GROUNDED,
                    reverseAnimationCurve: Curves.decelerate,
                    forwardAnimationCurve: Curves.elasticOut,
                    backgroundColor: Colors.black,
                    duration: Duration(seconds: 15),
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    mainButton: IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Fluttertoast.showToast(msg: /*" Opening downloads page..  "*/"Will be available soom",toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 15,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        //gourl('http://atdepic.000webhostapp.com/downloads.php');
                      },
                      tooltip: 'Go to downloads page',
                      color: Colors.white,
                    ),
                    titleText: Text(
                      "Vision version: 1.0.0+1",
                      style: TextStyle(fontSize: 18.0, color: Colors.green),
                    ),
                    messageText: Text(
                      "Automatic update notification feature will be available soon.\nBy that time, please click on the button to manually check.",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
                    ),
                  )..show(context);
                },
              ),
              Divider(thickness: 0.2, color: Colors.black),
              ListTile(
                title: Text('Made in India',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black54)),
              ),
            ],
          ),
    ),
    ),
    ]
    );

  }

  gourl(url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "Something went wrong :(",toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      throw 'Could not launch $url';
    }
  }
}