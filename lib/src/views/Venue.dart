import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import 'package:TURF_TOWN_/src/Screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:TURF_TOWN_/src/widgets/Navigation_bar.dart';

// --- Data Model ---
class TurfItem {
  final String imagePath;
  final String title;
  final String subtitle;
  final String rating;

  TurfItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
  });

  String get id => title;
}

class CricketScorerHeader extends StatefulWidget {
  const CricketScorerHeader({super.key});

  @override
  State<CricketScorerHeader> createState() => _CricketScorerHeaderState();
}

class _CricketScorerHeaderState extends State<CricketScorerHeader> {
  static const Color accentColor = Colors.white;
  static const Color searchBarBackgroundColor = Color(0xFF545454);
  static const double iconSize = 25.0;
  static const Color dividerColor = Color(0xFFFFFFFF);
  static const Color favouritesContainerColor = Color(0xFFD9D9D9);

  int _selectedIndex = 2;

  final List<TurfItem> _allTurfs = [
    TurfItem(imagePath: 'assets/images/cricket_ground_1.png.jpg', title: 'Goat Sports...', subtitle: 'Lawspet', rating: '4.5'),
    TurfItem(imagePath: 'assets/images/cricket_ground_2.png.jpg', title: 'The Sports S...', subtitle: 'Kottakuppam', rating: '4.0'),
    TurfItem(imagePath: 'assets/images/cricket_ground_10.png.jpeg', title: 'Providence Turf', subtitle: 'Gorimedu', rating: '4.6'),
    TurfItem(imagePath: 'assets/images/cricket_ground_4.png.jpg', title: 'Turf 10', subtitle: 'Ellaipillaichavady ~ 3.5km', rating: '4.2'),
    TurfItem(imagePath: 'assets/images/cricket_ground_6.png.png', title: 'Pondy Pitch', subtitle: 'Ariyankuppam ~ 7.3km', rating: '4.8'),
    TurfItem(imagePath: 'assets/images/cricket_ground_7.png.png', title: 'Goat Sports Arena', subtitle: 'Lawspet ~ 0.7km', rating: '4.8'),
    TurfItem(imagePath: 'assets/images/cricket_ground_8.png.png', title: 'Lotus', subtitle: 'Lawspet ~ 0.5km', rating: '4.1'),
    TurfItem(imagePath: 'assets/images/cricket_ground_9.png.png', title: 'Aadukalam', subtitle: 'Lawspet ~ 0.5km', rating: '3.7'),
    TurfItem(imagePath: 'assets/images/cricket_ground_4.png.jpg', title: 'The Sports Studio', subtitle: 'Lawspet ~ 0.5km', rating: '4.5'),
  ];

  final List<String> _favoriteTurfIds = ['Goat Sports...', 'The Sports S...', 'Providence Turf'];

  void _toggleFavorite(String turfId) {
    setState(() {
      if (_favoriteTurfIds.contains(turfId)) {
        _favoriteTurfIds.remove(turfId);
      } else {
        _favoriteTurfIds.add(turfId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<TurfItem> favoriteCards =
    _allTurfs.where((turf) => _favoriteTurfIds.contains(turf.id)).toList();

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: Appbg1.mainGradient,
        ),
        child: Column(
          children: [
            // --- HEADER SECTION ---
            SafeArea(
              bottom: false,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(
                          'Cricket',
                          style: GoogleFonts.poppins(
                            color: accentColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Scorer',
                            style: GoogleFonts.poppins(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.headset_mic_outlined,
                          color: Colors.white,
                          size: 25.0,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 25.0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),


                  ],
                    ),

                ),
              ),


            // --- SEARCH BAR (same style as Home Page) ---
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF545454),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    hintText: "Search...",
                    hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // --- DIVIDER 1 ---
            Center(
              child: SizedBox(
                width: 360.0,
                child: Container(
                  height: 1.0,
                  color: dividerColor,
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // --- YOUR FAVORITES LABEL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 116.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                    color: favouritesContainerColor,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Your Favourites',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // --- FAVORITES LIST ---
            SizedBox(
              height: favoriteCards.isEmpty ? 0 : 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: favoriteCards.length,
                itemBuilder: (context, index) {
                  final item = favoriteCards[index];
                  return Padding(
                    padding: index < favoriteCards.length - 1
                        ? const EdgeInsets.only(right: 16.0)
                        : EdgeInsets.zero,
                    child: FavouriteCard(
                      imagePath: item.imagePath,
                      title: item.title,
                      subtitle: item.subtitle,
                      onToggleFavorite: () => _toggleFavorite(item.id),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 2.0),

            // --- DIVIDER 2 ---
            Center(
              child: SizedBox(
                width: 360.0,
                child: Container(
                  height: 1.0,
                  color: dividerColor,
                ),
              ),
            ),

            // --- GRID VIEW (All turfs) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _allTurfs.length,
                  itemBuilder: (context, index) {
                    final item = _allTurfs[index];
                    final bool isFavorite = _favoriteTurfIds.contains(item.id);
                    return TurfCard(
                      imagePath: item.imagePath,
                      title: item.title,
                      subtitle: item.subtitle,
                      rating: item.rating,
                      isFavorite: isFavorite,
                      onToggleFavorite: () => _toggleFavorite(item.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FavouriteCard ---
class FavouriteCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double cardWidth;
  final double cardHeight;
  final double imageHeight;
  final VoidCallback? onToggleFavorite;

  const FavouriteCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.cardWidth = 150,
    this.cardHeight = 180,
    this.imageHeight = 110,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.red, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TurfCard ---
class TurfCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String rating;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const TurfCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.isFavorite,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 85,
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin:
                        const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0
                              ? Colors.white
                              : Colors.white54,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          rating,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star,
                            color: Colors.white, size: 10),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
