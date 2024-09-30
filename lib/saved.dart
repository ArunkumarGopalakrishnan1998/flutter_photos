import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {}

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  List<io.File> files = [];

  Future<List<io.File>> setDownloadsDirectory() async {
    var directory = await io.Directory(
            '/storage/emulated/0/Android/data/com.example.photos/files/downloads/')
        .create(recursive: true);
    final downloadsDirectory = directory.path;
    print(directory.path);
    final List<io.FileSystemEntity> savedFiles =
        io.Directory(downloadsDirectory).listSync();

    return savedFiles.map((element) => io.File(element.path)).toList();
    print('................................................ ${files}');
  }

  @override
  Widget build(BuildContext context) {
    setDownloadsDirectory();
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Photos'),
      ),
      body: FutureBuilder<List<io.File>>(
        future: setDownloadsDirectory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading files'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved files'));
          } else {
            List<io.File> files = snapshot.data!;
            return MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: EdgeInsets.all(12.0),
              itemCount: files.length,
              itemBuilder: (context, index) {
                return InkWell(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Hero(
                      tag: files[index],
                      child: Image.file(files[index]),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
