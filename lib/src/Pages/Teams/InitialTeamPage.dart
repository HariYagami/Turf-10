import 'package:TURF_TOWN_/src/Screens/advanced.settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:TURF_TOWN_/src/Pages/Teams/playerselection_page.dart';
import 'package:TURF_TOWN_/src/Pages/Teams/Team_Name.dart';
import '../../models/team_storage.dart';
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
  int _selectedIndex = 0;
  
  // Add PageController for horizontal scrolling
  late PageController _pageController;

  List<Team> teams = [];
  bool isLoadingTeams = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => isLoadingTeams = true);
    final loadedTeams = await TeamStorage.getTeams();
    if (mounted) {
      setState(() {
        teams = loadedTeams;
        isLoadingTeams = false;
      });
    }
  }

  Future<void> _onBottomNavTap(int index) async {
    if (index == 1) {
      // Navigate to Teams management page
      await Navigator.push(
        context,
        SmoothPageRoute(page: const TeamNameScreen()),
      );
      // Reload teams when returning from Teams page
      await _loadTeams();
      // Stay on Toss tab after returning
      setState(() => _selectedIndex = 0);
      _pageController.jumpToPage(0);
    } else {
      // Animate to the selected page
      setState(() => _selectedIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    oversController.dispose();
    _pageController.dispose();
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
                // Header stays fixed at top
                Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: _buildHeader(MediaQuery.of(context).size.width),
                ),
                // Page indicator
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: _buildPageIndicator(),
                ),
                // PageView for horizontal scrolling content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    children: [
                      // Toss Page (index 0)
                      _buildTossPage(),
                      // Teams placeholder page (index 1) - will navigate to TeamNameScreen
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Swipe left or tap Teams\nto manage your teams',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  SmoothPageRoute(page: const TeamNameScreen()),
                                );
                                await _loadTeams();
                                setState(() => _selectedIndex = 0);
                                _pageController.jumpToPage(0);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Manage Teams'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B7790),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _selectedIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _selectedIndex == index 
                ? const Color(0xFF00C4FF) 
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // Extract the toss page content into a separate widget
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
                  bottom: 100,
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

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF39375F).withOpacity(0.95),
            const Color(0xFF39375F).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.casino_outlined,
            activeIcon: Icons.casino,
            label: 'Toss',
            index: 0,
          ),
          const SizedBox(width: 60), // Space for FAB
          _buildNavItem(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: 'Teams',
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Elevated circular button when active
          if (isActive)
            Positioned(
              top: -35,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4E46A6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4E46A6).withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    activeIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          
          // Label and icon when inactive
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show icon only when inactive
                if (!isActive)
                  Icon(
                    icon,
                    color: const Color(0xFFB0B3C6),
                    size: 24,
                  ),
                if (!isActive) const SizedBox(height: 4),
                // Label text
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFFB0B3C6),
                    fontSize: isActive ? 13 : 11,
                    fontFamily: 'Poppins',
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                SmoothPageRoute(page: const TeamNameScreen()),
              );
              await _loadTeams();
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
          _buildTeamDropdownRow('Team 1', team1Name, w, (value) {
            setState(() => team1Name = value);
          }),
          SizedBox(height: w * 0.03),
          _buildTeamDropdownRow('Team 2', team2Name, w, (value) {
            setState(() => team2Name = value);
          }),
        ],
      ),
    );
  }

  Widget _buildTeamDropdownRow(String label, String? selectedTeam, double w, Function(String?) onChanged) {
    // Determine which teams are available based on the label
    List<Team> availableTeams = teams;
    
    // If this is Team 2 dropdown and Team 1 is selected, exclude Team 1 from options
    if (label == 'Team 2' && team1Name != null) {
      availableTeams = teams.where((team) => team.name != team1Name).toList();
    }
    
    // If this is Team 1 dropdown and Team 2 is selected, exclude Team 2 from options
    if (label == 'Team 1' && team2Name != null) {
      availableTeams = teams.where((team) => team.name != team2Name).toList();
    }

    return Row(
      children: [
        SizedBox(
          width: w * 0.2,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5C5C5E),
                width: 1,
              ),
            ),
            child: availableTeams.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: w * 0.03),
                    child: Text(
                      teams.isEmpty ? 'No teams available' : 'No other teams available',
                      style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: availableTeams.any((team) => team.name == selectedTeam) ? selectedTeam : null,
                      hint: Text(
                        'Select Team',
                        style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2C2C2E),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: availableTeams.map((team) {
                        return DropdownMenuItem<String>(
                          value: team.name,
                          child: Text(
                            team.name,
                            style: _textStyle(w * 0.034, null, Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Clear the current selection if it's now invalid
                        if (label == 'Team 1' && value == team2Name) {
                          setState(() {
                            team2Name = null;
                            tossWinnerTeam = null;
                          });
                        } else if (label == 'Team 2' && value == team1Name) {
                          setState(() {
                            team1Name = null;
                            tossWinnerTeam = null;
                          });
                        }
                        
                        // Also reset toss winner if it becomes invalid
                        if (label == 'Team 1') {
                          if (tossWinnerTeam == team1Name && team1Name != value) {
                            setState(() => tossWinnerTeam = null);
                          }
                        } else if (label == 'Team 2') {
                          if (tossWinnerTeam == team2Name && team2Name != value) {
                            setState(() => tossWinnerTeam = null);
                          }
                        }
                        
                        onChanged(value);
                      },
                    ),
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
          _buildTossWinnerDropdownRow('Winner', tossWinnerTeam, w),
          SizedBox(height: w * 0.03),
          _buildTossDecisionDropdownRow('Decision', tossDecision, w),
        ],
      ),
    );
  }

  Widget _buildTossWinnerDropdownRow(String label, String? selectedTeam, double w) {
    // Get selected teams for toss dropdown
    List<String> selectedTeams = [];
    if (team1Name != null) selectedTeams.add(team1Name!);
    if (team2Name != null && team2Name != team1Name) selectedTeams.add(team2Name!);

    return Row(
      children: [
        SizedBox(
          width: w * 0.2,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5C5C5E),
                width: 1,
              ),
            ),
            child: selectedTeams.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: w * 0.03),
                    child: Text(
                      'Select teams first',
                      style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTeams.contains(tossWinnerTeam) ? tossWinnerTeam : null,
                      hint: Text(
                        'Select Team',
                        style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2C2C2E),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: selectedTeams.map((teamName) {
                        return DropdownMenuItem<String>(
                          value: teamName,
                          child: Text(
                            teamName,
                            style: _textStyle(w * 0.034, null, Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => tossWinnerTeam = value);
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTossDecisionDropdownRow(String label, String? selectedDecision, double w) {
    final decisions = ['Bat', 'Bowl'];

    return Row(
      children: [
        SizedBox(
          width: w * 0.2,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5C5C5E),
                width: 1,
              ),
            ),
            child: tossWinnerTeam == null
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: w * 0.03),
                    child: Text(
                      'Select toss winner first',
                      style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDecision,
                      hint: Text(
                        'Select Decision',
                        style: _textStyle(w * 0.034, null, Colors.white.withOpacity(0.5)),
                      ),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF2C2C2E),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: decisions.map((decision) {
                        return DropdownMenuItem<String>(
                          value: decision,
                          child: Text(
                            decision,
                            style: _textStyle(w * 0.034, null, Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => tossDecision = value);
                      },
                    ),
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
            // Validate all required fields
            if (oversController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter overs!'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            if (team1Name == null || team2Name == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both teams!'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            if (tossWinnerTeam == null || tossDecision == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please complete toss details!'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            // Determine batting and bowling teams based on toss
            String battingTeam;
            String bowlingTeam;
            
            if (tossDecision == 'Bat') {
              battingTeam = tossWinnerTeam!;
              bowlingTeam = (tossWinnerTeam == team1Name) ? team2Name! : team1Name!;
            } else {
              bowlingTeam = tossWinnerTeam!;
              battingTeam = (tossWinnerTeam == team1Name) ? team2Name! : team1Name!;
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Match setup complete!'),
                backgroundColor: Color(0xFF00C4FF),
              ),
            );
            
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => SelectPlayersPage(
                  battingTeamName: battingTeam,
                  bowlingTeamName: bowlingTeam,
                ),
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