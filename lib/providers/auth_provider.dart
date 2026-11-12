import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> checkLoginStatus() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        final data = doc.data();

        _currentUser = User(
          id: firebaseUser.uid,
          nama: data?['nama'] ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      } catch (e) {
        _currentUser = User(
          id: firebaseUser.uid,
          nama: firebaseUser.email?.split('@').first ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      }
      notifyListeners();
    }
  }

  Future<String?> register(String nama, String email, String kataSandi) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: kataSandi,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': firebaseUser.uid,
          'nama': nama,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _currentUser = User(
          id: firebaseUser.uid,
          nama: nama,
          email: email,
        );
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
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
      return null;
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

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    notifyListeners();
  }

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

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({required String email, required String newPassword}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
