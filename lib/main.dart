import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const BukuKontakApp());
}

// Model data untuk menyimpan struktur informasi kontak
class Contact {
  final String name;
  final String email;
  final String phone;
  final String? category;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.category,
  });
}

// Model data untuk menyimpan struktur informasi favorit
class Favorite {
  final String name;
  final String email;
  final String phone;

  Favorite({required this.name, required this.email, required this.phone});
}

// Root widget untuk konfigurasi tema dan rute navigasi aplikasi
class BukuKontakApp extends StatelessWidget {
  const BukuKontakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Buku Kontak',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBF5FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      // Definisi rute navigasi halaman
      initialRoute: '/',
      routes: {
        '/': (context) => const BerandaScreen(),
        '/tambah': (context) => const TambahKontakScreen(),
        '/tambah-favorit': (context) => const TambahFavoritScreen(),
        '/tentang': (context) => const TentangScreen(),
      },
    );
  }
}

// Halaman utama yang mengelola daftar kontak & favorit dan navigasi tab/drawer
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Array untuk menyimpan data kontak secara dinamis di dalam memori
  final List<Contact> daftarKontak = [];
  // Array untuk menyimpan data favorit secara terpisah dari kontak
  final List<Favorite> daftarFavorit = [];
  final StreamController<String> _searchController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.close();
    super.dispose();
  }

  // Pindah ke halaman form kontak dan menerima objek Contact baru hasil Navigator.pop
  Future<void> _tambahKontak(BuildContext context) async {
    final newContact = await Navigator.pushNamed(context, '/tambah');
    if (newContact != null && newContact is Contact) {
      setState(() {
        daftarKontak.add(newContact);
      });
    }
  }

  // Pindah ke halaman form favorit dan menerima objek Favorite baru hasil Navigator.pop
  Future<void> _tambahFavorit(BuildContext context) async {
    final newFavorite = await Navigator.pushNamed(context, '/tambah-favorit');
    if (newFavorite != null && newFavorite is Favorite) {
      setState(() {
        daftarFavorit.add(newFavorite);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BUKU KONTAK'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.account_circle), text: 'Kontak'),
            Tab(icon: Icon(Icons.star), text: 'Favorit'),
          ],
        ),
      ),
      // Sider navigation drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2196F3)),
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Kontak'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0); // Pindah ke Tab Kontak
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () {
                Navigator.pop(context);
                _tambahKontak(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1); // Pindah ke Tab Favorit
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tentang');
              },
            ),
          ],
        ),
      ),
      // Tampilan konten berdasarkan tab yang aktif
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Daftar Kontak
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cari kontak',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchController.add,
                ),
              ),
              Expanded(
                child: StreamBuilder<String>(
                  stream: _searchController.stream,
                  builder: (context, snapshot) {
                    final keyword = (snapshot.data ?? '').toLowerCase();
                    final kontakTersaring = daftarKontak.where((kontak) {
                      final namaCocok = kontak.name.toLowerCase().contains(keyword);
                      final kategoriCocok =
                          kontak.category?.toLowerCase().contains(keyword) ??
                          false;
                      return namaCocok || kategoriCocok;
                    }).toList();

                    if (kontakTersaring.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada kontak',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: kontakTersaring.length,
                      itemBuilder: (context, index) {
                        final kontak = kontakTersaring[index];
                        final inisial = kontak.name.trim().isEmpty
                            ? '?'
                            : kontak.name.trim()[0].toUpperCase();
                        return ListTile(
                          leading: CircleAvatar(child: Text(inisial)),
                          title: Text(
                            kontak.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${kontak.email}\n${kontak.phone}\n${kontak.category ?? 'Tanpa kategori'}',
                          ),
                          isThreeLine: true,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Tab 2: Daftar Kontak Favorit
          daftarFavorit.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada kontak favorit',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: daftarFavorit.length,
                  itemBuilder: (context, index) {
                    final favorit = daftarFavorit[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        favorit.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text('${favorit.email}\n${favorit.phone}'),
                      isThreeLine: true,
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: const Color(0xFF21005D),
        onPressed: () {
          if (_tabController.index == 0) {
            _tambahKontak(context);
          } else {
            _tambahFavorit(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Halaman formulir input data kontak baru
class TambahKontakScreen extends StatefulWidget {
  const TambahKontakScreen({super.key});

  @override
  State<TambahKontakScreen> createState() => _TambahKontakScreenState();
}

class _TambahKontakScreenState extends State<TambahKontakScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controller untuk membaca nilai dari form input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();

  @override
  void dispose() {
    // Membersihkan controller untuk mencegah kebocoran memori (memory leak)
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  // Memvalidasi input dan mengembalikan objek Contact ke halaman beranda
  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_namaController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _hpController.text.isNotEmpty) {
      final newContact = Contact(
        name: _namaController.text,
        email: _emailController.text,
        phone: _hpController.text,
        category: _kategoriController.text.isEmpty
            ? null
            : _kategoriController.text,
      );
      Navigator.pop(context, newContact);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kontak')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Email harus mengandung @';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hpController,
                decoration: const InputDecoration(labelText: 'No Handphone'),
                validator: (value) {
                  if (value == null || !RegExp(r'^\d{10,}$').hasMatch(value)) {
                    return 'No Handphone minimal 10 digit angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori (opsional)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEADDFF),
                  foregroundColor: const Color(0xFF21005D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _simpan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman formulir input data favorit baru
class TambahFavoritScreen extends StatefulWidget {
  const TambahFavoritScreen({super.key});

  @override
  State<TambahFavoritScreen> createState() => _TambahFavoritScreenState();
}

class _TambahFavoritScreenState extends State<TambahFavoritScreen> {
  // Controller untuk membaca nilai dari form input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  // Memvalidasi input dan mengembalikan objek Favorite ke halaman beranda
  void _simpan() {
    if (_namaController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _hpController.text.isNotEmpty) {
      final newFavorite = Favorite(
        name: _namaController.text,
        email: _emailController.text,
        phone: _hpController.text,
      );
      Navigator.pop(context, newFavorite);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Favorit')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hpController,
              decoration: const InputDecoration(labelText: 'No Handphone'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEADDFF),
                foregroundColor: const Color(0xFF21005D),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _simpan,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman profil statis pengguna
class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 65,
              backgroundImage: AssetImage('assets/FotoSaya.jpg'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Muchammad Naufal Fariz',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('XII RPL B', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            const Text(
              'SMK Negeri 5 Surakarta',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
