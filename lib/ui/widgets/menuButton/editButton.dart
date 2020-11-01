import 'dart:io';

import 'package:Prism/theme/jam_icons_icons.dart';
import 'package:Prism/ui/widgets/popup/signInPopUp.dart';
import 'package:flutter/material.dart';
import 'package:photofilters/photofilters.dart';
import 'package:Prism/main.dart' as main;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imageLib;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class EditButton extends StatefulWidget {
  final String url;
  const EditButton({
    @required this.url,
    Key key,
  }) : super(key: key);

  @override
  _EditButtonState createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  bool isLoading;
  String imageData;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (main.prefs.get("isLoggedin") == false) {
          googleSignInPopUp(context, () {
            onEdit(widget.url);
          });
        } else {
          onEdit(widget.url);
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4))
              ],
              borderRadius: BorderRadius.circular(500),
            ),
            padding: const EdgeInsets.all(17),
            child: Icon(
              JamIcons.pencil,
              color: Theme.of(context).accentColor,
              size: 20,
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              height: 53,
              width: 53,
              child:
                  isLoading ? const CircularProgressIndicator() : Container())
        ],
      ),
    );
  }

  Future<void> onEdit(String url) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(url); // <--2
    final documentDirectory = await getApplicationDocumentsDirectory();
    final firstPath = "${documentDirectory.path}/images";
    final filePathAndName = "${documentDirectory.path}/images/pic.jpg";
    await Directory(firstPath).create(recursive: true); // <-- 1
    File file2 = File(filePathAndName); // <-- 2
    file2.writeAsBytesSync(response.bodyBytes); // <-- 3
    setState(() {
      imageData = filePathAndName;
      isLoading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: const Text("Photo Filter Example"),
          image: imageLib.decodeImage(File(imageData).readAsBytesSync()),
          filters: presetFiltersList,
          filename: path.basename(File(imageData).path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
