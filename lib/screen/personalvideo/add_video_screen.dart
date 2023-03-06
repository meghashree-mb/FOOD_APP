import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/providers/manager.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:nexus/utils/widgets.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({Key? key}) : super(key: key);

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {

  File? videofile;
  bool? uploadingvideo;
  final picker = ImagePicker();
  TextEditingController? captionController;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    uploadingvideo = false;
    currentUser = FirebaseAuth.instance.currentUser;
    captionController = TextEditingController();
  }

  Future<File> checkAnCompress() async {
    File? compressedFile = videofile!;
    int minimumSize = 200 * 1024;
    if (await compressedFile.length() > minimumSize) {
      final dir = await path_provider.getTemporaryDirectory();
      final tp = dir.absolute.path + "/temp.mp4";
      compressedFile = await compressAndGetFile(compressedFile, tp);
    }
    print(await compressedFile.length());
    return compressedFile;
  }

  @override
  Widget build(BuildContext context) {

    Future pickImage() async {
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (mounted) {
        setState(() {
          videofile = File(pickedFile!.path);
        });
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
        actions: [
          (uploadingvideo!)
              ? const SizedBox()
              : IconButton(
              onPressed: () {
                if (!uploadingvideo!) {
                  if (videofile != null) {
                    setState(() {
                      videofile = null;
                    });
                  }
                }
              },
              color: (videofile != null) ? Colors.red[300] : Colors.grey,
              icon: const Icon(Icons.delete)),
          (uploadingvideo!)
              ? const SizedBox()
              : IconButton(
              onPressed: () async {
                if (videofile != null) {
                  setState(() {
                    uploadingvideo = true;
                  });
                  // File? compressedFile = await checkAnCompress();
                  setState(() {
                    videofile;
                  });
                  // remove = compressedFile
                  await Provider.of<manager>(context, listen: false)
                      .addNewVideo(captionController!.text.toString(),
                      currentUser!.uid.toString(), videofile!)
                      .then((value) {
                    setState(() {
                      uploadingvideo = false;
                    });
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      content: Text('Successfully posted'),
                      duration: Duration(seconds: 2),
                    ));
                    Navigator.pop(context);
                  });
                }
              },
              icon: Icon(Icons.check),
              color: (videofile != null) ? Colors.green : Colors.grey)
        ],
      ),
      body: SafeArea(
        child: Container(
          height: displayHeight(context),
          width: displayWidth(context),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: (uploadingvideo!)
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: displayHeight(context) * 0.2),
                Expanded(child: Image.asset('images/postLoad.gif')),
                Expanded(
                  child: Text(
                    'Uploading Post ...',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: displayWidth(context) * 0.05,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
                : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (videofile != null)
                      ? Image.file(
                    videofile!,
                    height: displayHeight(context) * 0.5,
                    width: displayWidth(context) * 0.8,
                    fit: BoxFit.contain,
                  )
                      : Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)),
                    height: displayHeight(context) * 0.5,
                    width: displayWidth(context) * 0.8,
                    child: Center(
                        child: IconButton(
                          onPressed: () {
                            pickImage();
                          },
                          icon: Icon(Icons.video_call_rounded),
                        )),
                  ),
                  Opacity(
                      opacity: 0.0,
                      child: Divider(
                        height: displayHeight(context) * 0.1,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLength: 500,
                      maxLines: 5,
                      minLines: 1,
                      controller: captionController,
                      decoration: const InputDecoration(
                          hintText: "Write a caption...",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400)),
                    ),
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
