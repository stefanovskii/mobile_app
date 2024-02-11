import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function(File?) onImageSelected;

  const ImageInput({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 300);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    // Notify the parent widget about the selected image
    widget.onImageSelected(_selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(onPressed: _takePicture, icon: Icon(Icons.camera_alt), label: Text("Take picture"));

    if (_selectedImage != null) {
      content = Image.file(_selectedImage!, fit: BoxFit.cover);
    }

    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
