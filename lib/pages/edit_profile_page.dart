import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;

  @override
  void initState() {
    super.initState();
    // Memuat nama pengguna saat ini ke dalam form
    final user = context.read<AuthProvider>().currentUser;
    _namaController = TextEditingController(text: user?.nama ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _simpanProfil() {
    if (_formKey.currentState!.validate()) {
      // Logika simulasi simpan profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context); // Kembali ke halaman profil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanProfil,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}