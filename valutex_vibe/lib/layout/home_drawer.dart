import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';

class HomeDrawer extends StatelessWidget {
  final Map settings;

  HomeDrawer({
    Key key,
    @required this.settings,
  })  : assert(settings != null),
        super(key: key);

  void _openSettingsScreen(BuildContext context) async {
    //final newCurrencyList =
    await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(settings: settings),
          ),
        );
    //callback(newCountryCurrencyName);
    // Scaffold
    //     .of(context)
    //     .showSnackBar(SnackBar(content: Text("$newCurrencyList")));
  }

  _openEmailApp() async {
    String toAddress = 'valutex.pardut@gmail.com';
    String emailSubject = 'Valutex: About your app...';
    String emailBody = 'Hi...';
    toAddress = Uri.encodeComponent(toAddress);
    emailSubject = Uri.encodeComponent(emailSubject);
    emailBody = Uri.encodeComponent(emailBody);
    String url = 'mailto:$toAddress?subject=$emailSubject&body=$emailBody';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('Valutex', style: TextStyle(fontSize: 30.0)),
                //Container(height: 4.0),
                Text('Currency exchange', style: TextStyle(fontSize: 18.0)),
                Container(height: 16.0),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              _openSettingsScreen(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('About app'),
            onTap: () {
              // Update the state of the app
              // ...
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text('Rate on the store'),
            onTap: () {
              // Update the state of the app
              // ...
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text('Share this app'),
            onTap: () {
              // Update the state of the app
              // ...
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text('Contact developer'),
            onTap: _openEmailApp,
          ),
        ],
      ),
    );
  }
}