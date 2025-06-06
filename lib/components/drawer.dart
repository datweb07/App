import 'package:flutter/material.dart';
import 'package:demo_nckh/screens/settings_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PHẦN TRÊN
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset(
                    'images/iconApp.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0, top: 25.0),
                child: ListTile(
                  title: Text(
                    "H O M E",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  leading: Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: Text(
                    "S E T T I N G S",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context);

                    // Navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settingssreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          // PHẦN DƯỚI: LOGOUT
          Padding(
            padding: EdgeInsets.only(left: 25.0, bottom: 50),
            child: ListTile(
              title: Text(
                "L O G O U T",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              leading: Icon(Icons.logout),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
