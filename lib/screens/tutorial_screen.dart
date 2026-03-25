import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _incrementCounter();
  }

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('tutorial_count') ?? 0;
    await prefs.setInt('tutorial_count', count + 1);
  }

  Future<void> _onStart() async {
    final prefs = await SharedPreferences.getInstance();
    if (_dontShowAgain) {
      await prefs.setBool('show_every_10', true);
      await prefs.setInt('tutorial_counter_for_interval', 0);
    } else {
      await prefs.setBool('show_every_10', false);
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
              Color(0xFFF44336),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Header
            Column(
              children: [
                Image.asset(
                  'assets/my_imposter.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 12),
                const Text(
                  'SPY OYUNU',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Nasıl Oynanır?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: const [
                  _TutorialSection(
                    icon: Icons.play_arrow_rounded,
                    iconColor: Color(0xFFFF9800),
                    title: 'Oyunun Amacı',
                    description:
                    'Oyunculardan biri Imposter\'dır! Diğer oyuncular seçilen kategoriden rastgele bir kelimeyi bilirken, Imposter bu kelimeyi bilmez. Imposter kelimeyi tahmin etmeye çalışırken, diğer oyuncular Imposter\'ı bulmaya çalışır.',
                  ),
                  _TutorialSection(
                    icon: Icons.category_rounded,
                    iconColor: Color(0xFF2196F3),
                    title: 'Kategoriler Nasıl Çalışır?',
                    description:
                    'Önce bir kategori seçilir (Meslekler, Yiyecekler, Sporcular vb.). Seçilen kategoriden rastgele bir kelime belirlenir. Normal oyuncular bu kelimeyi görür, Imposter göremez ancak kategoriyi bilir (İpucu açıksa).',
                  ),
                  _TutorialSection(
                    icon: Icons.group_rounded,
                    iconColor: Color(0xFF4CAF50),
                    title: 'Oyuncu Rolleri',
                    description:
                    '• Normal Oyuncular: Kelimeyi görebilir ve Imposter\'ı bulmaya çalışır.\n• Imposter: Kelimeyi göremez, kategori ipucuyla ve diğer oyuncuları gözlemleyerek kelimeyi tahmin etmeye çalışır.',
                  ),
                  _TutorialSection(
                    icon: Icons.smartphone_rounded,
                    iconColor: Color(0xFF9C27B0),
                    title: 'Kartlar Nasıl Gösterilir?',
                    description:
                    'Oyun başladığında her oyuncu sırayla kartını görür. Kartınızı gördükten sonra "Sonraki Oyuncu" butonuna basarak telefonu bir sonrakine verin. Kartınızı kimseye göstermeyin!',
                  ),
                  _TutorialSection(
                    icon: Icons.lightbulb_rounded,
                    iconColor: Color(0xFFFFEB3B),
                    title: 'İpucu Ayarı',
                    description:
                    'İpucu AÇIK: Imposter kategoriye ait ipucu görür.\n\nİpucu KAPALI: Imposter hiçbir ipucu görmez, sadece "SPY" yazısını görür — daha zor mod!',
                  ),
                  _TutorialSection(
                    icon: Icons.chat_rounded,
                    iconColor: Color(0xFF00BCD4),
                    title: 'Oyun Süreci',
                    description:
                    '1. Herkes kartını kontrol eder\n2. Oyuncular birbirine kelimeyle ilgili sorular sorar\n3. Cevaplar vererek birbirinizi test edin\n4. Süre bitince oylama başlar',
                  ),
                  _TutorialSection(
                    icon: Icons.timer_rounded,
                    iconColor: Color(0xFFE91E63),
                    title: 'Zamanlayıcı',
                    description:
                    'Oyun başladığında süre akmaya başlar. Duraklatma, yeniden başlatma ve erken bitirme seçenekleri vardır. Süre bitince otomatik olarak oylama ekranına geçilir!',
                  ),
                  _TutorialSection(
                    icon: Icons.how_to_vote_rounded,
                    iconColor: Color(0xFF673AB7),
                    title: 'Oylama Sistemi',
                    description:
                    'Süre bitince her oyuncu sırayla şüphelendiği kişiye oy verir. Oylar gizlidir. En çok oy alan kişi açıklanır ve Imposter ise Normal Oyuncular kazanır!',
                  ),
                  _TutorialSection(
                    icon: Icons.emoji_events_rounded,
                    iconColor: Color(0xFFFF5722),
                    title: 'Kazanma Koşulları',
                    description:
                    '• Normal Oyuncular: Imposter\'ı doğru tahmin ederse kazanır.\n\n• Imposter: Yakalanmadan kalır ve kelimeyi tahmin ederse kazanır.',
                  ),
                  _TutorialSection(
                    icon: Icons.description_rounded,
                    iconColor: Color(0xFF795548),
                    title: 'Örnek: Meslekler Kategorisi',
                    description:
                    'Kategori: Meslekler → Rastgele kelime: "Doktor" seçilir\n\n• Normal oyuncular "Doktor" kelimesini görür\n• Imposter sadece "Meslekler" kategorisini bilir (ipucu açıksa)\n• Oyuncular sorular sorarak Imposter\'ı bulmaya çalışır',
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            // Footer
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        onChanged: (v) =>
                            setState(() => _dontShowAgain = v ?? false),
                        checkColor: const Color(0xFFE91E63),
                        fillColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const Text(
                        'Bir daha gösterme',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _onStart,
                      icon: const Icon(Icons.play_arrow_rounded,
                          color: Color(0xFFE91E63)),
                      label: const Text(
                        'OYUNA BAŞLA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _TutorialSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}