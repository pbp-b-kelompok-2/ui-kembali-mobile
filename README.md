# ♻️ UIKembali Mobile

UIKembali Mobile adalah aplikasi mobile berbasis **Flutter** yang menjadi pendamping aplikasi web UIKembali. Aplikasi ini ditujukan bagi mahasiswa Universitas Indonesia untuk menemukan, memberikan, atau menjual barang bekas yang masih layak pakai. Pengguna dapat mencari barang, mengajukan adopsi gratis atau pembelian, serta menggunakan fitur pendukung interaksi komunitas.

Aplikasi mobile dirancang untuk terintegrasi dengan web service Django dari proyek web UIKembali, sehingga data yang digunakan pada aplikasi mobile terhubung dengan data pada aplikasi web.

> **Status (Checkpoint 1):** kerangka aplikasi Flutter dan navigasi 5 tab tersedia. Modul Chat dan Katalog sudah memakai endpoint Django REST Framework. Modul Forum mengikuti tiga layar desain mobile (daftar komunitas, detail diskusi, dan buat posting), dengan daftar/pencarian/detail/komentar terhubung ke API. Pembuatan posting memerlukan pengguna yang sudah terautentikasi di backend. Profil masih berupa placeholder. Tautan APK menyusul setelah Checkpoint 1.

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
├── screens/                             # home_page, katalog/, forum/, transactions/, chat/, home_shell (bottom nav)
├── models/                              # Item, Transaction, Chat, CatalogFilter, ForumPost, ForumComment
├── services/                            # KatalogApi, ChatApi dan ForumApi (Django REST Framework)
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

### Endpoint Django REST Framework (modul Forum)

API Forum berada pada prefix `/api/forum/`. Operasi baca bersifat publik; operasi tulis memerlukan autentikasi session Django. Backend Forum tersedia pada source web branch `feat/dimas`; API perlu digabung dan dipasang di server sebelum dipakai aplikasi mobile.

| Method | Endpoint | Kegunaan | Akses |
|---|---|---|---|
| `GET` | `/api/forum/posts/` | Daftar diskusi; menerima parameter pencarian `search`. | Publik |
| `GET` | `/api/forum/posts/<id>/` | Detail diskusi. | Publik |
| `POST` | `/api/forum/posts/` | Membuat diskusi. | Login |
| `PATCH`, `DELETE` | `/api/forum/posts/<id>/` | Mengubah atau menghapus diskusi sendiri. | Login, pemilik |
| `POST` | `/api/forum/posts/<id>/like/` | Toggle like diskusi. | Login |
| `POST` | `/api/forum/posts/<id>/save/` | Toggle simpan diskusi. | Login |
| `GET` | `/api/forum/comments/?post=<id>` | Daftar komentar/balasan untuk diskusi. | Publik |
| `POST` | `/api/forum/comments/` | Membuat komentar/balasan (`post`, `content`, opsional `parent`). | Login |
| `PATCH`, `DELETE` | `/api/forum/comments/<id>/` | Mengubah atau menghapus komentar sendiri. | Login, penulis |

Pengunjung yang belum login tidak menerima field `contact`, dan koordinat dibulatkan sekitar 100 m. Autentikasi memakai session Django (`SessionAuthentication`); halaman yang membutuhkan login menampilkan ajakan masuk sampai alur login mobile dari modul Profil tersedia.

### Endpoint Django REST Framework (modul Chat)

Endpoint berikut berasal dari modul Chat pada repository web. Seluruh rute memerlukan sesi login; daftar percakapan dan pesan hanya dapat diakses oleh pesertanya.

| Method | Endpoint | Kegunaan |
|---|---|---|
| `GET` | `/api/v1/chat/conversations/` | Daftar percakapan pengguna, termasuk barang, peserta, pesan terakhir, dan jumlah pesan belum dibaca. |
| `POST` | `/api/v1/chat/conversations/` | Membuat atau menggunakan ulang percakapan untuk barang. Body JSON: `{"item":"<uuid>"}`. |
| `GET` | `/api/v1/chat/conversations/<uuid>/messages/` | Memuat riwayat pesan dan menandai pesan masuk sebagai telah dibaca. |
| `POST` | `/api/v1/chat/conversations/<uuid>/messages/` | Mengirim pesan. Body JSON: `{"body":"..."}`; pesan wajib berisi teks dan maksimal 2.000 karakter. |

Mobile menampilkan inbox dari tombol **Pesan** pada Riwayat transaksi, membuka chat dari detail barang atau transaksi, dan memperbarui pesan aktif setiap 3 detik. Tampilan percakapan mengikuti referensi Figma UIKembali dan gambar chat mobile: ringkasan barang, bubble pesan, status baca, serta area untuk menulis dan mengirim pesan. Status transaksi dan konfirmasi serah terima tidak disediakan oleh endpoint chat, sehingga tetap mengikuti modul transaksi dan tidak ditiru sebagai aksi chat.

Integrasi chat menggunakan autentikasi sesi Django yang sama dengan katalog. Karena alur login/sesi mobile belum tersedia, endpoint yang membutuhkan login menampilkan ajakan untuk masuk; pengiriman dan pembacaan pesan akan berfungsi setelah sesi autentikasi mobile tersedia.

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

