import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/contributor_edit_widget.dart';
import '../components/navigation_drawer.dart';

class ContributeAndEditPage extends StatefulWidget {
  const ContributeAndEditPage({super.key});

  @override
  State<ContributeAndEditPage> createState() => _ContributeAndEditPageState();
}

class _ContributeAndEditPageState extends State<ContributeAndEditPage> {
  final bool _isOwner = false; // grab from database later

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.start,
                buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text(
                    'I am',
                    style: TextStyle(fontSize: 16),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.storefront),
                    onPressed: () {
                      if (_isOwner) {
                        // can edit
                      } else {
                        // apply for edit permissions and upload related proofs
                      }
                    },
                    label: const Text('Owner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOwner ? Colors.green : Colors.grey,
                      shadowColor: Colors.orange,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.group),
                    onPressed: () {},
                    label: const Text('Contributor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shadowColor: Colors.orange,
                    ),
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
              const ContributeEditWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
