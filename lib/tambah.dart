import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'journal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class TambahData extends StatefulWidget {
  @override
  _TambahDataState createState() => _TambahDataState();
}

class _TambahDataState extends State<TambahData> {
  TextEditingController judulController = TextEditingController();
  TextEditingController isiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _mediaFile;
  String? _savedPath;
  bool isVideo = false;

  VideoPlayerController? _videoController;

  final List<String> moodList = [
    "senang",
    "sedih",
    "netral",
    "marah",
    "bersemangat",
    "lelah"
  ];

  String? selectedMood;

  // ======================================================
  // KONVERSI content:// → real file ke direktori aplikasi
  // ======================================================
  Future<String> _copyToAppFolder(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newFile = File(
      "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}",
    );
    return await File(file.path).copy(newFile.path).then((f) => f.path);
  }

  // ======================================================
  // AMBIL FOTO / VIDEO
  // ======================================================
  Future<void> _ambilFotoKamera() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) _saveMedia(file, false);
  }

  Future<void> _ambilFotoGaleri() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) _saveMedia(file, false);
  }

  Future<void> _ambilVideoKamera() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
    if (file != null) _saveMedia(file, true);
  }

  Future<void> _ambilVideoGaleri() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) _saveMedia(file, true);
  }

  // ======================================================
  // SIMPAN MEDIA → folder aplikasi
  // ======================================================
  Future<void> _saveMedia(XFile file, bool video) async {
    try {
      final realPath = await _copyToAppFolder(file);

      setState(() {
        _mediaFile = File(realPath);
        _savedPath = realPath;
        isVideo = video;
      });

      if (video) _initVideoPlayer(realPath);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Media berhasil dimuat.")));
    } catch (e) {
      print("Error simpan media: $e");
    }
  }

  // ======================================================
  // VIDEO PLAYER
  // ======================================================
  Future<void> _initVideoPlayer(String path) async {
    try {
      _videoController?.dispose();

      _videoController = VideoPlayerController.file(File(path));
      await _videoController!.initialize();

      setState(() {});
    } catch (e) {
      print("Error video: $e");
    }
  }

  // ======================================================
  // SIMPAN DATA
  // ======================================================
  Future<bool> _simpanJournal() async {
    try {
      if (judulController.text.trim().isEmpty ||
          isiController.text.trim().isEmpty ||
          selectedMood == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lengkapi semua data.")),
        );
        return false;
      }

      await FirebaseFirestore.instance.collection("journal").add({
        "judul": judulController.text.trim(),
        "isi": isiController.text.trim(),
        "mood": selectedMood,
        "tanggal": DateTime.now(),
        "imagePath": isVideo ? null : _savedPath,
        "videoPath": isVideo ? _savedPath : null,
      });

      return true;
    } catch (e) {
      print("Error simpan data: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Tulis Journal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // ============================
            // CARD INPUT JUDUL & ISI
            // ============================
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: judulController,
                    decoration: InputDecoration(
                      labelText: "Judul",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: isiController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Isi Journal",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // ============================
                  // MOOD DROPDOWN
                  // ============================
                  DropdownButtonFormField(
                    value: selectedMood,
                    decoration: InputDecoration(
                      labelText: "Mood",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: moodList.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_emotions,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Text(m),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedMood = v),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // ============================
            // CARD MEDIA BUTTON
            // ============================
            Text(
              "Media (Foto / Video)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _menuButton(
                          Icons.camera_alt, "Foto Kamera", _ambilFotoKamera),
                      _menuButton(Icons.photo, "Foto Galeri", _ambilFotoGaleri),
                      _menuButton(
                          Icons.videocam, "Video Kamera", _ambilVideoKamera),
                      _menuButton(Icons.video_library, "Video Galeri",
                          _ambilVideoGaleri),
                    ],
                  ),

                  SizedBox(height: 20),

                  // PREVIEW FOTO
                  if (_mediaFile != null && !isVideo)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _mediaFile!,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // PREVIEW VIDEO
                  if (_mediaFile != null && isVideo)
                    _videoController != null &&
                            _videoController!.value.isInitialized
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                              SizedBox(height: 10),
                              IconButton(
                                icon: Icon(
                                  _videoController!.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  size: 48,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.value.isPlaying
                                        ? _videoController!.pause()
                                        : _videoController!.play();
                                  });
                                },
                              ),
                            ],
                          )
                        : CircularProgressIndicator(),

                  if (_savedPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Path: $_savedPath",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // ============================
            // TOMBOL SIMPAN
            // ============================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                bool saved = await _simpanJournal();
                if (saved) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => JournalPage()),
                  );
                }
              },
              child: Text(
                "Simpan Journal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

// =====================================================================
// BUTTON MEDIA STYLE (biar gak repetitif)
// =====================================================================
  Widget _menuButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
