import 'dart:io';

class Info {
  final File? photo;

  Info({this.photo});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      photo: json['photo'] != null ? File(json['photo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo': photo?.path,
    };
  }
}