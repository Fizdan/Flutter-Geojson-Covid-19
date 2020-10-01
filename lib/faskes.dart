import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;

class Faskes extends StatefulWidget {
  Faskes({Key key}) : super(key: key);

  @override
  _FaskesState createState() => _FaskesState();
}

class _FaskesState extends State<Faskes> {
  Set<Marker> _markers = HashSet<Marker>();

  @override
  void initState() {
    super.initState();
    _setRumahSakit();
    _setPuskesmas();
  }

  Future<void> _setRumahSakit() async {
    BitmapDescriptor _rsIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 0.5), 'assets/Rumahsakit.png');
    final data = await rootBundle.loadString('assets/RumahSakit.json');
    final dataPuskesmas = json.decode(data);
    for (var i = 0; i < dataPuskesmas["Sheet 1"].length; i++) {
      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId(dataPuskesmas["Sheet 1"][i]["Name"]),
              position: LatLng(
                  double.parse(dataPuskesmas["Sheet 1"][i]["latitude"]),
                  double.parse(dataPuskesmas["Sheet 1"][i]["longitude"])),
              infoWindow: InfoWindow(
                title: dataPuskesmas["Sheet 1"][i]["Name"],
                snippet: dataPuskesmas["Sheet 1"][i]["Alamat"],
              ),
              icon: _rsIcon),
        );
      });
    }
  }

  Future<void> _setPuskesmas() async {
    BitmapDescriptor _rsIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 0.5), 'assets/Puskesmas3.png');
    final data = await rootBundle.loadString('assets/Puskesmas.json');
    final dataPuskesmas = json.decode(data);
    for (var i = 0; i < dataPuskesmas["Sheet 1"].length; i++) {
      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId(dataPuskesmas["Sheet 1"][i]["Name"]),
              position: LatLng(
                  double.parse(dataPuskesmas["Sheet 1"][i]["latitude"]),
                  double.parse(dataPuskesmas["Sheet 1"][i]["longitude"])),
              infoWindow: InfoWindow(
                title: dataPuskesmas["Sheet 1"][i]["Name"],
                snippet: dataPuskesmas["Sheet 1"][i]["Alamat"],
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
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal,
                                width: 1,
                              ),
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/IsiFaskes.jpg'),
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
