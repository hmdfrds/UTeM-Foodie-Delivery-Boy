import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodir_delivery/providers/auth_provider.dart';
import 'package:foodir_delivery/screens/login_screen.dart';
import 'package:foodir_delivery/screens/splash_screen.dart';
import 'package:foodir_delivery/services/firebase_services.dart';
import 'package:foodir_delivery/widgets/order_sumary_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseServices _firebaseServices = FirebaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  String? status = null;
  int tag = 0;
  List<String> options = [
    'All',
    'Accepted',
    'Picked Up',
    'On The Way',
    'Delivered',
  ];

  Color? statusColors(document) {
    if (document['orderStatus'] == 'Rejected') {
      return Colors.red;
    }
    if (document['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }
    if (document['orderStatus'] == 'pickedUp') {
      return Colors.pink[900];
    }
    if (document['orderStatus'] == 'On The Way') {
      return Colors.deepPurpleAccent;
    }
    if (document['orderStatus'] == 'Delivered') {
      return Colors.green;
    }
    return Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: Text("Log out"),
                        content: Text("Are you sure you want to Logout"),
                        actions: [
                          CupertinoDialogAction(
                              child: Text("YES"),
                              onPressed: () {
                                _signOut().then((value) {
                                  Navigator.pushReplacementNamed(
                                      context, SplashScreen.id);
                                });
                                Navigator.of(context).pop();
                              }),
                          CupertinoDialogAction(
                              child: Text("NO"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })
                        ],
                      );
                    });
              },
              icon: Icon(Icons.logout))
        ],
        title: Text(
          'Orders',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.orange[500],
      body: Column(
        children: [
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('boys')
                  .doc(user!.email)
                  .get(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      documentSnapshot) {
                if (documentSnapshot.hasData) {
                  return documentSnapshot.data!.get('accVerified') == true
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.red,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'Your account is not verified',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'Please wait for admin to verify your account',
                                          style: TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                }

                return Container();
              }),
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    tag = val;
                    status = null;
                  });
                } else {
                  setState(() {
                    tag = val;
                    status = options[val];
                  });
                }
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
              choiceStyle: C2ChoiceStyle(
                color: Colors.red,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseServices.orders
                  .where('deliveryBoy.email', isEqualTo: user!.email)
                  .where('currentOrderStatus', isEqualTo: status)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: Text('No $status Orders'),
                  );
                }

                if (snapshot.data!.size == 0) {
                  return Center(
                    child: Text('No $status Orders'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: 8, left: 8, bottom: 8),
                        child: OrderSumarryCard(document: document),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
