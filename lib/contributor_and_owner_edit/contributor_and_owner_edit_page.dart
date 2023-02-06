import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utility_components/navigation_drawer.dart';
import 'owner_edit_widget.dart';
import 'contributor_edit_widget.dart';

class ContributeAndEditPage extends StatefulWidget {
  const ContributeAndEditPage({super.key});

  @override
  State<ContributeAndEditPage> createState() => _ContributeAndEditPageState();
}

class _ContributeAndEditPageState extends State<ContributeAndEditPage> {
  bool atOwnerPage = false;

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.fastfood),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "NTU Food Map",
                  style: GoogleFonts.sofia(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      drawer: const MyNavigationDrawer(),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.start,
                buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text(
                    'I am',
                    style: TextStyle(fontSize: 16),
                  ),
                  // Contributor button
                  ElevatedButton.icon(
                    icon: Icon(Icons.group,
                        color: atOwnerPage ? Colors.green : Colors.white),
                    onPressed: () => setState(() => atOwnerPage = false),
                    label: Text(
                      'Contributor',
                      style: TextStyle(
                          color: atOwnerPage ? Colors.green : Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            atOwnerPage ? Colors.white : Colors.green,
                        shadowColor: Colors.orange,
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Colors.green))),
                  ),
                  // Owner button
                  ElevatedButton.icon(
                    icon: Icon(Icons.storefront,
                        color: atOwnerPage ? Colors.white : Colors.green),
                    onPressed: () => setState(() => atOwnerPage = true),
                    label: Text(
                      'Owner',
                      style: TextStyle(
                          color: atOwnerPage ? Colors.white : Colors.green),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            atOwnerPage ? Colors.green : Colors.white,
                        shadowColor: Colors.orange,
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Colors.green))),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: .5,
                  height: .5,
                  color: Colors.grey,
                ),
              ),
              Container(
                child: atOwnerPage
                    ? const MyRestaurantList()
                    : const ContributeButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
