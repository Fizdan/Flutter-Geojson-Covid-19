import 'package:local_notifications/covid.dart';
import 'package:local_notifications/faskes.dart';
import 'package:local_notifications/fasum.dart';
import 'package:local_notifications/info_covid.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cegah Covid-19 Surabaya',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Main Menu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _getLocationPermission();
  }

  void _getLocationPermission() async {
    var location = new Location();
    try {
      location.requestPermission();
    } on Exception catch (_) {
      print('There was a problem allowing location access');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: new SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/LogoFinal.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Aplikasi Pemberi Informasi Covid-19',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 80),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Will take 50% of screen space
                  child: RaisedButton(
                    elevation: 0.5,
                    color: Colors.teal,
                    textColor: Colors.white,
                    child: Text("Sebaran Covid-19 Surabaya"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GMap()),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Will take 50% of screen space
                  child: RaisedButton(
                    elevation: 0.5,
                    color: Colors.teal,
                    textColor: Colors.white,
                    child: Text("Sebaran Fasilitas Kesehatan"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Faskes()),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Will take 50% of screen space
                  child: RaisedButton(
                    elevation: 0.5,
                    color: Colors.teal,
                    textColor: Colors.white,
                    child: Text("Sebaran Fasilitas Umum"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Fasum()),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Will take 50% of screen space
                  child: RaisedButton(
                    elevation: 0.5,
                    color: Colors.teal,
                    textColor: Colors.white,
                    child: Text("Info"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InfoCovid()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
