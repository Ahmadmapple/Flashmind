import 'package:flutter/material.dart';
import '../repositories/flash_mind_repository.dart';

/// Model sementara untuk kartu yang dibuat AI dari PDF.
class _AiCard {
  _AiCard({required this.front, required this.back});

  final String front;
  final String back;
  bool accepted = true;
}

/// Halaman untuk meninjau kartu yang dibuat AI dari dokumen PDF.
/// Pengguna dapat menerima atau menolak tiap kartu sebelum disimpan ke set.
class AiCardReviewPage extends StatefulWidget {
  const AiCardReviewPage({
    super.key,
    required this.setId,
    required this.fileName,
  });

  final String setId;
  final String fileName;

  @override
  State<AiCardReviewPage> createState() => _AiCardReviewPageState();
}

class _AiCardReviewPageState extends State<AiCardReviewPage> {
  static const Color _primaryColor   = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _successColor   = Color(0xFF2D6A4F);

  bool _isLoading = true;
  bool _isSaving  = false;

  // Kartu dummy hasil "AI" — dalam produksi ini diganti dengan respons API
  final List<_AiCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _simulateAiGeneration();
  }

  /// Simulasi delay pemrosesan AI lalu isi kartu dummy.
  Future<void> _simulateAiGeneration() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _cards.addAll([
        _AiCard(
          front: 'Apa fungsi utama membran sel?',
          back:
              'Membran sel mengatur apa yang masuk dan keluar dari sel, menjaga lingkungan internal sel tetap stabil.',
        ),
        _AiCard(
          front: 'Apa itu mitokondria?',
          back:
              'Mitokondria adalah organel penghasil energi sel dalam bentuk ATP melalui proses respirasi seluler.',
        ),
        _AiCard(
          front: 'Jelaskan proses fotosintesis secara singkat.',
          back:
              'Fotosintesis adalah proses tumbuhan mengubah cahaya matahari, air, dan CO₂ menjadi glukosa dan oksigen.',
        ),
        _AiCard(
          front: 'Apa perbedaan sel prokariotik dan eukariotik?',
          back:
              'Sel prokariotik tidak memiliki nukleus bermembran, sedangkan sel eukariotik memiliki nukleus yang terlindungi membran inti.',
        ),
        _AiCard(
          front: 'Apa fungsi ribosom dalam sel?',
          back:
              'Ribosom berperan dalam sintesis protein dengan menerjemahkan informasi genetik dari mRNA menjadi rantai asam amino.',
        ),
      ]);
      _isLoading = false;
    });
  }

  int get _acceptedCount => _cards.where((c) => c.accepted).length;

  Future<void> _saveAcceptedCards() async {
    final accepted = _cards.where((c) => c.accepted).toList();
    if (accepted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu kartu untuk disimpan.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = FlashMindRepository.instance;
    for (final card in accepted) {
      await repo.addFlashcard(
        setId:     widget.setId,
        frontText: card.front,
        backText:  card.back,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${accepted.length} kartu berhasil ditambahkan ke set.',
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );

    // Kembali ke detail set (2 halaman: review + pilih PDF)
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildReviewBody(),
      bottomNavigationBar: _isLoading ? null : _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
      ),
      title: const Text(
        'Tinjau Kartu AI',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: false,
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 24),
          const Text(
            'AI sedang membuat kartu\ndari dokumen kamu...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildReviewBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header info
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama file
              Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Color(0xFFE87A5D),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE87A5D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'AI membuat ${_cards.length} kartu. '
                'Centang kartu yang ingin disimpan ke set.',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Toggle pilih semua
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  final allAccepted = _acceptedCount == _cards.length;
                  setState(() {
                    for (final c in _cards) {
                      c.accepted = !allAccepted;
                    }
                  });
                },
                icon: Icon(
                  _acceptedCount == _cards.length
                      ? Icons.deselect
                      : Icons.select_all,
                  size: 18,
                  color: _primaryColor,
                ),
                label: Text(
                  _acceptedCount == _cards.length
                      ? 'Batalkan Semua'
                      : 'Pilih Semua',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Text(
                '$_acceptedCount/${_cards.length} dipilih',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Daftar kartu
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            itemCount: _cards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildCardItem(_cards[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(_AiCard card, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.accepted
              ? const Color(0xFF2D6A4F)
              : const Color(0xFFE8E4DB),
          width: card.accepted ? 2 : 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            card.accepted = !card.accepted;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox custom
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: card.accepted ? _successColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: card.accepted ? _successColor : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: card.accepted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),

              // Konten kartu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label + nomor
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3C279).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'KARTU ${index + 1}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Color(0xFF8B6914),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Depan
                    const Text(
                      'Depan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      card.front,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Divider tipis
                    Container(
                      height: 1,
                      color: const Color(0xFFEEECE8),
                    ),
                    const SizedBox(height: 10),

                    // Belakang
                    const Text(
                      'Belakang',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      card.back,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final hasAccepted = _acceptedCount > 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_isSaving || !hasAccepted) ? null : _saveAcceptedCards,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasAccepted ? _primaryColor : Colors.grey.shade300,
              foregroundColor: hasAccepted ? Colors.white : Colors.grey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    hasAccepted
                        ? 'Simpan $_acceptedCount Kartu ke Set'
                        : 'Pilih minimal 1 kartu',
                  ),
          ),
        ),
      ),
    );
  }
}
