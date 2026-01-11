import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Audio extends StatefulWidget {
  @override
  _AudioState createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  final AudioPlayer audioPlayer = AudioPlayer();

  // State untuk tracking audio yang sedang diputar
  String? currentPlayingId;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Daftar audio meditasi dan relaksasi
  final List<Map<String, dynamic>> audioList = [
    {
      'id': 'sleep',
      'title': 'Meditasi Sebelum Tidur',
      'subtitle': '5 Menit - Relaksasi untuk tidur nyenyak',
      'duration': '04:20',
      'path': 'audio/night.mp3',
      'icon': Icons.nightlight_round,
      'color': Colors.indigo,
      'category': 'Tidur',
    },
    {
      'id': 'morning',
      'title': 'Meditasi Pagi',
      'subtitle': '3 Menit - Energi positif di pagi hari',
      'duration': '703:36',
      'path': 'audio/morning.mp3',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'category': 'Meditasi',
    },
    {
      'id': 'calm',
      'title': 'Musik Tenang',
      'subtitle': '3 Menit - Musik instrumental menenangkan',
      'duration': '03:57',
      'path': 'audio/gymnopedie.mp3',
      'icon': Icons.music_note,
      'color': Colors.purple,
      'category': 'Musik',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Listener untuk durasi audio
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });

    // Listener untuk posisi audio
    audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });

    // Listener untuk status pemutaran
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    // Listener ketika audio selesai
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        currentPlayingId = null;
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // Fungsi untuk play audio
  Future<void> playAudio(String path, String id) async {
    try {
      if (currentPlayingId == id && isPlaying) {
        // Jika audio yang sama sedang diputar, pause
        await audioPlayer.pause();
      } else if (currentPlayingId == id && !isPlaying) {
        // Jika audio yang sama di-pause, resume
        await audioPlayer.resume();
      } else {
        // Play audio baru
        await audioPlayer.stop();
        await audioPlayer.play(AssetSource(path));
        setState(() {
          currentPlayingId = id;
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memutar audio. Pastikan file audio tersedia."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk stop audio
  Future<void> stopAudio() async {
    await audioPlayer.stop();
    setState(() {
      currentPlayingId = null;
      position = Duration.zero;
    });
  }

  // Format durasi ke string
  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Musik & Meditasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // HEADER CARD
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  "Relaksasi & Meditasi",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Tenangkan pikiran Anda dengan musik dan meditasi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // LIST AUDIO
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: audioList.length,
              itemBuilder: (context, index) {
                var audio = audioList[index];
                bool isCurrentlyPlaying = currentPlayingId == audio['id'];

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: isCurrentlyPlaying ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => playAudio(audio['path'], audio['id']),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // ICON CONTAINER
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: audio['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  audio['icon'],
                                  color: audio['color'],
                                  size: 28,
                                ),
                              ),

                              SizedBox(width: 16),

                              // TITLE & SUBTITLE
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      audio['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      audio['subtitle'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                audio['color'].withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            audio['category'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: audio['color'],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          audio['duration'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // PLAY/PAUSE BUTTON
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isCurrentlyPlaying
                                      ? audio['color']
                                      : audio['color'].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCurrentlyPlaying && isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: isCurrentlyPlaying
                                      ? Colors.white
                                      : audio['color'],
                                  size: 28,
                                ),
                              ),
                            ],
                          ),

                          // PROGRESS BAR (jika sedang diputar)
                          if (isCurrentlyPlaying && duration.inSeconds > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 14,
                                      ),
                                      trackHeight: 4,
                                    ),
                                    child: Slider(
                                      value: position.inSeconds.toDouble(),
                                      max: duration.inSeconds.toDouble(),
                                      activeColor: audio['color'],
                                      inactiveColor:
                                          audio['color'].withOpacity(0.2),
                                      onChanged: (value) async {
                                        await audioPlayer.seek(
                                          Duration(seconds: value.toInt()),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatDuration(position),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          formatDuration(duration),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // MINI PLAYER (jika ada audio yang diputar)
          if (currentPlayingId != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.replay_10),
                    iconSize: 32,
                    color: Colors.blueAccent,
                    onPressed: () async {
                      final newPosition = position - Duration(seconds: 10);
                      await audioPlayer.seek(
                        newPosition < Duration.zero
                            ? Duration.zero
                            : newPosition,
                      );
                    },
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 36,
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.resume();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.forward_10),
                    iconSize: 32,
                    color: Colors.blueAccent,
                    onPressed: () async {
                      final newPosition = position + Duration(seconds: 10);
                      await audioPlayer.seek(
                        newPosition > duration ? duration : newPosition,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    iconSize: 32,
                    color: Colors.red,
                    onPressed: stopAudio,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
