import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'team_name_screen.dart';

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

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String? selectedTeam1;
  String? selectedTeam2;
  String? selectedTossWinner;
  String? selectedTossDecision;
  final TextEditingController oversController = TextEditingController();
  bool additionalSettings = false;

  // Store created teams
  List<Map<String, dynamic>> teams = [];
  final List<String> tossDecisions = ['Bat', 'Bowl'];

  int teamsCreated = 0;

  void _navigateToAddTeam() async {
    if (teamsCreated >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 2 teams can be added for a match!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate and wait for result
   final result = await Navigator.push(
  context,
  SmoothPageRoute(
    page: TeamNameScreen(
      teamNumber: teamsCreated + 1,
      onTeamCreated: (teamData) {
        // This callback is called before popping
        print('Team created: ${teamData['team_name']}');
      },
    ),
  ),
);

    // Handle the result after navigation returns
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        teams.add(result);
        teamsCreated++;
        
        // Auto-assign teams when created
        if (teamsCreated == 1) {
          selectedTeam1 = result['team_name'];
        } else if (teamsCreated == 2) {
          selectedTeam2 = result['team_name'];
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Team "${result['team_name']}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    oversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: h),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(w),
                          SizedBox(height: h * 0.035),
                          _buildAddTeamsButton(w),
                          SizedBox(height: h * 0.035),
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Cricket ', style: _textStyle(w * 0.1)),
              TextSpan(text: 'Scorer', style: _textStyle(w * 0.05)),
            ],
          ),
        ),
        Row(
          children: [
            Icon(Icons.support_agent, color: Colors.white, size: w * 0.065),
            SizedBox(width: w * 0.025),
            Opacity(
              opacity: 0.90,
              child: Icon(Icons.settings, color: Colors.white, size: w * 0.065),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddTeamsButton(double w) {
    return InkWell(
      onTap: _navigateToAddTeam,
      borderRadius: BorderRadius.circular(10),
      splashColor: const Color(0xFF00C4FF).withOpacity(0.3),
      highlightColor: const Color(0xFF00C4FF).withOpacity(0.1),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2026),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: w * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Add Teams', style: _textStyle(w * 0.04)),
              SizedBox(width: w * 0.025),
              Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: w * 0.065,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsSection(double w) {
    bool teamsAvailable = teams.isNotEmpty;

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
          _buildDropdownField(
            'Team 1',
            selectedTeam1,
            (value) {
              setState(() {
                selectedTeam1 = value;
                // Reset toss winner if it was the changed team
                if (selectedTossWinner == value) {
                  selectedTossWinner = null;
                }
              });
            },
            w,
            enabled: teamsAvailable,
          ),
          SizedBox(height: w * 0.04),
          _buildDropdownField(
            'Team 2',
            selectedTeam2,
            (value) {
              setState(() {
                selectedTeam2 = value;
                // Reset toss winner if it was the changed team
                if (selectedTossWinner == value) {
                  selectedTossWinner = null;
                }
              });
            },
            w,
            enabled: teamsAvailable,
          ),
        ],
      ),
    );
  }

  Widget _buildTossDetailsSection(double w) {
    // Get available teams for toss (only selected teams)
    List<String> availableTossTeams = [];
    if (selectedTeam1 != null) availableTossTeams.add(selectedTeam1!);
    if (selectedTeam2 != null) availableTossTeams.add(selectedTeam2!);

    bool tossEnabled = availableTossTeams.length == 2;

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
          _buildLabeledDropdown(
            'Add',
            'Choose team',
            selectedTossWinner,
            (value) {
              setState(() => selectedTossWinner = value);
            },
            w,
            enabled: tossEnabled,
            items: availableTossTeams,
          ),
          SizedBox(height: w * 0.04),
          _buildLabeledDropdown(
            'Choose to',
            'Choose team',
            selectedTossDecision,
            (value) {
              setState(() => selectedTossDecision = value);
            },
            w,
            isTossDecision: true,
            enabled: tossEnabled,
          ),
        ],
      ),
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
            // Navigate to additional settings
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
            if (selectedTeam1 == null || selectedTeam2 == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both teams!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (oversController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter overs!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Match started: $selectedTeam1 vs $selectedTeam2'),
                  backgroundColor: const Color(0xFF00C4FF),
                ),
              );
              // Navigate to player selection or match screen
            }
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
                Icon(Icons.sports_cricket, color: Colors.white, size: w * 0.062),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    Function(String?) onChanged,
    double w, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () => _showTeamPicker(label, value, onChanged)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please add teams first!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.03),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFD9D9D9) : const Color(0xFF808080),
          border: Border.all(color: const Color(0xFFD1D1D1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: _textStyle(
                w * 0.034,
                null,
                value == null
                    ? (enabled ? const Color(0xFF9E9E9E) : const Color(0xFF6E6E6E))
                    : Colors.black,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_circle_outlined,
              color: enabled ? Colors.black54 : Colors.black26,
              size: w * 0.062,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledDropdown(
    String label,
    String placeholder,
    String? value,
    Function(String?) onChanged,
    double w, {
    bool isTossDecision = false,
    bool enabled = true,
    List<String>? items,
  }) {
    return Row(
      children: [
        SizedBox(
          width: w * 0.26,
          child: Text(label, style: _textStyle(w * 0.034)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: enabled
                ? () {
                    if (isTossDecision) {
                      _showTossDecisionPicker(value, onChanged);
                    } else {
                      _showTossWinnerPicker(value, onChanged, items ?? []);
                    }
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both teams first!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.025),
              decoration: BoxDecoration(
                color: enabled ? const Color(0xFFD9D9D9) : const Color(0xFF808080),
                border: Border.all(color: const Color(0xFFD1D1D1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? placeholder,
                    style: _textStyle(
                      w * 0.034,
                      null,
                      value == null
                          ? (enabled ? const Color(0xFF9E9E9E) : const Color(0xFF6E6E6E))
                          : Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: enabled ? Colors.black54 : Colors.black26,
                    size: w * 0.052,
                  ),
                ],
              ),
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

  void _showTeamPicker(
    String label,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select $label',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            ...teams.map((team) {
              final teamName = team['team_name'];
              // Prevent selecting the same team for both Team 1 and Team 2
              final isDisabled = (label == 'Team 1' && teamName == selectedTeam2) ||
                  (label == 'Team 2' && teamName == selectedTeam1);

              return ListTile(
                title: Text(
                  teamName,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                ),
                trailing: currentValue == teamName
                    ? const Icon(Icons.check, color: Color(0xFF00C4FF))
                    : null,
                enabled: !isDisabled,
                onTap: isDisabled
                    ? null
                    : () {
                        onChanged(teamName);
                        Navigator.pop(context);
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showTossWinnerPicker(
    String? currentValue,
    Function(String?) onChanged,
    List<String> availableTeams,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Toss Winner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            ...availableTeams.map((team) => ListTile(
              title: Text(team, style: const TextStyle(color: Colors.black)),
              trailing: currentValue == team
                  ? const Icon(Icons.check, color: Color(0xFF00C4FF))
                  : null,
              onTap: () {
                onChanged(team);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showTossDecisionPicker(String? currentValue, Function(String?) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Decision',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            ...tossDecisions.map((decision) => ListTile(
              title: Text(decision, style: const TextStyle(color: Colors.black)),
              trailing: currentValue == decision
                  ? const Icon(Icons.check, color: Color(0xFF00C4FF))
                  : null,
              onTap: () {
                onChanged(decision);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
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