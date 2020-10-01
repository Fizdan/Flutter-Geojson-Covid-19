import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;

class Fasum extends StatefulWidget {
  Fasum({Key key}) : super(key: key);

  @override
  _FasumState createState() => _FasumState();
}

class _FasumState extends State<Fasum> {
  Set<Marker> _markers = HashSet<Marker>();

  @override
  void initState() {
    super.initState();
    _setHandSanitizer();
    _setBilik();
    _setWastafel();
  }

  Future<void> _setHandSanitizer() async {
    BitmapDescriptor _hsIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/Handsan3.png');
    final data = await rootBundle.loadString('assets/HandSanitizer.json');
    final dataHandSanitizer = json.decode(data);
    for (var i = 0; i < dataHandSanitizer.length; i++) {
      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId(dataHandSanitizer[i]["Lokasi"]),
              position: LatLng(dataHandSanitizer[i]["Lintang"],
                  dataHandSanitizer[i]["Bujur"]),
              infoWindow: InfoWindow(
                title: dataHandSanitizer[i]["Lokasi"],
                snippet: dataHandSanitizer[i]["Alamat"],
              ),
              icon: _hsIcon),
        );
      });
    }
  }

  Future<void> _setBilik() async {
    BitmapDescriptor _rsIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/Bilik3.png');
    final data = await rootBundle.loadString('assets/BilikSterilisasi.json');
    final dataBilik = json.decode(data);
    for (var i = 0; i < dataBilik.length; i++) {
      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId(dataBilik[i]["Lokasi"]),
              position: LatLng(dataBilik[i]["Lintang"], dataBilik[i]["Bujur"]),
              infoWindow: InfoWindow(
                title: dataBilik[i]["Lokasi"],
                snippet: dataBilik[i]["Alamat"],
              ),
              icon: _rsIcon),
        );
      });
    }
  }

  Future<void> _setWastafel() async {
    BitmapDescriptor _rsIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/Wastafel3.png');
    final data = await rootBundle.loadString('assets/Wastafel.json');
    final dataWastafel = json.decode(data);
    for (var i = 0; i < dataWastafel.length; i++) {
      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId(dataWastafel[i]["Lokasi"]),
              position:
                  LatLng(dataWastafel[i]["Lintang"], dataWastafel[i]["Bujur"]),
              infoWindow: InfoWindow(
                title: dataWastafel[i]["Lokasi"],
                snippet: dataWastafel[i]["Alamat"],
              ),
              icon: _rsIcon),
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("0"),
          position: LatLng(37.77483, -122.41942),
          infoWindow: InfoWindow(
            title: "San Francsico",
            snippet: "An Interesting city",
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Map')),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(-7.2575, 112.7521),
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            // Container(
            //  alignment: Alignment.bottomCenter,
            //  padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
            //  child: Text("Coding with Curry"),
            //)
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Stack(children: <Widget>[
          Align(
            alignment: Alignment(1, -0.6),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton(
                child: new Icon(Icons.info),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal,
                                width: 1,
                              ),
                              image: DecorationImage(
                                image: AssetImage('assets/images/IsiFasum.jpg'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        );
                      });
                },
                heroTag: null,
              ),
            ),
          ),
        ]));
  }
}
