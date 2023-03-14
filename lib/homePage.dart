import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  TextEditingController? idTextController;
  TextEditingController? titleTextController;
  var data;
  var confidence;
  var classValue;
  var isLoading = false.obs;

  var id = 0.obs;
  var statusCode;
  TextEditingController runNo = TextEditingController();

  upload(File imageFile) async {
    isLoading.value = true;
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uploadURL = "http://ec2-34-196-165-184.compute-1.amazonaws.com/predict";
    var uri = Uri.parse(uploadURL);
    var request = http.MultipartRequest("POST", uri);
    var multipartFile =
        http.MultipartFile('file', stream, length, filename: (imageFile.path));
    request.files.add(multipartFile);
    var response = await request.send();
    statusCode = response.statusCode.toString();
    if (response.statusCode == 200) {
      response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .listen((value) {
        print("Value is :  $value");
        data = value;
        setState(() {
          classValue = data["class"].toString();
          confidence = data["confidence"].toString();
        });
      });
    }
    isLoading.value = false;
  }

  savePdf() async {
    if (_image == null) {
      Get.showSnackbar(GetSnackBar(
        message: "No Image Selected",
        title: "Select Image",
        snackPosition: SnackPosition.TOP,
        duration: Duration(milliseconds: 1500),
      ));
    } else if (runNo.text == "") {
      Get.showSnackbar(GetSnackBar(
        message: "Run Number Empty",
        title: "Enter Run No.",
        snackPosition: SnackPosition.TOP,
        duration: Duration(milliseconds: 1500),
      ));
    } else {
      var h = MediaQuery.of(context).size.height;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
              children: [
                pw.Text("Run No : ${runNo.text}",
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Image(
                  pw.MemoryImage(_image!.readAsBytesSync()),
                  height: h / 1.5,
                ),
                pw.Text(
                  "Class :- ${classValue ?? ""}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  "Confidence :- ${confidence ?? ""}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
      Directory? directory;
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
      }
      if (!await directory.exists())
        directory = await getExternalStorageDirectory();
      final bytes = await pdf.save();
      File file = File(
          '${directory!.path}/bcdi_classification${DateTime.now().microsecondsSinceEpoch}.pdf');
      print(file);
      await file.writeAsBytes(bytes);
      Get.showSnackbar(GetSnackBar(
        message: "File Save Successfully on Downloads Folder",
        title: "Saved",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1500),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              opacity: 0.5,
              image: AssetImage("assets/images/logo.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: Text(
                    "Maitri Diamond Purity",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                      child: Text(
                    "BCDI-CLASSIFICATION",
                    style: TextStyle(color: Colors.black, fontSize: 25),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Run No :- ",
                            style: const TextStyle(fontSize: 25),
                          ),
                          TextFormField(
                            controller: runNo,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                constraints: BoxConstraints(
                                  maxWidth: w / 4,
                                  maxHeight: 30,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                savePdf();
                              },
                              child: const Icon(
                                Icons.download_sharp,
                                size: 35,
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              onTap: () {
                                runNo.text = "";
                                _image = null;
                                classValue = "";
                                confidence = "";
                                statusCode = "";
                              },
                              child: Icon(Icons.delete, size: 35)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  (_image == null)
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)),
                          height: h / 3,
                          width: w,
                        )
                      : ClipRRect(
                          // borderRadius: BorderRadius.circular(h/2),
                          child: Image.file(
                          _image!,
                          width: w,
                          fit: BoxFit.fill,
                        )),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (isLoading.value == true)
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: Text(
                              "Class :- ${classValue ?? ""}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (isLoading.value == true)
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: Text(
                              "Confidence :- ${confidence ?? ""}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (isLoading.value == true)
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: Text(
                              "Status Code:- ${statusCode ?? ""}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery);

                            log('image path : ${image?.path} -- MimeType : ${image?.mimeType}');

                            setState(() {
                              _image = File(image!.path);
                            });
                            upload(_image!);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          child: const Icon(
                            CupertinoIcons.photo,
                            size: 80,
                            color: Colors.black,
                          )),
                      ElevatedButton(
                          onPressed: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                            log('image path : ${image?.path} -- MimeType : ${image?.mimeType}');

                            setState(() {
                              _image = File(image!.path);
                            });
                            // APIs.updateUserProfile(File(_image!));
                            upload(_image!);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          child: const Icon(
                            CupertinoIcons.camera,
                            size: 80,
                            color: Colors.black,
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
