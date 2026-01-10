import 'package:TURF_TOWN_/src/Pages/Teams/TeamPage.dart';
import 'package:TURF_TOWN_/src/Screens/advanced.settings_screen.dart';
import 'package:TURF_TOWN_/src/Pages/Teams/TeamPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:TURF_TOWN_/src/views/Home.dart';

class SmoothPageRoute extends PageRouteBuilder {
  final Widget page;

  SmoothPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

void main() => runApp(const FigmaToCodeApp());

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A237E),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const TeamPage(),
    );
  }
}

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController oversController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool additionalSettings = false;
  String? team1Name;
  String? team2Name;
  String? tossWinnerTeam;
  String? tossDecision;

  @override
  void dispose() {
    oversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        drawer: _buildDrawer(),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF283593), Color(0xFF1A237E), Color(0xFF000000)],
              stops: [0.0, 0.0, 0.2],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: _buildHeader(MediaQuery.of(context).size.width),
                ),
                Expanded(
                  child: _buildTossPage(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildTossPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: h),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.only(
                  left: w * 0.04,
                  right: w * 0.04,
                  top: w * 0.02,
                  bottom: w * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamsSection(w),
                    SizedBox(height: h * 0.025),
                    _buildTossDetailsSection(w),
                    SizedBox(height: h * 0.025),
                    _buildOversSection(w),
                    SizedBox(height: h * 0.04),
                    _buildBottomRow(w),
                    SizedBox(height: h * 0.025),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1C2026),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF283593), Color(0xFF1A237E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cricket Scorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.white),
            title: const Text('Teams', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewTeamsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Additional Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MatchSettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.scoreboard, color: Colors.white),
            title: const Text('Scorecard', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scorecard feature coming soon!'),
                  backgroundColor: Color(0xFF00C4FF),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.sports_cricket,
                label: 'Toss',
                isSelected: true,
                onTap: () {
                  // Already on this page
                },
              ),
              _buildNavItem(
                icon: Icons.group,
                label: 'Teams',
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewTeamsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00C4FF).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00C4FF) : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00C4FF) : Colors.white70,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double w) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Icon(
            Icons.menu,
            color: Colors.white,
            size: w * 0.07,
          ),
        ),
        Expanded(
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Cricket ', style: _textStyle(w * 0.1)),
                  TextSpan(text: 'Scorer', style: _textStyle(w * 0.05)),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            _buildSvgIcon('assets/ix_support.svg', w * 0.065),
            SizedBox(width: w * 0.025),
            Opacity(
              opacity: 0.90,
              child: _buildSvgIcon('assets/Group.svg', w * 0.065),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamsSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Teams', style: _textStyle(w * 0.04)),
          SizedBox(height: w * 0.04),
          _buildTeamInputRow('Team 1', team1Name, w, (value) {
            setState(() => team1Name = value);
          }),
          SizedBox(height: w * 0.03),
          _buildTeamInputRow('Team 2', team2Name, w, (value) {
            setState(() => team2Name = value);
          }),
        ],
      ),
    );
  }

  Widget _buildTeamInputRow(String label, String? selectedTeam, double w, Function(String?) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: w * 0.2,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5C5C5E),
                width: 1,
              ),
            ),
            child: Text(
              'Select Team',
              style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTossDetailsSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Toss Details', style: _textStyle(w * 0.04)),
          SizedBox(height: w * 0.04),
          _buildTossInputRow('Winner', w),
          SizedBox(height: w * 0.03),
          _buildTossInputRow('Decision', w),
        ],
      ),
    );
  }

  Widget _buildTossInputRow(String label, double w) {
    return Row(
      children: [
        SizedBox(
          width: w * 0.2,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5C5C5E),
                width: 1,
              ),
            ),
            child: Text(
              'Select $label',
              style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOversSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildLabeledTextField('Overs', 'Enter the overs', w),
    );
  }

  Widget _buildBottomRow(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => additionalSettings = !additionalSettings);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MatchSettingsPage()));
          },
          child: Row(
            children: [
              Text('Additional\nSettings', style: _textStyle(w * 0.04)),
              SizedBox(width: w * 0.025),
              Switch(
                value: additionalSettings,
                onChanged: (value) {
                  setState(() => additionalSettings = value);
                },
                activeColor: const Color(0xFF00C4FF),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please complete all fields!'),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4FF),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Match', style: _textStyle(w * 0.04)),
                SizedBox(width: w * 0.02),
                _buildSvgIcon('assets/mdi_cricket.svg', w * 0.062),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledTextField(String label, String placeholder, double w) {
    return Row(
      children: [
        SizedBox(
          width: w * 0.26,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: TextField(
            controller: oversController,
            keyboardType: TextInputType.number,
            style: _textStyle(w * 0.034, null, Colors.black),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: _textStyle(w * 0.034, null, const Color(0xFF9E9E9E)),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00C4FF), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.025),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSvgIcon(String path, double size, {bool colored = true}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: colored ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
    );
  }

  TextStyle _textStyle(double size, [FontWeight? weight, Color? color]) {
    return TextStyle(
      color: color ?? Colors.white,
      fontSize: size,
      fontFamily: 'Poppins',
      fontWeight: weight ?? FontWeight.w400,
    );
  }
}