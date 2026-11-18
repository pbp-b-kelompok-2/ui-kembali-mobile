# ♻️ UIKembali Mobile

UIKembali Mobile adalah aplikasi mobile berbasis **Flutter** yang menjadi pendamping aplikasi web UIKembali. Aplikasi ini ditujukan bagi mahasiswa Universitas Indonesia untuk menemukan, memberikan, atau menjual barang bekas yang masih layak pakai. Pengguna dapat mencari barang, mengajukan adopsi gratis atau pembelian, serta menggunakan fitur pendukung interaksi komunitas.

Aplikasi mobile dirancang untuk terintegrasi dengan web service Django dari proyek web UIKembali, sehingga data yang digunakan pada aplikasi mobile terhubung dengan data pada aplikasi web.

> **Status (Checkpoint 1):** kerangka aplikasi Flutter, navigasi 5 tab, dan modul **Katalog** (Beranda, Jelajahi & filter, detail barang, Riwayat transaksi) sudah terhubung ke endpoint Django REST Framework. Tab Forum dan Profil masih berupa halaman placeholder milik anggota lain. Tautan APK menyusul setelah Checkpoint 1.

## Menjalankan Aplikasi

Prasyarat: Flutter 3.50 atau lebih baru.

```bash
flutter pub get
flutter run                                   # memakai web service PWS
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # server Django lokal (emulator Android)
flutter test
```

Struktur kode utama:

```text
lib/
├── main.dart, theme.dart, config.dart   # entry point, token desain (font Inter), alamat API
├── models/                              # Item, Transaction, CatalogFilter
├── services/katalog_api.dart            # pemanggilan HTTP ke Django REST Framework
├── screens/                             # home_page, katalog/, transactions/, home_shell (bottom nav)
└── widgets/item_card.dart               # kartu barang yang dipakai ulang
```

## Repository Proyek

