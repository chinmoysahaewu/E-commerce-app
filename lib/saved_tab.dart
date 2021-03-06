import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/product_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'custom_action_bar.dart';


class SavedTab extends StatelessWidget {

  final CollectionReference _productsRef =
  FirebaseFirestore.instance.collection("Products");

  final CollectionReference _usersRef =
  FirebaseFirestore.instance.collection("Users");

  final User _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          FutureBuilder<QuerySnapshot>(
              future: _usersRef
                  .doc(_user.uid)
                  .collection("Saved")
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView(
                    padding: EdgeInsets.only(
                      top: 108.0,
                      bottom: 12.0,
                    ),
                    children: snapshot.data.docs.map((document) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductPage(
                                  productId: document.id,
                                ),
                              ));
                        },
                        child: FutureBuilder(
                          future: _productsRef
                              .doc(document.id)
                              .get(),
                          builder: (context, productSnap) {
                            if (productSnap.hasError) {
                              return Container(
                                child: Center(
                                  child: Text("${productSnap.error}"),
                                ),
                              );
                            }
                            if (productSnap.connectionState ==
                                ConnectionState.done) {
                              Map _productMap = productSnap.data.data();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 24.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(8.0),
                                        child: Image.network(
                                          "${_productMap['images'][0]}",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 16.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text("${_productMap['name']}",
                                              style: Constants.regularHeading),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            child: Text(
                                              "\$${_productMap['price']}",
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Theme.of(context).accentColor,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                            return Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }

                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }),
          CustomActionBar(
            title: "Saved",
            hasBackArrow: false,
          )
        ],
      ),
    );
  }
}
