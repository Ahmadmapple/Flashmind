import 'dart:async';

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
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Firestore read timeout'),
            );

        final data = doc.data();

        _currentUser = User(
          id: firebaseUser.uid,
          nama: data?['nama'] ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      } catch (e) {
        // Fallback jika Firestore gagal
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
        // Simpan profil ke Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
              'id': firebaseUser.uid,
              'nama': nama,
              'email': email,
              'createdAt': FieldValue.serverTimestamp(),
            })
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Firestore write timeout'),
            );

        // Kirim email verifikasi
        await firebaseUser.sendEmailVerification();
      }

      // Sign out — user harus verifikasi email dulu sebelum bisa login
      await _firebaseAuth.signOut();
      _currentUser = null;

      return null;
    } on auth.FirebaseAuthException catch (e) {
      try { await _firebaseAuth.currentUser?.delete(); } catch (_) {}
      if (e.code == 'weak-password') return 'Kata sandi terlalu lemah.';
      if (e.code == 'email-already-in-use') return 'Email ini sudah terdaftar.';
      if (e.code == 'invalid-email') return 'Format email tidak valid.';
      return 'Gagal mendaftar: ${e.message}';
    } on TimeoutException {
      try { await _firebaseAuth.currentUser?.delete(); } catch (_) {}
      return 'Koneksi timeout. Pastikan database Firestore sudah aktif.';
    } catch (e) {
      try { await _firebaseAuth.currentUser?.delete(); } catch (_) {}
      return 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
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
        // Cek apakah email sudah diverifikasi
        if (!firebaseUser.emailVerified) {
          await _firebaseAuth.signOut();
          return 'Email belum diverifikasi. Silakan cek inbox kamu dan klik link verifikasi.';
        }

        // Set timeout 10 detik untuk Firestore read
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Firestore read timeout'),
            );

        final data = doc.data();

        _currentUser = User(
          id: firebaseUser.uid,
          nama: data?['nama'] ?? firebaseUser.email?.split('@').first ?? 'Pengguna',
          email: firebaseUser.email ?? '',
        );
      }

      return null;
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Email atau kata sandi salah.';
      }
      return 'Gagal masuk: ${e.message}';
    } on TimeoutException {
      return 'Koneksi timeout. Pastikan database Firestore sudah aktif.';
    } catch (e) {
      return 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kirim ulang email verifikasi — untuk user yang belum verifikasi.
  Future<String?> resendVerificationEmail(String email, String kataSandi) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: kataSandi,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
        await _firebaseAuth.signOut();
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return 'Gagal kirim ulang: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan.';
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

      return null;
    } catch (e) {
      return 'Gagal memperbarui profil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
