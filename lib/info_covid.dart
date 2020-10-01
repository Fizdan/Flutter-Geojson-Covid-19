import 'package:flutter/material.dart';

class InfoCovid extends StatefulWidget {
  InfoCovid({Key key}) : super(key: key);

  @override
  _InfoCovidState createState() => _InfoCovidState();
}

class _InfoCovidState extends State<InfoCovid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: new SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Coronavirus disease 2019 (COVID-19) adalah penyakit pernapasan yang dapat menyebar dari orang ke orang. Virus ini diperkirakan menyebar terutama di antara orang-orang yang berhubungan dekat satu sama lain dalam jarak kurang lebih 2 meter melalui udara yang dihasilkan ketika orang yang terinfeksi batuk atau bersin. Seseorang dapat terkena Covid-19 dengan menyentuh permukaan atau benda yang memiliki virus di atasnya dan kemudian menyentuh mulut, hidung, atau mata mereka sendiri',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Protokol kesehatan',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  '•	Selalu gunakan masker, ditambah dengan face shield jika diperlukan \n•	Jaga kebersihan tempat tinggal, tempat kerja, dan tempat umum \n•	Jaga kebersihan diri dengan cuci tangan dengan benar selama 20 detik atau gunakan hand sanitizer \n•	Jauhi kerumunan \n•	Kurangi menyentuh area mulut, hidung, dan mata \n•	Minimalisir bersentuhan dan berdekatan dengan orang lain. \n•	Berjemur matahari pada pagi atau sore hari \n•	Hindari ruangan berlembab. \n',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Virus Corona dapat bertahan hidup pada benda dengan jangka waktu yang berbeda, dan untuk membunuh dapat menggunakan cairan desinfektan.',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  '•	Alumunium: 2 – 8 jam \n•	Sarung tangan operasi: sekitar 8 jam \n•	Besi: 4 – 8 jam \n•	Kayu: sekitar 4 hari \n•	Kaca: sekitar 4 hari \n•	Kertas: 4 – 5 hari \n•	Plastik: sekitar 5 hari \n ',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Istilah dalam Covid-19',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  '•	ODP (Orang Dalam Pengawasan) \nODP merupakan istilah yang digunakan untuk mengelompokkan individu berdasarkan beberapa hal seperti gejala demam atau gangguan pernapasan. Memiliki riwayat perjalanan ke daerah yang telah terinfeksi. Memiliki riwayat kontak dengan orang yang terinfeksi. Harus melakukan isolasi mandiri selama 14 hari dan jika kondisi memburuk perlu dilakukan tes laboraturium. Pada 13 Juli 2020 Kemenkes mengubah istilah ini menjadi “Kontak Erat”.',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  '•	PDP (Pasien Dalam Pengawasan) \nSama seperti ODP namun memiliki gejala demam dan gangguan pernapasan. Harus dilakukan rawat inap dan isolasi di rumah sakit dan wajib dilakukan tes laboratorium. Pada 13 Juli 2020 Kemenkes mengubah istilah ini menjadi “Kasus Suspect”.',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  '•	OTG (Orang Tanpa Gejala) \nSeseorang yang tidak memiliki gejala Covid-19, namun memiliki risiko tertular dari orang positif Covid -19. Dan juga orang tanpa gejala yang memiliki kontak erat dengan kasus positif Covid-19. Pada 13 Juli 2020 Kemenkes mengubah istilah ini menjadi “Kasus Probable”.',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  '•	Kasus Konfirmasi \nSeseorang terinfeksi Covid-19 dengan hasil pemeriksaan laboratorium positif.',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Gejala Covid-19',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  '•	Demam mencapai 38 derajat celcius \n•	Batuk kering \n•	Sakit tenggorokan \n•	Sakit kepala \n•	Lemas \n•	Sesak napas \n ',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Call Center Covid-19 Surabaya: 112',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Call Center Covid-19 Jawa Timur: 1500 117',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
