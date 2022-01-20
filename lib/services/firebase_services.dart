import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class FirebaseServices {
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> validateUser(id) async{
    DocumentSnapshot result = await boys.doc(id).get();
    return result;
  }
    Future<DocumentSnapshot> getCustomerDetail(id) async {
    return await users.doc(id).get();
    
  }

  Future<void>updateOrder({id, status}) async{
     final format = new DateFormat('yyyy-MM-dd hh:mm');
    DateTime now = DateTime.now();
    String time = format.format(now);
    Map<String, String> map = {
      'orderStatus': status,
      'time': time,
    };
    List orderStatus = [map];
    return await orders.doc(id).update({
      'currentOrderStatus': status,
      'orderStatus': FieldValue.arrayUnion(orderStatus)
    });
  }
}
