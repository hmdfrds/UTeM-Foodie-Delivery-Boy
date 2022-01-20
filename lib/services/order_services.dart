import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderServices {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<void> updateOrderStatus(documentId, status) async {
    final format = new DateFormat('yyyy-MM-dd hh:mm');
    DateTime now = DateTime.now();
    String time = format.format(now);
    Map<String, String> map = {
      'orderStatus': status,
      'time': time,
    };
    List orderStatus = [map];
    return await orders.doc(documentId).update({
      'currentOrderStatus': status,
      'orderStatus': FieldValue.arrayUnion(orderStatus)
    });
  }
}
