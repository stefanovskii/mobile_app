import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? from;
  final String? to;
  final String? message;
  final String? type;
  final DateTime? timestamp;

  NotificationModel({
    this.from,
    this.to,
    this.message,
    this.type,
    this.timestamp,
  });

  factory NotificationModel.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      from: data['from'],
      to: data['to'],
      message: data['message'],
      type: data['type'],
      timestamp: data['timestamp']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'message': message,
      'type': type,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }
}
