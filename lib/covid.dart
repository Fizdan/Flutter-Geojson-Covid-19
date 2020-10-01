import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:local_notifications/my_icons_covid_icons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GMap(),
    );
  }
}

class GMap extends StatefulWidget {
  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  // Data Location
  final Location location = Location();
  LocationData _location;
  String _error;

  // Data Polygon
  var dataJson;
  var dataCovid;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  BitmapDescriptor _markerIcon;
  var polygonNotif = List();
  var listKelurahan = List();
  var listKonfirmasi = List();
  var listODP = List();
  var listPDP = List();
  var lastPosition;

  @override
  void initState() {
    super.initState();
    initializing();
    _notifAwal();
    _setKonfirmasi();
  }

  void _notifAwal() async {
    _getLocation()
        .then((success) => print('Success'))
        .catchError((e) => print(e))
        .whenComplete(() {
      _setPolygon()
          .then((success) => print('Success'))
          .catchError((e) => print(e))
          .whenComplete(() {
        _showNotifications();
      });
    });
  }

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    dataJson = await rootBundle.loadString('assets/SurabayaCovidWarna.json');
    dataCovid = json.decode(dataJson);
  }

  void _showNotifications() async {
    await notification();
  }

  void _showNotificationsAfterSecond() async {
    await notificationAfterSec();
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  Future<void> _setPolygon() async {
    final geo = GeoJson();
    var kelurahan;
    var konfirmasi;
    var odp;
    var pdp;

    List<LatLng> polygonLatLongsData = List<LatLng>();
    geo.processedMultipolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);

        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
          polygonLatLongsData = [];
          var jsonDecodeList = geoSerie.toLatLng();

          for (var i = 0; i < jsonDecodeList.length; i++) {
            var ltlng =
                LatLng(jsonDecodeList[i].latitude, jsonDecodeList[i].longitude);

            polygonLatLongsData.add(ltlng);
          }

          for (var j = 0; j < dataCovid['Sheet1'].length; j++) {
            if (dataCovid['Sheet1'][j]['Kelurahan'] == geoSerie.name) {
              kelurahan = dataCovid['Sheet1'][j]['Kelurahan'];
              konfirmasi = dataCovid['Sheet1'][j]['Konfirmasi'];
              odp = dataCovid['Sheet1'][j]['ODP'];
              pdp = dataCovid['Sheet1'][j]['PDP'];
            }
          }

          setState(() {
            polygonNotif.add(polygonLatLongsData);
            listKelurahan.add(kelurahan);
            listKonfirmasi.add(konfirmasi);
            listODP.add(odp);
            listPDP.add(pdp);
          });
        }
      }
    });
    geo.endSignal.listen((_) => geo.dispose());
    final nameProperty = "Name";
    final data =
        await rootBundle.loadString('assets/Sebaran_Covid_Surabaya.geojson');
    await geo.parse(data, nameProperty: nameProperty, verbose: true);
  }

  Future<void> notification() async {
    var dataLat = _location.latitude;
    var dataLng = _location.longitude;
    var currentPosition = LatLng(dataLat, dataLng);
    String content = 'Data tidak tersedia';
    String header = 'Anda berada Diluar Surabaya';

    for (var i = 0; i < polygonNotif.length; i++) {
      if (_checkIfValidMarker(currentPosition, polygonNotif[i])) {
        header = "Anda Didalam Kelurahan " + listKelurahan[i];
        content = 'ODP : ' +
            listODP[i] +
            ', PDP : ' +
            listPDP[i] +
            ', Konfirmasi : ' +
            listKonfirmasi[i];
      }
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, header, content, notificationDetails);
  }

  Future<void> notificationAfterSec() async {
    var timeDelayed = DateTime.now().add(Duration(seconds: 5));
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'second channel ID', 'second Channel title', 'second channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(1, 'Hello there',
        'please subscribe my channel', timeDelayed, notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }

    // we can set navigator to navigate another screen
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  Future<void> _setKonfirmasi() async {
    final geo = GeoJson();

    final dataJson =
        await rootBundle.loadString('assets/SurabayaCovidWarna.json');
    final dataWarna = json.decode(dataJson);

    List<LatLng> polygonLatLongsData = List<LatLng>();
    geo.processedMultipolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);

        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
          polygonLatLongsData = [];
          var jsonDecodeList = geoSerie.toLatLng();
          //print('/////////////');
          //print(polygonFeature["properties"]);
          //print('/////////////');

          for (var i = 0; i < jsonDecodeList.length; i++) {
            var ltlng =
                LatLng(jsonDecodeList[i].latitude, jsonDecodeList[i].longitude);

            polygonLatLongsData.add(ltlng);
          }

          var color = Colors.red.withOpacity(0.7);

          var kecamatan;

          var konfirmasi;
          var konfirmasisembuh;
          var konfirmasimeninggal;

          var odp;
          var odpselesai;
          var odpmeninggal;

          var pdp;
          var pdpsembuh;
          var pdpmeninggal;

          var datapertanggal;
          var sumber;

          for (var j = 0; j < dataWarna['Sheet1'].length; j++) {
            int enol = 0;
            if (dataWarna['Sheet1'][j]['Kelurahan'] == geoSerie.name) {
              kecamatan = dataWarna['Sheet1'][j]['Kecamatan'];

              konfirmasi = dataWarna['Sheet1'][j]['Konfirmasi'];
              konfirmasisembuh = dataWarna['Sheet1'][j]['Konfirmasi Sembuh'];
              konfirmasimeninggal =
                  dataWarna['Sheet1'][j]['Konfirmasi Meninggal'];

              odp = dataWarna['Sheet1'][j]['ODP'];
              odpselesai = dataWarna['Sheet1'][j]['ODP Selesai Dipantau'];
              odpmeninggal = dataWarna['Sheet1'][j]['ODP Meninggal'];

              pdp = dataWarna['Sheet1'][j]['PDP'];
              pdpsembuh = dataWarna['Sheet1'][j]['PDP Sembuh'];
              pdpmeninggal = dataWarna['Sheet1'][j]['PDP Meninggal'];

              datapertanggal = dataWarna['Sheet1'][j]['Data Per Tanggal'];
              sumber = dataWarna['Sheet1'][j]['Sumber'];

              int angka =
                  int.parse(dataWarna['Sheet1'][j]['Kode Warna Konfirmasi']);
              //print(angka);
              if (angka == enol) {
                color = Colors.red.withOpacity(0.7);
              } else if (angka == 700) {
                color = Colors.deepOrange[angka].withOpacity(0.7);
              } else {
                color = Colors.red[angka].withOpacity(0.7);
              }
            }
          }

          setState(() => _polygons.add(
                Polygon(
                  polygonId: PolygonId(geoSerie.name),
                  points: polygonLatLongsData,
                  fillColor: color,
                  strokeWidth: 1,
                  consumeTapEvents: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal,
                                width: 8,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "",
                                  ),
                                  Text(
                                    "Kelurahan : " + geoSerie.name + "",
                                  ),
                                  Text(
                                    "Kecamatan : " + kecamatan + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "ODP : " + odp + "",
                                  ),
                                  Text(
                                    "ODP Selesai : " + odpselesai + "",
                                  ),
                                  Text(
                                    "ODP  Meninggal: " + odpmeninggal + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "PDP : " + pdp + "",
                                  ),
                                  Text(
                                    "PDP Sembuh : " + pdpsembuh + "",
                                  ),
                                  Text(
                                    "PDP  Meninggal: " + pdpmeninggal + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "Konfirmasi : " + konfirmasi + "",
                                  ),
                                  Text(
                                    "Konfirmasi Sembuh : " +
                                        konfirmasisembuh +
                                        "",
                                  ),
                                  Text(
                                    "Konfirmasi  Meninggal: " +
                                        konfirmasimeninggal +
                                        "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "Data Per Tanggal : " + datapertanggal + "",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ));
        }
      }
    });
    geo.endSignal.listen((_) => geo.dispose());
    final nameProperty = "Name";
    final data =
        await rootBundle.loadString('assets/Sebaran_Covid_Surabaya.geojson');
    await geo.parse(data, nameProperty: nameProperty, verbose: true);
    for (var item in _polygons) {
      print(item.polygonId.toString() + ',' + item.fillColor.toString());
    }
    print(_polygons.length);
  }

  Future<void> _setPDP() async {
    final geo = GeoJson();

    final dataJson =
        await rootBundle.loadString('assets/SurabayaCovidWarna.json');
    final dataWarna = json.decode(dataJson);

    List<LatLng> polygonLatLongsData = List<LatLng>();
    geo.processedMultipolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);

        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
          polygonLatLongsData = [];
          var jsonDecodeList = geoSerie.toLatLng();
          //print('/////////////');
          //print(polygonFeature["properties"]);
          //print('/////////////');

          for (var i = 0; i < jsonDecodeList.length; i++) {
            var ltlng =
                LatLng(jsonDecodeList[i].latitude, jsonDecodeList[i].longitude);

            polygonLatLongsData.add(ltlng);
          }

          var color = Colors.red.withOpacity(0.7);

          var kecamatan;

          var konfirmasi;
          var konfirmasisembuh;
          var konfirmasimeninggal;

          var odp;
          var odpselesai;
          var odpmeninggal;

          var pdp;
          var pdpsembuh;
          var pdpmeninggal;

          var datapertanggal;
          var sumber;

          for (var j = 0; j < dataWarna['Sheet1'].length; j++) {
            int enol = 0;
            if (dataWarna['Sheet1'][j]['Kelurahan'] == geoSerie.name) {
              kecamatan = dataWarna['Sheet1'][j]['Kecamatan'];

              konfirmasi = dataWarna['Sheet1'][j]['Konfirmasi'];
              konfirmasisembuh = dataWarna['Sheet1'][j]['Konfirmasi Sembuh'];
              konfirmasimeninggal =
                  dataWarna['Sheet1'][j]['Konfirmasi Meninggal'];

              odp = dataWarna['Sheet1'][j]['ODP'];
              odpselesai = dataWarna['Sheet1'][j]['ODP Selesai Dipantau'];
              odpmeninggal = dataWarna['Sheet1'][j]['ODP Meninggal'];

              pdp = dataWarna['Sheet1'][j]['PDP'];
              pdpsembuh = dataWarna['Sheet1'][j]['PDP Sembuh'];
              pdpmeninggal = dataWarna['Sheet1'][j]['PDP Meninggal'];

              datapertanggal = dataWarna['Sheet1'][j]['Data Per Tanggal'];
              sumber = dataWarna['Sheet1'][j]['Sumber'];

              int angka = int.parse(dataWarna['Sheet1'][j]['Kode Warna PDP']);
              //print(angka);
              if (angka == enol) {
                color = Colors.red.withOpacity(0.7);
              } else if (angka == 700) {
                color = Colors.deepOrange[angka].withOpacity(0.7);
              } else {
                color = Colors.red[angka].withOpacity(0.7);
              }
            }
          }

          setState(() => _polygons.add(
                Polygon(
                  polygonId: PolygonId(geoSerie.name),
                  points: polygonLatLongsData,
                  fillColor: color,
                  strokeWidth: 1,
                  consumeTapEvents: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal,
                                width: 8,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "",
                                  ),
                                  Text(
                                    "Kelurahan : " + geoSerie.name + "",
                                  ),
                                  Text(
                                    "Kecamatan : " + kecamatan + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "ODP : " + odp + "",
                                  ),
                                  Text(
                                    "ODP Selesai : " + odpselesai + "",
                                  ),
                                  Text(
                                    "ODP  Meninggal: " + odpmeninggal + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "PDP : " + pdp + "",
                                  ),
                                  Text(
                                    "PDP Sembuh : " + pdpsembuh + "",
                                  ),
                                  Text(
                                    "PDP  Meninggal: " + pdpmeninggal + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "Konfirmasi : " + konfirmasi + "",
                                  ),
                                  Text(
                                    "Konfirmasi Sembuh : " +
                                        konfirmasisembuh +
                                        "",
                                  ),
                                  Text(
                                    "Konfirmasi  Meninggal: " +
                                        konfirmasimeninggal +
                                        "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "Data Per Tanggal : " + datapertanggal + "",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ));
        }
      }
    });
    geo.endSignal.listen((_) => geo.dispose());
    final nameProperty = "Name";
    final data =
        await rootBundle.loadString('assets/Sebaran_Covid_Surabaya.geojson');
    await geo.parse(data, nameProperty: nameProperty, verbose: true);
  }

  Future<void> _setODP() async {
    final geo = GeoJson();

    final dataJson =
        await rootBundle.loadString('assets/SurabayaCovidWarna.json');
    final dataWarna = json.decode(dataJson);

    List<LatLng> polygonLatLongsData = List<LatLng>();
    geo.processedMultipolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      for (final polygon in multiPolygon.polygons) {
        final geoSerie = GeoSerie(
            type: GeoSerieType.polygon,
            name: polygon.geoSeries[0].name,
            geoPoints: <GeoPoint>[]);

        for (final serie in polygon.geoSeries) {
          geoSerie.geoPoints.addAll(serie.geoPoints);
          polygonLatLongsData = [];
          var jsonDecodeList = geoSerie.toLatLng();
          //print('/////////////');
          //print(polygonFeature["properties"]);
          //print('/////////////');

          for (var i = 0; i < jsonDecodeList.length; i++) {
            var ltlng =
                LatLng(jsonDecodeList[i].latitude, jsonDecodeList[i].longitude);

            polygonLatLongsData.add(ltlng);
          }

          var color = Colors.red.withOpacity(0.7);

          var kecamatan;

          var konfirmasi;
          var konfirmasisembuh;
          var konfirmasimeninggal;

          var odp;
          var odpselesai;
          var odpmeninggal;

          var pdp;
          var pdpsembuh;
          var pdpmeninggal;

          var datapertanggal;
          var sumber;

          for (var j = 0; j < dataWarna['Sheet1'].length; j++) {
            int enol = 0;
            if (dataWarna['Sheet1'][j]['Kelurahan'] == geoSerie.name) {
              kecamatan = dataWarna['Sheet1'][j]['Kecamatan'];

              konfirmasi = dataWarna['Sheet1'][j]['Konfirmasi'];
              konfirmasisembuh = dataWarna['Sheet1'][j]['Konfirmasi Sembuh'];
              konfirmasimeninggal =
                  dataWarna['Sheet1'][j]['Konfirmasi Meninggal'];

              odp = dataWarna['Sheet1'][j]['ODP'];
              odpselesai = dataWarna['Sheet1'][j]['ODP Selesai Dipantau'];
              odpmeninggal = dataWarna['Sheet1'][j]['ODP Meninggal'];

              pdp = dataWarna['Sheet1'][j]['PDP'];
              pdpsembuh = dataWarna['Sheet1'][j]['PDP Sembuh'];
              pdpmeninggal = dataWarna['Sheet1'][j]['PDP Meninggal'];

              datapertanggal = dataWarna['Sheet1'][j]['Data Per Tanggal'];
              sumber = dataWarna['Sheet1'][j]['Sumber'];

              int angka = int.parse(dataWarna['Sheet1'][j]['Kode Warna ODP']);
              //print(angka);
              if (angka == enol) {
                color = Colors.red.withOpacity(0.7);
              } else if (angka == 700) {
                color = Colors.deepOrange[angka].withOpacity(0.7);
              } else {
                color = Colors.red[angka].withOpacity(0.7);
              }
            }
          }

          setState(() => _polygons.add(
                Polygon(
                  polygonId: PolygonId(geoSerie.name),
                  points: polygonLatLongsData,
                  fillColor: color,
                  strokeWidth: 1,
                  consumeTapEvents: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.teal,
                                width: 8,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "",
                                  ),
                                  Text(
                                    "Kelurahan : " + geoSerie.name + "",
                                  ),
                                  Text(
                                    "Kecamatan : " + kecamatan + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "ODP : " + odp + "",
                                  ),
                                  Text(
                                    "ODP Selesai : " + odpselesai + "",
                                  ),
                                  Text(
                                    "ODP  Meninggal: " + odpmeninggal + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "PDP : " + pdp + "",
                                  ),
                                  Text(
                                    "PDP Sembuh : " + pdpsembuh + "",
                                  ),
                                  Text(
                                    "PDP  Meninggal: " + pdpmeninggal + "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "Konfirmasi : " + konfirmasi + "",
                                  ),
                                  Text(
                                    "Konfirmasi Sembuh : " +
                                        konfirmasisembuh +
                                        "",
                                  ),
                                  Text(
                                    "Konfirmasi  Meninggal: " +
                                        konfirmasimeninggal +
                                        "",
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    "Data Per Tanggal : " + datapertanggal + "",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ));
        }
      }
    });
    geo.endSignal.listen((_) => geo.dispose());
    final nameProperty = "Name";
    final data =
        await rootBundle.loadString('assets/Sebaran_Covid_Surabaya.geojson');
    await geo.parse(data, nameProperty: nameProperty, verbose: true);
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
            icon: _markerIcon),
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
              polygons: _polygons,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Stack(
          children: <Widget>[
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
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.teal,
                                  width: 8,
                                ),
                                image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/IsiCovid.jpg'),
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
            Align(
              alignment: Alignment(1, -0.4),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FloatingActionButton(
                  child: new Icon(Icons.equalizer),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.32,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.teal,
                                  width: 1,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/IsiTotalSby.jpg'),
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
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.extended(
                icon: Icon(MyIconsCovid.icon_pdp),
                label: Text('PDP'),
                onPressed: () {
                  setState(() {
                    _polygons.clear();
                  });
                  _setPDP();
                },
                heroTag: null,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                icon: Icon(MyIconsCovid.icon_odp),
                label: Text('ODP'),
                onPressed: () {
                  setState(() {
                    _polygons.clear();
                  });
                  _setODP();
                },
                heroTag: null,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                icon: Icon(MyIconsCovid.icon_konfirm),
                label: Text('Konfirmasi'),
                onPressed: () {
                  setState(() {
                    _polygons.clear();
                  });
                  _setKonfirmasi();
                },
                heroTag: null,
              ),
            ),
          ],
        ));
  }
}
