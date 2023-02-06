import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../components/navigation_drawer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<StatefulWidget> {
  List<Map<String, dynamic>> restaurants = [
    {
      'name': '食香園素食',
      'address': '06台北市大安區羅斯福路四段1號',
      'region': '活大',
      'coordinate': LatLng(25.01828119432962, 121.54034891272644)
    },
    {
      'name': '鍋in',
      'address': '100台北市中正區汀州路三段196號',
      'region': '公館',
      'coordinate': LatLng(25.012594827336873, 121.53533484156256)
    },
    {
      'name': '梧貳WUERFOODS(歐姆蛋包飯專賣店)',
      'address': '臺北市大安區和平東路二段311巷7號',
      'region': '118巷',
      'coordinate': LatLng(25.025340524746174, 121.54519113970983)
    },
    {
      'name': '韓庭州韓國料理',
      'address': '溫州街87號',
      'region': '溫州街',
      'coordinate': LatLng(25.01937031445742, 121.53287562436525)
    },
  ];
  List<Map<String, dynamic>> _foundRestaurant = [];

  @override
  void initState() {
    super.initState();
    _foundRestaurant = restaurants;
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
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
