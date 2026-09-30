import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('user_nama');
    final email = prefs.getString('user_email');

    if (nama != null && email != null) {
      _currentUser = User(id: 'u1', nama: nama, email: email);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String kataSandi) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && kataSandi.isNotEmpty) {
      _currentUser = User(id: 'u1', nama: 'Pengguna Flash Mind', email: email);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nama', _currentUser!.nama);
      await prefs.setString('user_email', _currentUser!.email);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String nama, String email, String kataSandi) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (nama.isNotEmpty && email.isNotEmpty && kataSandi.length >= 6) {
      _currentUser = User(id: 'u2', nama: nama, email: email);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nama', _currentUser!.nama);
      await prefs.setString('user_email', _currentUser!.email);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Mengecek apakah email terdaftar di penyimpanan lokal.
  Future<bool> checkEmailExists(String email) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('user_email');

    _isLoading = false;
    notifyListeners();

    return storedEmail != null &&
        storedEmail.toLowerCase() == email.toLowerCase();
  }

  /// Mengubah kata sandi pengguna berdasarkan email yang cocok.
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('user_email');

    if (storedEmail == null ||
        storedEmail.toLowerCase() != email.toLowerCase()) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Simpan password baru (disimpan hashed sederhana untuk demo lokal)
    await prefs.setString('user_password', newPassword);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_nama');
    await prefs.remove('user_email');

    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(String newName) async {
    if (_currentUser != null && newName.isNotEmpty) {
      _currentUser = User(
        id: _currentUser!.id,
        nama: newName,
        email: _currentUser!.email,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nama', newName);

      notifyListeners();
    }
  }
}