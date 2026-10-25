# Flash Mind

Aplikasi pembelajaran berbasis flashcard yang dapat digunakan sebagai media bantu untuk melatih daya ingat pengguna secara aktif.

---

## Daftar Isi

1. [Tujuan](#tujuan)
2. [Fitur Utama](#fitur-utama)
3. [Teknologi](#teknologi)
4. [Setup Aplikasi](#setup-aplikasi)
5. [Perintah Menjalankan Aplikasi](#perintah-menjalankan-aplikasi)
6. [Data Dummy](#data-dummy)
7. [Skenario Simulasi](#skenario-simulasi)

---

## Tujuan
Tujuan utama dari aplikasi ini, yaitu
- Membantu pengguna dalam memahami suatu topik pembelajaran dengan mensimulasikan kegiatan tanya-jawab melalui flashcard, tanpa harus bergantung pada keberadaan pihak lain sehingga pengguna dapat melakukan pembelajaran secara mandiri.
- Meningkatkan kemampuan pengguna dalam mengorganisasikan informasi melalui pembentuk set-set flashcard dengan topik yang berhubungan.
- Membantu pengguna menilai pemahamannya terhadap suatu topik pembelajaran dengan adanya data hasil sesi belajar.
- Memberikan rekomendasi belajar yang andal bagi pengguna berdasarkan performa pengguna selama melakukan pembelajaran.
- Mendorong terbentuknya kebiasaan belajar yang konsisten bagi pengguna.

---

## Fitur Utama

Fitur utama dari aplikasi ini, yaitu
- **Pengelolaan Set Flashcard**
  
  Pengguna dapat membuat suatu set flashcard yang terdiri atas beberapa flashcard. Selain itu, pengguna dapat mengedit atau menghapus flashcard dari satu set atau keseluruhan flashcard dalam satu set.
  
- **Kegiatan Belajar**

  Pengguna dapat memulai suatu sesi belajar dengan memilih satu set yang hendak dipelajari. Kegiatan pembelajaran akan dilakukan sebagaimana penggunaan flashcard pada umumnya, yaitu penampilan pertanyaan di sisi depan kartu terlebih dahulu. Kemudian, pengguna dapat membalik kartu untuk melihat jawaban di sisi belakang.

  Terdapat pilihan yang diberikan untuk setiap penyelesaian flashcard untuk menilai tingkat kesulitannya, yaitu benar atau salah.
  
- **Statistik dan Riwayat Pembelajaran**

  Aplikasi akan menyediakan data statistik yang disusun berdasarkan riwayat pembelajaran pengguna yang meliputi, set terakhir yang dipelajari, jumlah flashcard yang dipelajari, jumlah set yang dipelajari, jumlah benar dan salah, serta durasi pembelajaran.

  
- **Rekomendasi Belajar**
  
  Dengan menggunakan data statistik serta riwayat pembelajaran, aplikasi dapat menyusun rekomendasi set yang perlu dipelajari berdasarkan kriteria, seperti set mana yang sudah lama tidak dipelajari, set dengan persentase salah yang besar, set dengan durasi rata-rata penyelesaian yang relatif lama, dan kriteria lainnya.

---

## Teknologi

1. Flutter dengan Dart SDK `^3.13.2`
2. Dependensi utama:
   - `provider` (^6.1.5+1)
   - `shared_preferences` (^2.5.5)
   - `cupertino_icons` (^1.0.8)
   - `flutter_lints` (^6.0.0)

---

## Setup Aplikasi

### Prasyarat

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) dengan Dart minimal `3.13.2`.
2. Target untuk melakukan pengujian, seperti
   - Emulator Android atau perangkat fisik dengan USB debugging aktif
   - Simulator iOS, khusus macOS dengan Xcode
   - Browser atau desktop
3. Code Editor, seperti VS Code atau Android Studio dengan plugin Flutter dan Dart.

Periksa instalasi:

```bash
flutter --version
dart --version
flutter doctor
```

### Instalasi

```bash
# 1. Clone repositori
git clone https://github.com/Ahmadmapple/Flashmind.git

# 2. Masuk ke direktori proyek
cd Flashmind

# 3. Unduh dependensi
flutter pub get
```
---

## Perintah Menjalankan Aplikasi

```bash
# Lihat perangkat/emulator yang tersedia
flutter devices

# Menjalankan di perangkat yang terhubung
flutter run

# Menjalankan di perangkat tertentu dengan id perangkat
flutter run -d <device_id>

# Menjalankan di browser
flutter run -d chrome

# Menjalankan di desktop (sesuai OS)
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

> Saat aplikasi berjalan, tombol `r` dapat ditekan di terminal untuk hot reload dan `R` untuk hot restart.

---

## Data Dummy

Data dummy dibuat otomatis saat aplikasi dijalankan melalui fungsi `_initDummyData` pada `lib/repositories/flash_mind_repository.dart`.

Data set, kartu, dan sesi belajar yang dibuat pengguna akan disimpan secara sementara selama aplikasi sedang berjalan. Setelah aplikasi ditutup atau di-*hot restart*, data kembali ke data dummy awal. Hanya data akun, termasuk nama, email, dan kata sandi yang bertahan karena disimpan di `SharedPreferences`.

Data dummy pada aplikasi ini, yaitu

### 5 Set Flashcard yang masing-masingnya berisikan 5 kartu


| ID | Nama | Deskripsi | Waktu Dibuat |
|---|---|---|---|
| `set-1` | Biologi Sel | Konsep dasar biologi sel dan organel-organelnya. | 12 hari lalu |
| `set-2` | Bahasa Jepang | Kosakata dasar dan sapaan sehari-hari bahasa Jepang. | 9 hari lalu |
| `set-3` | Kimia Organik | Alkana, alkena, alkuna, isomer, dan gugus fungsi. | 7 hari lalu |
| `set-4` | Matematika Dasar | Operasi dasar, rumus geometri, dan teori bilangan. | 5 hari lalu |
| `set-5` | Sejarah Indonesia | Peristiwa penting dalam sejarah kemerdekaan Indonesia. | 3 hari lalu |

<details>
<summary><b>Isi kartu per set</b></summary>

**set-1: Biologi Sel**

| Pertanyaan | Jawaban |
|---|---|
| Apa fungsi utama membran sel? | Mengatur zat yang masuk dan keluar sel serta menjaga keseimbangan internal. |
| Apa itu mitokondria? | Organel penghasil energi (ATP) melalui respirasi seluler; disebut "pembangkit listrik sel". |
| Jelaskan fotosintesis secara singkat. | Proses tumbuhan mengubah cahaya matahari, air, dan CO₂ menjadi glukosa dan oksigen. |
| Apa perbedaan sel prokariotik dan eukariotik? | Prokariotik tidak memiliki nukleus bermembran; eukariotik memiliki nukleus yang diselubungi membran inti. |
| Apa fungsi ribosom? | Mensintesis protein dengan menerjemahkan mRNA menjadi rantai asam amino. |

**set-2: Bahasa Jepang**

| Pertanyaan | Jawaban |
|---|---|
| ありがとう (Arigatou) artinya? | Terima kasih |
| おはよう (Ohayou) artinya? | Selamat pagi |
| こんにちは (Konnichiwa) artinya? | Selamat siang / Halo |
| さようなら (Sayounara) artinya? | Selamat tinggal |
| すみません (Sumimasen) artinya? | Permisi / Maaf |

**set-3: Kimia Organik**

| Pertanyaan | Jawaban |
|---|---|
| Apa itu isomer? | Senyawa dengan rumus molekul sama tetapi struktur atau susunan atom berbeda. |
| Apa itu alkana? | Hidrokarbon jenuh dengan ikatan tunggal C–C; rumus umum CₙH₂ₙ₊₂. |
| Perbedaan alkena dan alkuna? | Alkena: ikatan rangkap dua (C=C). Alkuna: ikatan rangkap tiga (C≡C). |
| Apa itu gugus fungsi? | Atom/kelompok atom pada molekul organik yang menentukan sifat kimianya. |
| Apa itu reaksi substitusi? | Reaksi penggantian satu atom/gugus dalam molekul dengan atom/gugus lain. |

**set-4: Matematika Dasar**

| Pertanyaan | Jawaban |
|---|---|
| Berapa hasil dari 7 × 8? | 56 |
| Apa rumus luas lingkaran? | L = π × r² (di mana r adalah jari-jari) |
| Apa itu bilangan prima? | Bilangan asli lebih dari 1 yang hanya habis dibagi 1 dan dirinya sendiri. |
| Apa rumus Teorema Pythagoras? | a² + b² = c², di mana c adalah sisi miring segitiga siku-siku. |
| Apa itu FPB? | Faktor Persekutuan Terbesar: bilangan terbesar yang habis membagi dua bilangan. |

**set-5: Sejarah Indonesia**

| Pertanyaan | Jawaban |
|---|---|
| Kapan Indonesia merdeka? | 17 Agustus 1945 |
| Siapa proklamator kemerdekaan Indonesia? | Soekarno dan Mohammad Hatta |
| Apa isi Sumpah Pemuda 1928? | Satu bangsa (Indonesia), satu tanah air (Indonesia), satu bahasa (Indonesia). |
| Apa nama operasi militer yang membebaskan Irian Barat? | Operasi Trikora (Tri Komando Rakyat), 1961–1962. |
| Siapa presiden pertama Republik Indonesia? | Ir. Soekarno, menjabat 1945–1967. |

</details>

### 8 Riwayat Sesi Belajar (semua berstatus selesai)

| ID | Set | Waktu mulai | Durasi | Benar/Total | Akurasi |
|---|---|---|---|---|---|
| `ses-1` | Biologi Sel | 5 hari lalu | 5 mnt | 4/5 | 80% |
| `ses-2` | Biologi Sel | 2 hari lalu | 4 mnt | 5/5 | 100% |
| `ses-3` | Biologi Sel | 3 jam lalu | 3 mnt 30 dtk | 5/5 | 100% |
| `ses-4` | Bahasa Jepang | 4 hari lalu | 3 mnt | 3/5 | 60% |
| `ses-5` | Bahasa Jepang | 1 hari lalu | 2 mnt 45 dtk | 4/5 | 80% |
| `ses-6` | Kimia Organik | 6 hari lalu | 4 mnt 15 dtk | 2/5 | 40% |
| `ses-7` | Kimia Organik | 3 hari lalu | 3 mnt | 3/5 | 60% |
| `ses-8` | Matematika Dasar | 2 hari lalu | 2 mnt 50 dtk | 5/5 | 100% |

### Statistik awal yang tampil di aplikasi

| Indikator | Nilai awal |
|---|---|
| Tingkat hafalan keseluruhan | 78% |
| Kartu dipelajari | 40 |
| Set aktif | 5 |
| Skor terakhir per set | Biologi Sel 100%, Bahasa Jepang 80%, Kimia Organik 60%, dan Matematika Dasar 100% |

### Kartu dummy hasil "AI" yang diperoleh dari fitur Upload PDF

Setiap kali fitur ini digunakan, aplikasi akan membuat **5 kartu yang sama** bertema Biologi Sel.

---

## Skenario Simulasi

Skenario pengujian berikut dapat dijalankan dalam menggunakan aplikasi.

### 1. Registrasi dan Login
1. Jalankan aplikasi. Splash screen tampil sekitar 2 detik.
2. Halaman **Login** akan ditampilkan jika belum pernah menggunakan aplikasi. Bila tidak memiliki akun, buka halaman **Daftar**.
3. Lakukan pemeriksaan input yang tidak valid, seperti nama 1 karakter, email tanpa `@`, dan kata sandi kurang dari 6 karakter.

   **Hasil:** pesan validasi, yaitu "Nama minimal 2 karakter", "Masukkan alamat email yang valid", "Kata sandi minimal 6 karakter".
5. Isi data valid, lalu selesaikan pendaftaran.

   **Hasil:** pendaftaran berhasil dan kembali ke halaman Login.
6. Masuk dengan email dan kata sandi yang benar.

   **Hasil:** masuk ke halaman utama (Beranda). Jika email atau sandi salah, muncul peringatan "Email atau kata sandi salah".
   

### 2. Lupa Kata Sandi
1. Di halaman Login, pilih lupa kata sandi.
2. Masukkan email yang belum terdaftar.

   **Hasil:** pesan peringatan, yaitu "Email tidak ditemukan".
4. Masukkan email terdaftar, lalu isi kata sandi baru dan konfirmasinya.

   **Hasil:** Jika konfirmasi tidak sama, muncul "Kata sandi tidak cocok". Jika kata sandi kurang dari 6 karakter, tampil pesan peringatan bahwa kata sandi minimal 6 karakter. Jika sama, muncul "Kata sandi berhasil diubah!".

### 3. Menjelajahi Beranda dan Rekomendasi
1. Perhatikan sapaan sesuai jam (pagi/siang/sore/malam) dan nama depan pengguna.
2. Kartu **Ulasan Terakhir** menampilkan set yang paling baru dipelajari. Untuk penggunaan awal, akan ditampilkan data dummy, yaitu **Biologi Sel** dengan sesi terakhir adalah 3 jam lalu.
3. Perhatikan grafik aktivitas 7 hari terakhir dan ketuk salah satu batang untuk melihat detail hari itu.

### 4. Mencari dan Memfilter Set
1. Buka laman **Berkas**.
2. Akan muncul 5 set dummy.
3. Ketik `Kimia` di kolom pencarian.

   **Hasil:** hanya set Kimia Organik yang tampil. Ketika kata yang tidak menjadi bagian dari nama suatu set dimasukkan, akan tampil pesan "Tidak ada set yang cocok".
5. Pilih filter **Sesi Terhenti**.

   **Hasil:** "Tidak ada sesi belajar yang terhenti" karena belum ada sesi yang dihentikan.

### 5. Membuat Set dan Kartu
1. Di tab Berkas, pilih **Tambah Set**.
2. Isi judul kurang dari 3 karakter lalu simpan.

   **Hasil:** validasi menolak. Judul dibatasi maksimal 40 karakter dan deskripsi maksimal 100 karakter.
4. Isi judul valid, lalu simpan.

   **Hasil:** pengguna dibawa masuk ke detail set dengan pesan "Set berhasil dibuat."
5. Tambahkan kartu dengan memasukkan pertanyaan dan jawaban dengan batasan minimal 1 karakter dan batasan maksimal 999 karakter.

   **Hasil:** Jika input kurang dari 1 karakter, akan tampil teks peringatan batasan minimal. Jika input valid, tampil pesan "Kartu berhasil dibuat." dan jumlah kartu di set bertambah.

### 6. Mengubah dan Menghapus Set atau Kartu
1. Di laman Berkas, pilih satu set. Dari layar **Detail Set**, pilih **Edit Set**, ubah judul atau deskripsi dengan batasan yang valid.

   **Hasil:** "Set berhasil diperbarui."
3. Di layar **Detail Set**, pilih satu kartu untuk masuk ke layar **Detail Kartu**. Lakukan pengeditan pada setiap sisi kartu dengan batasan yang valid.

   **Hasil:** Isi kartu berhasil diperbarui.
4. Pilih **Hapus Set**. Dialog konfirmasi menampilkan nama set.

   **Hasil:** Setelah dikonfirmasi oleh pengguna, "Set berhasil dihapus." Sesi belajar milik set itu ikut terhapus.

### 7. Simulasi Membuat Kartu dari File PDF 
1. Buka suatu set untuk masuk ke layar Detail Set.
2. Pilih **Upload PDF**, lalu **Pilih File PDF**.
3. Sistem akan secara otomatis membuat sekumpulan kartu dan membawa pengguna ke layar **Tinjau Kartu AI**.
4. Pada layar **Tinjau Kartu AI**, pilih kartu yang ingin disimpan.

   **Hasil:** jika tidak ada yang dipilih, muncul "Pilih minimal satu kartu untuk disimpan."
   
6. Simpan.

   **Hasil:** Satu atau sekumpulan kartu disimpan dan pengguna dibawa kembali ke detail set.

### 8. Sesi Belajar Hingga Selesai
1. Buka satu set, lalu pilih **Mulai Belajar**.
2. Halaman awal sesi menampilkan riwayat dan rekor set.
3. Tekan **Mulai** untuk memulai suatu sesi belajar.
4. Baca pertanyaan pada sisi depan, lalu **ketuk kartu** untuk membalik dan melihat jawaban.
5. Setelah melihat jawaban, pengguna dapat memilih **Benar** atau **Salah** untuk setiap kartu. 
6. Setelah kartu terakhir dinilai:

   **Hasil:** layar ringkasan menampilkan durasi pengerjaan dan persentase jawaban benar, beserta rekor belajar.

### 9. Menghentikan dan Melanjutkan Sesi
1. Mulai sesi pada satu set.
2. Keluar dari sesi belajar yang masih berlangsung dengan menekan tombol kembali.

   **Hasil:** sesi berstatus terhenti.
4. Buka laman **Berkas**, lalu pilih filter **Sesi Terhenti**.

   **Hasil:** sesi yang berstatus terhenti sebelumnya akan tampil pada layar.
5. Masuk ke set tersebut. Tombol **Mulai Belajar** berubah menjadi **Lanjut Belajar**.
6. Tombol **Lanjut Belajar** akan membawa pengguna ke sesi terhenti sebelumnya, tepat pada bagian yang ditinggalkan.

### 10. Memeriksa Statistik
1. Buka laman **Statistik**.
2. Sebelum menjalankan sesi baru, akan ada data dummy, yaitu tingkat hafalan ± **78%**, **40** kartu, **5** set aktif.
3. Setelah menyelesaikan sesi pada skenario 8 dan 9, angka bertambah dengan bagian *Sesi Terbaru* menampilkan sesi terakhir, *Riwayat Belajar* menampilkan skor terakhir per set, dan waktu terakhir merujuk ke waktu sesi yang baru dipelajari.

### 11. Edit Profil dan Keluar
1. Dari Beranda, ketuk avatar pengguna untuk membuka halaman profil.
2. Ubah nama melalui menu edit profil.

   **Hasil:** Jika input kurang dari 2 karakter, muncul pesan peringatan. Jika input pengguna terdiri dari 2 karakter atau lebih, tampil "Profil berhasil diperbarui." dan nama pengguna baru akan disimpan.

3. Pilih **Keluar** sehingga pengguna dibawah kembali ke laman Login. Data pengguna akan tersimpan selama aplikasi tidak dimatikan. Namun, ketika masuk setelah aplikasi dijalankan kembali, data set dan sesi kembali ke data dummy awal karena disimpan di memori sementara.

---