| Komponen | Repository / Alamat |
|---|---|
| Aplikasi mobile (Flutter) | [ui-kembali-mobile](https://github.com/pbp-b-kelompok-2/ui-kembali-mobile) |
| Aplikasi web dan backend Django | [ui-kembali](https://github.com/pbp-b-kelompok-2/ui-kembali) |
| Web service (PWS) | [UIKembali Web](https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id/) |

Repository aplikasi web dan repository aplikasi mobile dipisahkan sesuai ketentuan tugas Final Term PBP.

## Anggota Kelompok

| Nama | NPM |
|---|---:|
| Axel Sebastian Saragih | 2506590063 |
| Dimas Bayu Nugroho | 2506534636 |
| Elvis Sestomi | 2506544990 |
| Muhammad Rifky Padjri | 2506585800 |
| Owen Viriya Chandra | 2506539196 |

## Deskripsi Aplikasi

UIKembali membantu mahasiswa UI memanfaatkan kembali barang yang masih layak pakai. Barang dapat ditawarkan secara gratis untuk diadopsi atau dijual kepada pengguna lain. Dengan aplikasi mobile, pengguna diharapkan dapat mengakses katalog dan fitur komunitas UIKembali melalui perangkat Android.

Fitur yang menjadi cakupan pengembangan aplikasi mobile mengikuti modul kelompok berikut. Daftar ini merupakan **target pembagian implementasi mobile**, bukan pernyataan bahwa seluruh fitur Flutter sudah selesai di repository ini.

## Modul dan Pembagian Tugas

| Modul | Penanggung Jawab | Cakupan Pengembangan Mobile |
|---|---|---|
| **Profile dan Autentikasi** | Elvis Sestomi | Integrasi autentikasi UI SSO melalui mekanisme yang disediakan backend, menampilkan informasi profil, serta mengelola data profil pengguna. |
| **Posting dan Katalog Barang** | Owen Viriya Chandra | Menampilkan katalog dan detail barang, pencarian dan filter, membuat serta mengelola posting barang, dan mengajukan atau mengelola permintaan adopsi/pembelian. |
| **Chat** | Axel Sebastian Saragih | Menampilkan daftar percakapan dan detail percakapan, mengirim pesan, serta menampilkan riwayat komunikasi antara pemilik barang dan calon pengadopsi/pembeli. |
| **Forum** | Dimas Bayu Nugroho | Menampilkan daftar dan detail diskusi, membuat serta mengelola posting, komentar dan balasan, serta interaksi seperti menyukai dan menyimpan posting. |
| **Review dan Report** | Muhammad Rifky Padjri | Menampilkan ulasan dan rating, mengirim ulasan setelah transaksi selesai, serta membuat dan melihat laporan terkait barang atau pengguna. |

Pembagian modul mobile ini mengacu pada pembagian tanggung jawab dan fitur pada proyek web UIKembali. Penyesuaian dapat dilakukan mengikuti kebutuhan integrasi dan perkembangan implementasi Flutter.

## Peran Pengguna

UIKembali memiliki satu jenis akun utama, yaitu pengguna yang masuk menggunakan akun Universitas Indonesia. Pengguna yang sama dapat menjalankan peran berbeda sesuai aktivitasnya.

### 1. Pengunjung

Pengunjung dapat melihat informasi dan katalog barang yang memang disediakan untuk akses publik. Untuk menggunakan fungsi yang membutuhkan identitas pengguna, pengunjung perlu masuk terlebih dahulu.

### 2. Pemilik atau Penjual

Pengguna sebagai pemilik/penjual dapat:

- Membuat posting barang yang ingin diberikan atau dijual.
- Mengubah dan menghapus posting miliknya.
- Menentukan jenis penawaran, yaitu adopsi gratis atau penjualan dengan harga tertentu.
- Melihat, menerima, atau menolak permintaan transaksi.
- Berkomunikasi dengan calon pengadopsi atau pembeli melalui chat.
- Melihat ulasan yang diterima setelah transaksi.

### 3. Pengadopsi atau Pembeli

Pengguna sebagai pengadopsi/pembeli dapat:

- Melihat, mencari, dan memfilter katalog barang.
- Melihat detail barang dan informasi lokasi.
- Mengajukan adopsi gratis atau pembelian.
- Berkomunikasi dengan pemilik barang melalui chat.
- Memberikan ulasan dan rating setelah transaksi selesai.
- Melaporkan barang atau pengguna yang bermasalah.

Satu akun dapat menjadi pemilik/penjual pada suatu transaksi dan menjadi pengadopsi/pembeli pada transaksi lainnya.

## Alur Integrasi dengan Web Service Django

Aplikasi mobile Flutter menggunakan web service dari aplikasi web UIKembali yang dikembangkan dengan Django. Dengan integrasi ini, aplikasi mobile dan web menggunakan sumber data backend yang sama.

**Alamat web service:** [https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id/](https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id/)

### Alur pertukaran data

1. Pengguna membuka aplikasi UIKembali Mobile.
2. Aplikasi mengirim HTTP request secara asynchronous ke web service Django sesuai fitur yang digunakan.
3. Django menerima request, menjalankan validasi dan pemeriksaan hak akses yang diperlukan, kemudian mengambil atau memperbarui data.
4. Backend mengirimkan response dalam format JSON untuk endpoint yang menyediakan response JSON.
5. Aplikasi Flutter mengolah response JSON menjadi objek/model Dart.
6. Data yang telah diolah ditampilkan pada widget Flutter. Ketika pengguna melakukan aksi yang mengubah data, aplikasi mengirim request ke endpoint backend yang sesuai dan memperbarui tampilan berdasarkan response dari server.

### Endpoint Django REST Framework (modul Katalog)

Endpoint berikut dibangun dengan Django REST Framework pada repository web UIKembali (branch `feat/katalog-drf`, prefix `/api/v1/`). Respons daftar memakai amplop `{count, page, num_pages, results}`.

| Method | Endpoint | Kegunaan | Akses |
|---|---|---|---|
| `GET` | `/api/v1/items/` | Daftar barang. Filter: `q`, `category`, `type` (`ADOPSI`/`JUAL`), `condition`, `location`, `sort`, `min_price`, `max_price`, `page`. | Semua pengunjung |
| `POST` | `/api/v1/items/` | Memasang barang (JSON atau `multipart` bila ada foto). | Pengguna login |
| `GET` | `/api/v1/items/mine/` | Barang milik pengguna. | Pengguna login |
| `GET` | `/api/v1/items/<uuid>/` | Detail barang. | Semua pengunjung |
| `PUT`/`PATCH`/`DELETE` | `/api/v1/items/<uuid>/` | Ubah / hapus (soft delete) barang. | Pemilik barang |
| `POST` | `/api/v1/items/<uuid>/ajukan/` | Mengajukan adopsi/pembelian. | Pengguna login, bukan pemilik |
| `GET` | `/api/v1/transactions/` | Riwayat transaksi (sebagai peminta atau pemilik). Filter: `type`, `page`. | Pengguna login |

Pengunjung yang belum login tidak menerima field `contact`, dan koordinat dibulatkan sekitar 100 m. Autentikasi memakai session Django (`SessionAuthentication`); halaman yang membutuhkan login menampilkan ajakan masuk sampai alur login mobile dari modul Profil tersedia.

Contoh penggunaan dengan alamat PWS:

```text
GET https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id/api/v1/items/?category=BUKU&type=ADOPSI
GET https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id/api/v1/items/<uuid>/
```

### Integrasi autentikasi

Aplikasi web UIKembali menggunakan UI Single Sign-On (SSO) melalui CAS untuk autentikasi pengguna. Pada aplikasi mobile, alur login dan cara Flutter mempertahankan status autentikasi perlu disesuaikan dengan mekanisme yang didukung backend. Request yang membutuhkan login harus membawa kredensial/sesi sesuai mekanisme tersebut agar backend dapat memverifikasi identitas dan hak akses pengguna.

### Pengolahan response JSON di Flutter

Secara umum, setiap fitur mobile akan menjalankan alur berikut:

1. Memanggil endpoint Django melalui HTTP request asynchronous.
2. Memeriksa status response dari server.
3. Melakukan parsing JSON ke model/data class Dart.
4. Menangani kondisi loading, data kosong, dan error.
5. Menampilkan data pada widget yang sesuai.
6. Mengirim perubahan data ke backend melalui endpoint yang sesuai, lalu menyinkronkan tampilan dengan response terbaru.

## Desain UI/UX

Desain UIKembali dibuat menggunakan Figma:

- [Figma UIKembali](https://www.figma.com/design/rTVD1SeON4Oi2QX6KCMLmN/UIKembali?node-id=0-1)

Tautan tersebut merupakan referensi desain proyek UIKembali. Frame atau halaman yang khusus menggambarkan tampilan mobile dapat ditambahkan atau diperbarui pada file Figma tersebut sesuai perkembangan aplikasi Flutter.

## APK dan Deployment

| Artefak | Tautan / Status |
|---|---|
| APK Android | Belum tersedia. Tautan akan ditambahkan setelah aplikasi mobile selesai dibangun dan dirilis. |
| GitHub Releases | Belum tersedia. |
| Bitrise | Belum tersedia / belum dicantumkan. |

Sesuai ketentuan Final Term, APK dapat ditambahkan ke README setelah tahap implementasi dan proses build aplikasi selesai. APK yang telah dirilis nantinya dapat dicantumkan melalui GitHub Releases dan platform deployment yang digunakan kelompok.

## Referensi

- [Panduan Final Term PBP](https://pbp.cs.ui.ac.id/assignments/group/finalterm.html)
- [Repository Web UIKembali](https://github.com/pbp-b-kelompok-2/ui-kembali)
- [UIKembali Web Service (PWS)](https://elvis-sestomi-ui-kembali.pws.cs.ui.ac.id/)
- [Dokumentasi Flutter](https://docs.flutter.dev/)
- [Dokumentasi Django](https://docs.djangoproject.com/)
- [Dokumentasi UI SSO untuk Django](https://github.com/RistekCSUI/django-sso-ui)

