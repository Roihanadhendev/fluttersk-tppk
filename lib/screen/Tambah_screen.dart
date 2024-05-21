import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class TambahPage extends StatefulWidget {
  @override
  _TambahPageState createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _judulController = TextEditingController();
  TextEditingController _deskripsiController = TextEditingController();
  String _kategori = 'Pilih Kategori Laporan';
  File? _image;
  bool _isLoading = false;

  final List<String> _kategoriLaporan = [
    'Pilih Kategori Laporan',
    'Bullying',
    'Kekerasan Seksual',
    'Kekerasan Fisik',
    'Pemalakan'
  ];

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("gagal menambahkan gambar : $e");
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child('laporan_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _submitLaporan() async {
    if (_formKey.currentState!.validate()) {
      if (_kategori == 'Pilih Kategori Laporan') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pilih kategori laporan.')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      try {
        await FirebaseFirestore.instance.collection('data-dummy').add({
          'judul': _judulController.text,
          'deskripsi': _deskripsiController.text,
          'kategori': _kategori,
          'tanggal': Timestamp.now(),
          'gambar_url': imageUrl,
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Laporan berhasil dikirim.')));

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _kategori = 'Pilih Kategori Laporan';
          _image = null;
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim laporan: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Judul Laporan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Laporan',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _kategori,
                onChanged: (String? newValue) {
                  setState(() {
                    _kategori = newValue!;
                  });
                },
                items: _kategoriLaporan.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Pilih Kategori Laporan',
                ),
                validator: (value) {
                  if (value == null || value == 'Pilih Kategori Laporan') {
                    return 'Pilih kategori';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: _pickImage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file),
                    SizedBox(width: 8.0),
                    Text('Bukti Laporan'),
                  ],
                ),
              ),
              if (_image != null) Image.file(_image!),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitLaporan,
                child: Text('Kirim'),
              ),
              if (_isLoading)
                Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
