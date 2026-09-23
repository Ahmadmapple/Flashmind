import 'package:flutter/material.dart';

class BerkasPage extends StatelessWidget {
  const BerkasPage({super.key});

  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);

  static const List<_FlashcardSet> _sets = [
    _FlashcardSet(
      title: 'Nama Set',
      description: 'Deskripsi set',
      cardCount: 0,
    ),
    _FlashcardSet(
      title: 'Bahasa Jepang',
      description: 'Kosakata bahasa Jepang',
      cardCount: 30,
    ),
    _FlashcardSet(
      title: 'Biologi',
      description: 'Definisi dari istilah-istilah ilmiah',
      cardCount: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterRow(),
                  const SizedBox(height: 18),
                  ..._sets.map(
                    (set) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _FlashcardSetCard(set: set),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 18, 20, 20),
      decoration: const BoxDecoration(color: _accentColor),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Berkas',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
          ),
          ElevatedButton(
            // To do: hubungkan ke alur "Tambah Set" saat sudah tersedia.
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(_primaryColor),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              ),
              minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            child: const Text(
              'Tambah Set',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _FilterChip(label: 'Semua Set', selected: true, onPressed: () {}),
        const SizedBox(width: 8),
        _FilterChip(label: 'Perlu Diulas', selected: false, onPressed: () {}),
      ],
    );
  }
}

class _FlashcardSetCard extends StatelessWidget {
  const _FlashcardSetCard({required this.set});

  final _FlashcardSet set;

  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26, width: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  set.title,
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              Text(
                '${set.cardCount} kartu',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            set.description,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardActionButton(
                label: 'Kelola Set',
                backgroundColor: _accentColor,
                foregroundColor: _primaryColor,
                onPressed: () {},
              ),
              _CardActionButton(
                label: 'Mulai Belajar',
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? _primaryColor : Colors.white,
        foregroundColor: selected ? Colors.white : _primaryColor,
        side: BorderSide(color: selected ? _primaryColor : Colors.black26),
        elevation: 0,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}

class _FlashcardSet {
  const _FlashcardSet({
    required this.title,
    required this.description,
    required this.cardCount,
  });

  final String title;
  final String description;
  final int cardCount;
}
