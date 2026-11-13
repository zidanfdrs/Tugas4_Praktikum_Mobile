import 'package:flutter/material.dart';
import 'package:tugas4_praktikum/api_service.dart';
import 'package:tugas4_praktikum/article_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF315C42);
    return MaterialApp(
      title: 'Berita Kuliner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFFFFBF4),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF4),
        useMaterial3: true,
      ),
      home: const NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.fetchArticles});

  final Future<List<ArticleModel>> Function()? fetchArticles;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<ArticleModel>> _articles;
  Object? _refreshError;
  bool _showBackToTop = false;

  Future<List<ArticleModel>> _fetchArticles() =>
      widget.fetchArticles?.call() ?? ApiService().fetchArticles();

  @override
  void initState() {
    super.initState();
    _articles = _fetchArticles();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showBackToTop && mounted) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  Future<void> _refreshArticles() {
    final refreshedArticles = _fetchArticles();
    setState(() {
      _articles = refreshedArticles;
      _refreshError = null;
    });

    return refreshedArticles.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (mounted) {
          setState(() => _refreshError = error);
        }
      },
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Berita Kuliner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFFFFBF4),
        surfaceTintColor: Colors.transparent,
        leading: const Icon(Icons.restaurant_menu, color: Color(0xFF315C42)),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF315C42),
        onRefresh: _refreshArticles,
        child: FutureBuilder<List<ArticleModel>>(
          future: _articles,
          builder: (context, snapshot) {
            final articles = snapshot.data ?? const <ArticleModel>[];
            final error = _refreshError ?? snapshot.error;

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: articles.isEmpty ? 2 : articles.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _PageIntro();
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    articles.isEmpty) {
                  return const _StatusMessage(
                    icon: null,
                    message: 'Memuat berita kuliner...',
                    showProgress: true,
                  );
                }

                if (error != null && articles.isEmpty) {
                  return _ErrorMessage(
                    message: error.toString(),
                    onRetry: _refreshArticles,
                  );
                }

                if (articles.isEmpty) {
                  return const _StatusMessage(
                    icon: Icons.ramen_dining_outlined,
                    message: 'Belum ada berita makanan untuk ditampilkan.',
                  );
                }

                return _ArticleCard(article: articles[index - 1]);
              },
            );
          },
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              tooltip: 'Kembali ke atas',
              backgroundColor: const Color(0xFF315C42),
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE7EFE3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cerita di balik setiap sajian',
              style: TextStyle(
                color: Color(0xFF203D2C),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Kabar terbaru seputar makanan, restoran, dan dunia kuliner.',
              style: TextStyle(color: Color(0xFF526657), height: 1.4),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.restaurant, size: 16, color: Color(0xFF315C42)),
                SizedBox(width: 6),
                Text(
                  'BERITA MAKANAN',
                  style: TextStyle(
                    color: Color(0xFF315C42),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.urlToImage != null)
            Image.network(
              article.urlToImage!,
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _ImagePlaceholder(),
            )
          else
            const _ImagePlaceholder(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KULINER',
                  style: TextStyle(
                    color: Color(0xFFB05A35),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  article.judul,
                  style: const TextStyle(
                    color: Color(0xFF242A24),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (article.deskripsi != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    article.deskripsi!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF657067),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      color: const Color(0xFFF1E8D8),
      alignment: Alignment.center,
      child: const Icon(
        Icons.dinner_dining,
        size: 54,
        color: Color(0xFF9A7857),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.message,
    this.showProgress = false,
  });

  final IconData? icon;
  final String message;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          if (showProgress)
            const CircularProgressIndicator()
          else
            Icon(icon, size: 44, color: const Color(0xFF7C8C7C)),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF526657)),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 44, color: Color(0xFFB05A35)),
          const SizedBox(height: 12),
          const Text(
            'Berita belum bisa dimuat',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF657067)),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
