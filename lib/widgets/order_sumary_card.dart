import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodir_delivery/services/firebase_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foodir_delivery/services/order_services.dart';
import 'package:intl/intl.dart';

class OrderSumarryCard extends StatefulWidget {
  const OrderSumarryCard({Key? key, required this.document}) : super(key: key);
  final DocumentSnapshot document;

  @override
  _OrderSumarryCardState createState() => _OrderSumarryCardState();
}

class _OrderSumarryCardState extends State<OrderSumarryCard> {
  OrderServices _orderServices = OrderServices();
  FirebaseServices _firebaseServices = FirebaseServices();
  DocumentSnapshot? _customer;

  Color? statusColors(DocumentSnapshot document) {
    if (document['currentOrderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }
    if (document['currentOrderStatus'] == 'Rejected') {
      return Colors.red;
    }
    if (document['currentOrderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    }
    if (document['currentOrderStatus'] == 'On The Way') {
      return Colors.purple[900];
    }
    if (document['currentOrderStatus'] == 'Delivered') {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(DocumentSnapshot document) {
    if (document['currentOrderStatus'] == 'Accepted') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColors(document),
      );
    }
    if (document['currentOrderStatus'] == 'Picked Up') {
      return Icon(
        Icons.cases,
        color: statusColors(document),
      );
    }
    if (document['currentOrderStatus'] == 'On The Way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColors(document),
      );
    }
    if (document['currentOrderStatus'] == 'Delivered') {
      return Icon(
        Icons.shopping_bag,
        color: statusColors(document),
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColors(document),
    );
  }

  @override
  void initState() {
    print(widget.document['userId']);
    _firebaseServices
        .getCustomerDetail(widget.document['userId'])
        .then((value) {
      setState(() {
        _customer = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 0,
            leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: statusIcon(widget.document)),
            title: Text(
              widget.document['currentOrderStatus'],
              style: TextStyle(
                  fontSize: 12,
                  color: statusColors(widget.document),
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'On ${DateFormat.yMMMd().format(DateTime.parse(widget.document['timestamp']))}',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Payment Type : ${widget.document['cod'] == true ? 'Cash on delivery' : 'Paid Online'}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Amount : RM${widget.document['total'].toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _customer != null
              ? ListTile(
                  title: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Receiver : ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text('${widget.document['receiverName']}',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Location : ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text('${widget.document['location']}',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                              ))
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          _launchURL(_customer!['number']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Icon(
                              Icons.phone_in_talk,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
              
          ExpansionTile(
            title: Text(
              'Order details',
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
            subtitle: Text(
              'View order details',
              style: TextStyle(fontSize: 12, color: Colors.black26),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return ListTile(
                      leading: CircleAvatar(
                        child: Image.network(
                            widget.document['products'][i]['productImage']),
                        backgroundColor: Colors.white,
                      ),
                      title: Text(
                        widget.document['products'][i]['productName'],
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        '${widget.document['products'][i]['qty']} x ${widget.document['products'][i]['price']} = ${widget.document['products'][i]['total']}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ));
                },
                itemCount: widget.document['products'].length,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 8, bottom: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Seller : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.document['seller']['shopName'],
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Delivery Fee : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'RM${widget.document['deliveryFee']}',
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
          statusContainer(widget.document, context),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document['currentOrderStatus'] == 'Accepted') {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
        height: 50,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: FlatButton(
            onPressed: () {
              EasyLoading.show(status: 'Updating Order');
              _firebaseServices
                  .updateOrder(id: document.id, status: 'Picked Up')
                  .then((value) {
                EasyLoading.showSuccess('Order Status is now Picked Up');
              });
            },
            color: statusColors(document),
            child: Text(
              'Update Status to Pick Up',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (document['currentOrderStatus'] == 'Picked Up') {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
        height: 50,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: FlatButton(
            onPressed: () {
              EasyLoading.show(status: 'Updating Order');
              _firebaseServices
                  .updateOrder(id: document.id, status: 'On The Way')
                  .then((value) {
                EasyLoading.showSuccess('Order Status is now On the way');
              });
            },
            color: statusColors(document),
            child: Text(
              'Update Status to On the way',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    if (document['currentOrderStatus'] == 'On The Way') {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
        height: 50,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: FlatButton(
            onPressed: () {
              if (document['cod']) {
                showMyDialog('Order status', 'Delivered', document, context);
              } else {
                EasyLoading.show(status: 'Updating Order');
                _firebaseServices
                    .updateOrder(id: document.id, status: 'Delivered')
                    .then((value) {
                  EasyLoading.showSuccess('Order Status is now Delivered');
                });
              }
            },
            color: statusColors(document),
            child: Text(
              'Update Status to Delivered',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (document['currentOrderStatus'] == 'Delivered') {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
        height: 50,
        child: FlatButton(
          onPressed: () {},
          color: statusColors(document),
          child: Text(
            'Order Completed',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[300],
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () {
                  showMyDialog('Accept Order', 'Accepted', document, context);
                },
                color: Colors.blue,
                child: Text(
                  'Accept',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AbsorbPointer(
                absorbing:
                    document['currentOrderStatus'] == 'Rejected' ? true : false,
                child: FlatButton(
                  onPressed: () {
                    showMyDialog('Reject Order', 'Rejected', document, context);
                  },
                  color: document['currentOrderStatus'] == 'Rejected'
                      ? Colors.grey
                      : Colors.red,
                  child: Text(
                    'Reject',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showMyDialog(title, status, document, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(
                'Make sure you have received payment (RM ${document['total']})'),
            actions: [
              FlatButton(
                  onPressed: () {
                    EasyLoading.show(status: 'Updating Status');
                    _firebaseServices
                        .updateOrder(id: document.id, status: 'Delivered')
                        .then((value) {
                      EasyLoading.showSuccess('Order status is now Delivered');
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'RECEIVE',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          );
        });
  }

  void _launchURL(number) async {
    if (!await launch('tel:$number')) throw 'Could not launch $number';
  }
}
