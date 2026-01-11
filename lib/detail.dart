import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'edit.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  String id;
  String judul;
  String isi;
  String mood;
  Timestamp tanggal;

  String? imagePath;
  String? videoPath;

  DetailPage({
    required this.id,
    required this.judul,
    required this.isi,
    required this.mood,
    required this.tanggal,
    this.imagePath,
    this.videoPath,
    super.key,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    if (widget.videoPath != null && File(widget.videoPath!).existsSync()) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(widget.videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _deleteDoc() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Hapus"),
        content: Text("Apakah data ini akan dihapus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('journal')
          .doc(widget.id)
          .delete();
      Navigator.pop(context); // kembali ke halaman sebelumnya
    }
  }

  Color _moodColor() {
    switch (widget.mood) {
      case "senang":
        return Colors.green.shade400;
      case "sedih":
        return Colors.blue.shade300;
      case "marah":
        return Colors.red.shade400;
      case "bersemangat":
        return Colors.orange.shade400;
      case "lelah":
        return Colors.grey.shade400;
      default:
        return Colors.teal;
    }
  }

  Future<void> _refreshData() async {
    final doc = await FirebaseFirestore.instance
        .collection('journal')
        .doc(widget.id)
        .get();
    setState(() {
      widget.judul = doc['judul'];
      widget.isi = doc['isi'];
      widget.mood = doc['mood'];
      widget.tanggal = doc['tanggal'];
      widget.imagePath = doc['imagePath'];
      widget.videoPath = doc['videoPath'];
      _initVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat("dd MMM yyyy").format(widget.tanggal.toDate());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Detail Journal"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditData(
                    id: widget.id,
                    judul: widget.judul,
                    isi: widget.isi,
                    mood: widget.mood,
                    tanggal: widget.tanggal,
                    imagePath: widget.imagePath,
                    videoPath: widget.videoPath,
                  ),
                ),
              );

              // Ambil data terbaru dari Firestore setelah edit
              await _refreshData();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: _deleteDoc,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.judul,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        backgroundColor: _moodColor(),
                        label: Text(
                          widget.mood,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Spacer(),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.isi,
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          if (widget.imagePath != null &&
              File(widget.imagePath!).existsSync()) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black12,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(File(widget.imagePath!)),
            ),
            SizedBox(height: 20),
          ],
          if (_videoController != null &&
              _videoController!.value.isInitialized) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
