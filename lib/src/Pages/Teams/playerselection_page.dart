import 'package:flutter/material.dart';
import 'package:TURF_TOWN_/src/Scorecard/ScoreCard.dart';
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import '../../models/team_storage.dart';

class SelectPlayersPage extends StatefulWidget {
  final String battingTeamName;
  final String bowlingTeamName;

  const SelectPlayersPage({
    Key? key,
    required this.battingTeamName,
    required this.bowlingTeamName,
  }) : super(key: key);

  @override
  _SelectPlayersPageState createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;

  List<String> battingPlayers = [];
  List<String> bowlingPlayers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamPlayers();
  }

  Future<void> _loadTeamPlayers() async {
    setState(() => isLoading = true);
    
    final battingTeam = await TeamStorage.getTeamByName(widget.battingTeamName);
    final bowlingTeam = await TeamStorage.getTeamByName(widget.bowlingTeamName);
    
    if (mounted) {
      setState(() {
        battingPlayers = battingTeam?.players ?? [];
        bowlingPlayers = bowlingTeam?.players ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Appbg1.mainGradient),
        width: double.infinity,
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0E7292),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        // Top header section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Cricket",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Scorer",
                                      style: TextStyle(
                                        fontSize: 23,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.headphones,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 41),

                        // Card container
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2026),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back arrow + title
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: const Text(
                                      "Select Opening Players",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Team Names Display
                                    Text(
                                      "Batting: ${widget.battingTeamName}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Bowling: ${widget.bowlingTeamName}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Striker
                                    const Text(
                                      "Striker",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildDropdown(
                                      hint: "Select Striker",
                                      value: selectedStriker,
                                      items: battingPlayers,
                                      onChanged: (value) {
                                        setState(() => selectedStriker = value);
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Non-Striker
                                    const Text(
                                      "Non-Striker",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildDropdown(
                                      hint: "Select Non-Striker",
                                      value: selectedNonStriker,
                                      items: battingPlayers,
                                      onChanged: (value) {
                                        setState(() => selectedNonStriker = value);
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Bowler
                                    const Text(
                                      "Bowler",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildDropdown(
                                      hint: "Choose Bowler",
                                      value: selectedBowler,
                                      items: bowlingPlayers,
                                      onChanged: (value) {
                                        setState(() => selectedBowler = value);
                                      },
                                    ),

                                    const SizedBox(height: 57),

                                    // Proceed Button
                                    Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0E7292),
                                          minimumSize: const Size(50, 50),
                                          maximumSize: const Size(150, 50),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: () {
                                          // Validation
                                          if (selectedStriker == null ||
                                              selectedNonStriker == null ||
                                              selectedBowler == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Please select all players!"),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          if (selectedStriker == selectedNonStriker) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Striker and Non-Striker cannot be the same!"),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          // Proceed to scorecard
                                         // Proceed to scorecard
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Board(
                                          battingTeamName: widget.battingTeamName,
                                          bowlingTeamName: widget.bowlingTeamName,
                                          striker: selectedStriker!,
                                          nonStriker: selectedNonStriker!,
                                          bowler: selectedBowler!,
                                        ),
                                      ),
                                    );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: const Text(
                                                "Proceed",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      height: 44.23,
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 20,
          ),
          isExpanded: true,
          isDense: true,
          items: items.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    enabled: false,
                    child: Text(
                      'No players available',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ]
              : items
                  .map(
                    (player) => DropdownMenuItem<String>(
                      value: player,
                      child: Text(
                        player,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}