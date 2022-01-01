import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dogs vs Cats',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Georgia',
      ),
      home: const Home(),
    );
  }
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  File? image;
  var imageWidth;
  var imageHeight;
  var result;

  loadModel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
        model: "assets/dogs-vs-cats-tflite.tflite",
        labels: "assets/labels.txt",
      );
    } on PlatformException {
      print('failed to load the model');
    }
  }

  Future predict(File img) async {
    var prediction = await Tflite.runModelOnImage(
      path : img.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true
    );
    setState(() {
      result = prediction;
    });
  }

  Future sendImage(File img) async {
    if(img == null) return;
    await predict(img);

    FileImage(img).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
      setState(() {
        imageWidth = info.image.width.toDouble();
        imageHeight = info.image.height.toDouble();
        image = img;
      });
    })));
  }

  // select image from gallery
  selectFromGallery() async {
    final picker = ImagePicker();
    var img = await picker.pickImage(source: ImageSource.gallery), imggg;
    if(img == null) return;
    setState(() {});
    if(img != null) {imggg = File(img.path);}
    sendImage(imggg);
  }

  // select image from camera
  selectFromCamera() async {
    final picker = ImagePicker();
    var img = await picker.pickImage(source: ImageSource.camera), imggg;
    if(img == null) return;
    setState(() {});
    if(img != null) {imggg = File(img.path);}
    sendImage(imggg);
  }

  @override
  void initState() {
    super.initState();

    loadModel().then((val) {
      setState(() {});
    });
  }

  Widget PredictionValue(rcg) {
    if (rcg == null) {
      return Text('', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    }else if(rcg.isEmpty){
      return Center(
        child: Text("Could not recognize", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0,0,0,0),
      child: Center(
        child: Column(
          children: [
            Text(
              "Prediction: "+rcg[0]['label'].toString().toUpperCase(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Text(
              "Confidence: "+rcg[0]['confidence'].toStringAsFixed(2).toUpperCase(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dogs vs Cats'),),
      body: Center(
        child: Scrollbar(
          thickness: 10,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text('よこそ'),
                image == null ? Text('upload an image') : Center(
                  child: Image.file(
                    image!,
                    fit: BoxFit.scaleDown, 
                    width: MediaQuery.of(context).size.width * 0.9, 
                    height: MediaQuery.of(context).size.height * 0.7
                  ),
                ),
                PredictionValue(result),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: selectFromCamera,
                      icon: Icon(Icons.camera),
                      label: Text('Camera'),
                    ),
                    TextButton.icon(
                      onPressed: selectFromGallery, 
                      icon: Icon(Icons.upload), 
                      label: Text('Gallery'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}