import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'diamondModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _image;
  TextEditingController? idTextController;
  TextEditingController? titleTextController;
  var data;
  var id;
  var titleData;

  Future<Album> createAlbum(String title) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/albums'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
      }),
    );

    if (response.statusCode == 201) {
      data = jsonDecode(response.body);
      setState(() {
        id = data['id'].toString();
        titleData = data['title'].toString();
      });
      log(response.body);

      log("DataType of data : ${data.runtimeType}");
      return Album.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
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
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (_image == null)
                  ? Container()
                  : ClipRRect(
                      // borderRadius: BorderRadius.circular(h/2),
                      child: Image.file(
                      File(_image!),
                      width: w,
                      height: h/1.8,
                      fit: BoxFit.cover,
                    )),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Value", textAlign: TextAlign.right),
              ),
              SizedBox(
                height: 45,
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: data != null ? id : " ",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Confirmation", textAlign: TextAlign.right),
              ),
              SizedBox(
                height: 45,
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: data != null ? titleData : " ",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          elevation: 2,
          onPressed: () {
            _showBottomSheet();
          },
          label:const Text("Upload"),
          icon:const Icon(Icons.drive_folder_upload_rounded),

        ),
      ),
    );
  }

  void _showBottomSheet() {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: h * 0.02, bottom: h * 0.05),
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);

                      log('image path : ${image?.path} -- MimeType : ${image?.mimeType}');

                      setState(() {
                        _image = image!.path;
                      });
                      // APIs.updateUserProfile(File(_image!));
                      createAlbum(_image!);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(w * 0.2, h * 0.15),
                    ),
                    child: Image.asset('assets/images/photo.png'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.camera);
                      log('image path : ${image?.path} -- MimeType : ${image?.mimeType}');

                      setState(() {
                        _image = image!.path;
                      });
                      // APIs.updateUserProfile(File(_image!));
                      createAlbum(_image!);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(w * 0.2, h * 0.1),
                    ),
                    child: Image.asset('assets/images/camera.png'),
                  )
                ],
              ),
            ],
          );
        });
  }
}
