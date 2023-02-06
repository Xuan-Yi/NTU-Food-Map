import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PicturePicker extends StatelessWidget {
  PicturePicker({
    Key? key,
    required this.imgFiles,
    required this.setImgFiles,
    required this.removeImgFile,
  }) : super(key: key);

  final ImagePicker _picker = ImagePicker();
  final List<File> imgFiles;
  final ValueChanged<List<File>> setImgFiles;
  final ValueChanged<int> removeImgFile;

  // Get image from gallery
  Future<void> _getFromGallery() async {
    List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setImgFiles(pickedFiles.map((pf) => File(pf.path)).toList());
    }
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        // Picture picker title
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        // Pick pictures
        Row(
          children: [
            // Picture picker button
            SizedBox(
              height: 60,
              width: 60,
              child: Tooltip(
                message: "Pick pictures",
                padding: const EdgeInsets.all(8),
                verticalOffset: 36,
                height: 24,
                textStyle: const TextStyle(fontSize: 15, color: Colors.black),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 6,
                    )
                  ],
                ),
                waitDuration: const Duration(seconds: 1),
                showDuration: const Duration(seconds: 2),
                child: ElevatedButton(
                  onPressed: () => _getFromGallery(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Picture previews
            Expanded(
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: imgFiles.length,
                  itemBuilder: (context, int index) {
                    return TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromARGB(0, 255, 255, 255),
                              content: Stack(
                                children: [
                                  // preview image
                                  Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox.fromSize(
                                        size: Size.infinite,
                                        child: Image.file(imgFiles[index],
                                            filterQuality: FilterQuality.high,
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                  ),
                                  // detect to close preview
                                  GestureDetector(
                                      onTap: () => Navigator.pop(context)),
                                  // delete image button
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: MaterialButton(
                                      onPressed: () {
                                        removeImgFile(index);
                                        Navigator.pop(context);
                                      },
                                      color: Colors.white,
                                      splashColor: Colors.greenAccent,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(18),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 24,
                                        color: Colors.pinkAccent,
                                        shadows: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 16,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              insetPadding: EdgeInsets.zero,
                              contentPadding: EdgeInsets.zero,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox.fromSize(
                          size: const Size(60, 60),
                          child: Image.file(imgFiles[index],
                              filterQuality: FilterQuality.low,
                              fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
