import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class EditData extends StatefulWidget {
  final String id;
  final String judul;
  final String isi;
  final String mood;
  final Timestamp tanggal;
  final String? imagePath;
  final String? videoPath;

  EditData({
    required this.id,
    required this.judul,
    required this.isi,
    required this.mood,
    required this.tanggal,
    this.imagePath,
    this.videoPath,
  });

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  final picker = ImagePicker();

  late TextEditingController judul;
  late TextEditingController isi;
  String? mood;

  String? imagePath;
  String? videoPath;

  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();

    judul = TextEditingController(text: widget.judul);
    isi = TextEditingController(text: widget.isi);
    mood = widget.mood;

    imagePath = widget.imagePath;
    videoPath = widget.videoPath;

    if (videoPath != null && File(videoPath!).existsSync()) {
      videoController = VideoPlayerController.file(File(videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<String> saveToAppFolder(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final name =
        "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
    final target = File("${dir.path}/$name");
    return (await File(file.path).copy(target.path)).path;
  }

  Future pickImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final path = await saveToAppFolder(picked);
    setState(() => imagePath = path);
  }

  Future pickVideo() async {
    final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final path = await saveToAppFolder(picked);
    videoPath = path;

    videoController?.dispose();
    videoController = VideoPlayerController.file(File(path));
    await videoController!.initialize();
    setState(() {});
  }

  Future save() async {
    await FirebaseFirestore.instance
        .collection("journal")
        .doc(widget.id)
        .update({
      "judul": judul.text,
      "isi": isi.text,
      "mood": mood,
      "imagePath": imagePath,
      "videoPath": videoPath,
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    videoController?.dispose();
    judul.dispose();
    isi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Edit Journal", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: 28),
            onPressed: save,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ===================== INPUT FORM =====================
          TextField(
            controller: judul,
            decoration: InputDecoration(
              labelText: "Judul",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 16),

          TextField(
            controller: isi,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Isi Journal",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: mood,
            decoration: InputDecoration(
              labelText: "Mood",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: ["senang", "sedih", "netral", "marah", "lelah"]
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => mood = v),
          ),

          SizedBox(height: 25),

          // ===================== FOTO =====================
          Text("Foto",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),

          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  if (imagePath != null && File(imagePath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(imagePath!),
                          height: 200, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: Center(child: Text("Tidak ada foto")),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.photo),
                    label: Text("Ganti Foto"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // ===================== VIDEO =====================
          Text("Video",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),

          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  if (videoController != null &&
                      videoController!.value.isInitialized)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: videoController!.value.aspectRatio,
                            child: VideoPlayer(videoController!),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            videoController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              videoController!.value.isPlaying
                                  ? videoController!.pause()
                                  : videoController!.play();
                            });
                          },
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: Center(child: Text("Tidak ada video")),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: pickVideo,
                    icon: Icon(Icons.video_library),
                    label: Text("Ganti Video"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
