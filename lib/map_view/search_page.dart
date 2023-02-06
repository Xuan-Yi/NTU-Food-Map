import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utility_components/navigation_drawer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<StatefulWidget> {
  List<Map<String, dynamic>> restaurants = List<Map<String, dynamic>>.from([]);
  List<Map<String, dynamic>> _foundRestaurant =
      List<Map<String, dynamic>>.from([]);

  // Grab restaurant from Firestore
  Future<void> _getRestaurants() async {
    final ref = FirebaseFirestore.instance.collection('restaurants');
    final snapshot = await ref.get();
    List<Map<String, dynamic>> restaurantList =
        List<Map<String, dynamic>>.from([]);

    if (snapshot.docs.isNotEmpty) {
      restaurantList = snapshot.docs
          .map((e) => Map<String, dynamic>.from(e.data()))
          .toList();
      final List<String> idList = snapshot.docs.map((e) => e.id).toList();
      for (int i = 0; i < restaurantList.length; i++) {
        restaurantList[i]['coordinate'] = LatLng(
            restaurantList[i]['coordinate'].latitude,
            restaurantList[i]['coordinate'].longitude);
        restaurantList[i].addAll({'id': idList[i]});
      }
    }

    setState(() {
      restaurants = restaurantList;
      _foundRestaurant = restaurantList;
    });
  }

  @override
  void initState() {
    _getRestaurants();
    super.initState();
  }

  // Search bar filter
  void _runFilter(String enterKeyword) {
    final keywords =
        enterKeyword.replaceAll(RegExp(r"\s+\b|\b\s"), ' ').split(' ');
    List<Map<String, dynamic>> results = [];

    if (enterKeyword.isEmpty) {
      results = restaurants;
    } else {
      results = restaurants.where((res) {
        bool allMatch = true;
        for (int i = 0; i < keywords.length; i++) {
          if (!res['name'].toLowerCase().contains(keywords[i].toLowerCase()) &
              !res['address']
                  .toLowerCase()
                  .contains(keywords[i].toLowerCase()) &
              !res['region']
                  .toLowerCase()
                  .contains(keywords[i].toLowerCase())) {
            allMatch = false;
          }
        }
        return allMatch;
      }).toList();
    }
    setState(() {
      _foundRestaurant = results;
    });
  }

  Future<bool> _requestPop() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/map');
    return Future.value(false);
  }

  @override
  Widget build(context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
        ),
        resizeToAvoidBottomInset: false,
        drawer: const MyNavigationDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => _runFilter(value),
                  cursorColor: Colors.grey,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    hintText: 'Search',
                    hintMaxLines: 2,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Filtered available restaurants
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _foundRestaurant.length,
                  itemBuilder: ((context, index) => TextButton(
                        onLongPress: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Claim ownership'),
                            content: const Text(
                                'Do you want to claim ownership to this restaurant?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  // Update document (user)
                                  final user =
                                      FirebaseAuth.instance.currentUser!;
                                  final docUser = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid);
                                  final snapshot = await docUser.get();
                                  List<String> myRestaurants =
                                      List<String>.from(
                                          snapshot.data()!['my restaurants']);
                                  myRestaurants.add(restaurants[index]['id']);

                                  docUser.update({
                                    'my restaurants':
                                        myRestaurants.toSet().toList()
                                  }); // remove duplicates
                                  Navigator.pop(context);
                                },
                                child: const Text('Yes',
                                    style: TextStyle(color: Colors.green)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('No',
                                    style: TextStyle(color: Colors.green)),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          // more response here
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/map',
                              arguments: restaurants[index]);
                          // show restaurant name
                          Fluttertoast.showToast(
                              msg: restaurants[index]['name'].toString(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        },
                        child: Card(
                          key: ValueKey(restaurants[index]['name']),
                          color: Colors.green,
                          elevation: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          child: ListTile(
                            leading: Container(
                              constraints: const BoxConstraints(maxWidth: 96),
                              child: Text(
                                _foundRestaurant[index]['region'],
                                maxLines: 1,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 24,
                                    color: Colors.white),
                              ),
                            ),
                            title: Text(
                              _foundRestaurant[index]['name'],
                              maxLines: 1,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              _foundRestaurant[index]['address'],
                              maxLines: 1,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
