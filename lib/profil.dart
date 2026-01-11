import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'login.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imagePath;

  String _nama = '';
  String _deskripsi = '';
  String _email = '';
  String _username = '';
  String _nomorHp = '';
  String _bio = '';

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadProfil();
    // Trigger animasi fade-in
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  Future<void> _loadProfil() async {
    final prefs = await SharedPreferences.getInstance();

    final savedImage = prefs.getString('fotoProfil');

    setState(() {
      _nama = prefs.getString('nama') ?? 'Nama Pengguna';
      _deskripsi = prefs.getString('deskripsi') ?? 'Deskripsi singkat';
      _email = prefs.getString('email') ?? 'email@example.com';
      _username = prefs.getString('username') ?? 'username';
      _nomorHp = prefs.getString('nomorHp') ?? '08xxxxxxxxxx';
      _bio = prefs.getString('bio') ?? 'Bio singkat Anda.';

      if (savedImage != null && File(savedImage).existsSync()) {
        _imageFile = File(savedImage);
        _imagePath = savedImage;
      }

      _namaController.text = _nama;
      _descController.text = _deskripsi;
      _emailController.text = _email;
      _usernameController.text = _username;
      _nomorHpController.text = _nomorHp;
      _bioController.text = _bio;
    });
  }

  Future<void> _saveProfil() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nama', _namaController.text);
    await prefs.setString('deskripsi', _descController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('nomorHp', _nomorHpController.text);
    await prefs.setString('bio', _bioController.text);

    if (_imagePath != null) {
      await prefs.setString('fotoProfil', _imagePath!);
    }

    setState(() {
      _nama = _namaController.text;
      _deskripsi = _descController.text;
      _email = _emailController.text;
      _username = _usernameController.text;
      _nomorHp = _nomorHpController.text;
      _bio = _bioController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil disimpan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );

    if (image == null) return;

    await _savePickedFile(image);
  }

  Future<void> _savePickedFile(XFile pickedFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedFile.path);

    final savedImage = File('${appDir.path}/$fileName');
    await savedImage.writeAsBytes(await pickedFile.readAsBytes());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fotoProfil', savedImage.path);

    setState(() {
      _imageFile = savedImage;
      _imagePath = savedImage.path;
    });
  }

  void _editProfilDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profil Lengkap",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_namaController, "Nama", Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_descController, "Deskripsi", Icons.description),
              const SizedBox(height: 12),
              _buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 12),
              _buildTextField(
                  _usernameController, "Username", Icons.account_circle),
              const SizedBox(height: 12),
              _buildTextField(_nomorHpController, "Nomor HP", Icons.phone),
              const SizedBox(height: 12),
              _buildTextField(_bioController, "Bio", Icons.edit_note,
                  maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveProfil();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5E35B1), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            tooltip: "Simpan Profil",
            onPressed: _saveProfil,
          ),
        ],
      ),
      body: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ===========================
                // FOTO PROFIL
                // ===========================
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 65,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          backgroundColor: Colors.blueAccent.shade100,
                          child: _imageFile == null
                              ? const Icon(Icons.person,
                                  size: 75, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5E35B1), Color(0xFF1E88E5)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===========================
                // NAMA & DESKRIPSI
                // ===========================
                Text(
                  _nama,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _deskripsi,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 32),

                // ===========================
                // CARD INFO LENGKAP
                // ===========================
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5E35B1), Color(0xFF1E88E5)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Informasi Akun",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _infoTile(Icons.email, "Email", _email),
                      const SizedBox(height: 4),
                      _infoTile(Icons.person, "Username", _username),
                      const SizedBox(height: 4),
                      _infoTile(Icons.phone_android, "Nomor HP", _nomorHp),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_note,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Bio",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _bio,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ===========================
                // BUTTONS
                // ===========================
                ElevatedButton.icon(
                  onPressed: _editProfilDialog,
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text(
                    "Edit Profil",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Login()),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
