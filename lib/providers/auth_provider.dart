import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Cek sesi Firebase saat aplikasi dibuka dari Splash Screen
  Future<void> checkLoginStatus() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      // Ambil data nama dari Firestore jika user masih dalam status login
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        final data = doc.data();

        _currentUser = User(
          id: firebaseUser.uid,
          nama: data?['nama'] ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      } catch (e) {
        // Jika gagal ambil data Firestore, fallback menggunakan data email
        _currentUser = User(
          id: firebaseUser.uid,
          nama: firebaseUser.email?.split('@').first ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      }
      notifyListeners();
    }
  }

  // Proses Pendaftaran Menggunakan Firebase Auth
  Future<String?> register(String nama, String email, String kataSandi) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Buat akun di Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: kataSandi,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Simpan data tambahan (nama) ke dalam koleksi 'users' di Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': firebaseUser.uid,
          'nama': nama,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Set current user untuk UI
        _currentUser = User(
          id: firebaseUser.uid,
          nama: nama,
          email: email,
        );
      }

      _isLoading = false;
      notifyListeners();
      return null; // Return null menandakan sukses tanpa pesan error

    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      // Terjemahkan error Firebase ke Bahasa Indonesia
      if (e.code == 'weak-password') {
        return 'Kata sandi terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Email ini sudah terdaftar.';
      } else if (e.code == 'invalid-email') {
        return 'Format email tidak valid.';
      }
      return 'Gagal mendaftar: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan sistem.';
    }
  }

  // Proses Masuk (Login) Menggunakan Firebase Auth
  Future<String?> login(String email, String kataSandi) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: kataSandi,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Ambil nama dari Firestore
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        final data = doc.data();

        _currentUser = User(
          id: firebaseUser.uid,
          nama: data?['nama'] ?? firebaseUser.email?.split('@').first ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      }

      _isLoading = false;
      notifyListeners();
      return null; // Null menandakan sukses

    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Email atau kata sandi salah.';
      }
      return 'Gagal masuk: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan sistem.';
    }
  }

  // Proses Keluar (Logout)
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Proses Memperbarui Profil ke Firestore
  Future<String?> updateProfile(String newName) async {
    if (_currentUser == null) return 'Pengguna tidak valid';

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'nama': newName,
      });

      _currentUser = User(
        id: _currentUser!.id,
        nama: newName,
        email: _currentUser!.email,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Gagal memperbarui profil.';
    }
  }
}
