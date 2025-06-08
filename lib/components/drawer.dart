import 'package:demo_nckh/authentication/auth_service.dart';
import 'package:demo_nckh/authentication/login_or_register.dart';
import 'package:demo_nckh/screens/identify/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:demo_nckh/screens/settings_screen.dart';
import '../screens/mode_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // void logout() {
  //   // Get auth service
  //   final _auth = AuthService();
  //   _auth.signOut();
  // }

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
                    "M O D E",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  leading: Icon(Icons.mode),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ModeScreen()),
                    );
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

          // // PHẦN DƯỚI: LOGOUT
          // Padding(
          //   padding: EdgeInsets.only(left: 25.0, bottom: 60),
          //   child: ListTile(
          //     title: Text(
          //       "L O G O U T",
          //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          //     ),
          //     leading: Icon(Icons.logout),
          //     onTap: logout,
          //   ),
          // ),
        ],
      ),
    );
  }
}
