import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Laporan {
  final String id;
  final String userid;
  final String KodeLaporan;
  final String JudulLaporan;
  final String IsiLaporan;
  final String kategori;
  final String gambar;

  Laporan(
      {required this.id,
      required this.userid,
      required this.KodeLaporan,
      required this.JudulLaporan,
      required this.IsiLaporan,
      required this.kategori,
      required this.gambar});

  factory Laporan.FromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Laporan(
        id: doc.id,
        userid: data['userid'],
        KodeLaporan: data['KodeLaporan'],
        JudulLaporan: data['JudulLaporan'],
        IsiLaporan: data['IsiLaporan'],
        kategori: data['kategori'],
        gambar: data['gambar']);
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Laporan> _laporans = [];
  List<Laporan> _filteredLaporans = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('data-dummy').get();
      setState(() {
        _laporans =
            snapshot.docs.map((doc) => Laporan.FromFirestore(doc)).toList();
        _filteredLaporans = _laporans;
        _isLoading = false;
        print('Fetched ${_laporans.length} reports');
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching data: $e");
    }
  }

  void _filterLaporan(String query) {
    List<Laporan> filteredLaporans = _laporans.where((laporan) {
      return laporan.JudulLaporan.toLowerCase().contains(query.toLowerCase()) ||
          laporan.IsiLaporan.toLowerCase().contains(query.toLowerCase()) ||
          laporan.kategori.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredLaporans = filteredLaporans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencarian Laporan'),
        backgroundColor: Colors.lightBlue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 17.0),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Laporan',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Icon(Icons.search),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              onChanged: (value) => {_filterLaporan(value)},
            ),
            Expanded(
                child: _isLoading
                    ? Center(
                        child: LoadingAnimationWidget.waveDots(
                            color: Colors.black, size: 50.0),
                      )
                    : ListView.builder(
                        itemCount: _filteredLaporans.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_filteredLaporans[index].JudulLaporan),
                            subtitle: Text(
                              'ID Pengguna: ${_filteredLaporans[index].userid}, Kode Laporan: ${_filteredLaporans[index].KodeLaporan}, Kategori: ${_filteredLaporans[index].kategori}',
                            ),
                          );
                        },
                      )),
          ],
        ),
      ),
    );
  }
}
