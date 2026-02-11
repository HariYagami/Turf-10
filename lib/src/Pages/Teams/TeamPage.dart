import 'package:TURF_TOWN_/src/Pages/Teams/team_members_page.dart';
import 'package:flutter/material.dart';
import 'package:TURF_TOWN_/src/models/team.dart';
class SmoothPageRoute extends PageRouteBuilder {
  final Widget page;

  SmoothPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // For reverse animation (going back), slide from left to right
            final isReverse = animation.status == AnimationStatus.reverse;
            final begin = isReverse ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
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

class NewTeamsPage extends StatefulWidget {
  const NewTeamsPage({super.key});

  @override
  State<NewTeamsPage> createState() => _NewTeamsPageState();
}

class _NewTeamsPageState extends State<NewTeamsPage> {
  List<Team> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _showAllData() {
    final allTeams = Team.getAll();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: Text(
          'ObjectBox Data (${allTeams.length} teams)',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: allTeams.isEmpty
              ? const Text(
                  'No teams in database',
                  style: TextStyle(color: Colors.white70),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTeams.length,
                  itemBuilder: (context, index) {
                    final team = allTeams[index];
                    return Card(
                      color: const Color(0xFF2A2F3A),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.teamName,
                              style: const TextStyle(
                                color: Color(0xFF00C4FF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DB ID: ${team.id}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              'UUID: ${team.teamId}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              'Members: ${team.teamCount}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTeams() async {
    try {
      final loadedTeams = Team.getAll();
      if (mounted) {
        setState(() {
          teams = loadedTeams;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Error loading teams: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

 Future<void> _createNewTeam() async {
  final teamName = await _showTeamNameDialog();
  
  if (teamName == null || teamName.trim().isEmpty) {
    return;
  }

  final trimmedName = teamName.trim();
  
  // Capitalize first letter
  final capitalizedName = trimmedName.isEmpty 
      ? trimmedName 
      : trimmedName[0].toUpperCase() + trimmedName.substring(1);

  // Validate team name
  if (capitalizedName.length < 2) {
    _showSnackBar('Team name must be at least 2 characters', Colors.orange);
    return;
  }

  if (capitalizedName.length > 30) {
    _showSnackBar('Team name must be less than 30 characters', Colors.orange);
    return;
  }

  // Check if team already exists
  final existingTeam = Team.getByName(capitalizedName);
  if (existingTeam != null) {
    _showSnackBar('Team "$capitalizedName" already exists!', Colors.orange);
    return;
  }

  // Create team in ObjectBox
  try {
    final team = Team.create(capitalizedName);
    setState(() {
      teams.add(team);
    });
    _showSnackBar('Team "$capitalizedName" created successfully!', Colors.green);
  } catch (e) {
    _showSnackBar('Error creating team: $e', Colors.red);
  }
}
 Future<String?> _showTeamNameDialog() async {
  final controller = TextEditingController();
  
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Team',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Team Name',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontFamily: 'Poppins',
                  ),
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  counterText: '',
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
                    borderSide: const BorderSide(
                      color: Color(0xFF00C4FF),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: (_) {
                  Navigator.of(dialogContext).pop(controller.text);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(null),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(controller.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C4FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ), 
        ),
      );
    },
  );
}

  void _deleteTeam(Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text('Delete Team', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${team.teamName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              team.delete();
              setState(() {
                teams.removeWhere((t) => t.teamId == team.teamId);
              });
              Navigator.pop(context);
              _showSnackBar('Team "${team.teamName}" deleted', Colors.orange);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return GestureDetector(
    onHorizontalDragEnd: (details) {
      // Swipe right (velocity is positive) -> go back to Toss page
      if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
        Navigator.pop(context);
      }
    },
    child: Scaffold(
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
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C4FF),
                        ),
                      )
                    : teams.isEmpty
                        ? _buildEmptyState()
                        : _buildTeamsList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTeam,
        backgroundColor: const Color(0xFF00C4FF),
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
              isSelected: false,
              onTap: () {
                Navigator.pop(context);  // Goes back with smooth animation
              },
            ),
            _buildNavItem(
              icon: Icons.group,
              label: 'Teams',
              isSelected: true,  // Changed to true - you're on Teams page
              onTap: () {},  // Changed to empty - already on this page
            ),
          ],
        ),
      ),
    ),
  );
}

// Keep your _buildNavItem method as is - no changes needed
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Teams',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.storage, color: Colors.white, size: 26),
                onPressed: _showAllData,
              ),
              const SizedBox(width: 10),
              const Icon(Icons.support_agent, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Opacity(
                opacity: 0.90,
                child: const Icon(Icons.settings, color: Colors.white, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No teams yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create a team',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return _buildTeamCard(team);
      },
    );
  }

 Widget _buildTeamCard(Team team) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamMembersPage(team: team),
        ),
      ).then((_) => _loadTeams());
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00C4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C4FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.group,
                color: Color(0xFF00C4FF),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (team.teamCount > 0)
                    Text(
                      '${team.teamCount} players',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    )
                  else
                    Text(
                      'Tap to add players',
                      style: TextStyle(
                        color: const Color(0xFF00C4FF).withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              iconSize: 24,
              onPressed: () => _deleteTeam(team),
            ),
          ],
        ),
      ),
    ),
  );
}
}