import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class Preview extends StatefulWidget {
  const Preview({super.key, required this.photos, required this.index});

  @override
  State<Preview> createState() => _PreviewState();
  final List<Map<String, String>> photos;
  final int index;
}

class _PreviewState extends State<Preview> {
  int currentPageIndex = 0;
  final globalKey = GlobalKey();
  String downloadsPath = 'UNKNOWN';

  Future<void> downloadAndSaveImage(String imageUrl) async {
    Dio dio = Dio();

    try {
      // Get the Downloads directory
      Directory? downloadsDirectory = await getDownloadsDirectory();

      // Create a file name based on the current timestamp
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.png';

      // Create the file path
      String filePath = '${downloadsDirectory?.path}/$fileName';

      // Download the image
      await dio.download(imageUrl, filePath);

      print('Image downloaded to: $filePath');
    } catch (error) {
      print('Error downloading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentImage = widget.index;
    print('....................index ${widget.index}');

    return RepaintBoundary(
        key: globalKey,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white)),
          body: PhotoViewGallery.builder(
            itemCount: widget.photos.length,
            builder: (context, index) =>
                PhotoViewGalleryPageOptions.customChild(
                    onTapDown: (context, details, controllerValue) => {
                          currentImage = index,
                          print('....................down ${currentImage}')
                        },
                    child: CachedNetworkImage(
                      imageUrl: widget.photos[index]['original']!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.red.shade400,
                      ),
                    ),
                    minScale: PhotoViewComputedScale.covered,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.photos[index])),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  downloadAndSaveImage(
                      widget.photos[currentImage]['original']!);
                },
                iconSize: 40,
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  final url =
                      Uri.parse(widget.photos[currentImage]['original']!);
                  final resp = await http.get(url);
                  Share.shareXFiles(
                    [
                      XFile.fromData(resp.bodyBytes,
                          name: 'image', mimeType: 'image/png')
                    ],
                    subject: 'image',
                  );
                },
                iconSize: 40,
                color: Colors.white,
              ),
            ],
          ),
        ));
  }
}
