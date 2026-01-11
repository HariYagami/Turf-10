import 'package:flutter/material.dart';
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import 'package:TURF_TOWN_/src/models/match_storage.dart';
import 'package:TURF_TOWN_/src/models/team.dart';
import 'package:TURF_TOWN_/src/models/team_member.dart';
import 'package:TURF_TOWN_/src/models/player_storage.dart';

class SelectPlayersPage extends StatefulWidget {
  final String battingTeamName;
  final String bowlingTeamName;
  final int totalOvers;

  const SelectPlayersPage({
    super.key,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.totalOvers,
  });

  @override
  State<SelectPlayersPage> createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;
  
  // Store player data
  List<TeamMember> battingPlayers = [];
  List<TeamMember> bowlingPlayers = [];
  
  // Store team IDs
  String? battingTeamId;
  String? bowlingTeamId;
  
  // Store current match
  String? currentMatchId;
  
  bool isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _loadMatchAndPlayers();
  }

  Future<void> _loadMatchAndPlayers() async {
    try {
      // Get the most recent match (the one just created)
      final allMatches = MatchStorage.getAllMatches();
      if (allMatches.isEmpty) {
        _showSnackBar('No match found', Colors.red);
        setState(() => isLoadingPlayers = false);
        return;
      }
      
      // Sort by matchId descending to get the latest match
      allMatches.sort((a, b) => b.matchId.compareTo(a.matchId));
      final currentMatch = allMatches.first;
      currentMatchId = currentMatch.matchId;
      
      // Get batting and bowling team IDs from the match
      battingTeamId = currentMatch.getBattingTeamId();
      bowlingTeamId = currentMatch.getBowlingTeamId();
      
      // Load players for both teams
      if (battingTeamId != null) {
        battingPlayers = PlayerStorage.getPlayersByTeam(battingTeamId!);
      }
      
      if (bowlingTeamId != null) {
        bowlingPlayers = PlayerStorage.getPlayersByTeam(bowlingTeamId!);
      }
      
      // Validate that teams have players
      if (battingPlayers.isEmpty) {
        _showSnackBar('Batting team has no players!', Colors.orange);
      }
      
      if (bowlingPlayers.isEmpty) {
        _showSnackBar('Bowling team has no players!', Colors.orange);
      }
      
      setState(() => isLoadingPlayers = false);
      
    } catch (e) {
      _showSnackBar('Error loading players: $e', Colors.red);
      setState(() => isLoadingPlayers = false);
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

  void _showPlayerSelectionDialog(String playerType) {
    List<TeamMember> availablePlayers;
    String? currentSelection;
    
    switch (playerType) {
      case 'Striker':
      case 'Non-Striker':
        availablePlayers = battingPlayers;
        currentSelection = playerType == 'Striker' ? selectedStriker : selectedNonStriker;
        break;
      case 'Bowler':
        availablePlayers = bowlingPlayers;
        currentSelection = selectedBowler;
        break;
      default:
        return;
    }
    
    if (availablePlayers.isEmpty) {
      _showSnackBar('No players available for selection', Colors.red);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: Text(
          'Select $playerType',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availablePlayers.length,
            itemBuilder: (context, index) {
              final player = availablePlayers[index];
              final isSelected = player.playerId == currentSelection;
              
              // Disable if already selected in another role
              bool isDisabled = false;
              String disabledReason = '';
              
              if (playerType == 'Striker' && player.playerId == selectedNonStriker) {
                isDisabled = true;
                disabledReason = 'Selected as Non-Striker';
              } else if (playerType == 'Non-Striker' && player.playerId == selectedStriker) {
                isDisabled = true;
                disabledReason = 'Selected as Striker';
              }
              
              return Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: ListTile(
                  enabled: !isDisabled,
                  title: Text(
                    player.teamName,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF00C4FF) : Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: isDisabled
                      ? Text(
                          disabledReason,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                        )
                      : Text(
                          'ID: ${player.playerId}',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                  leading: Icon(
                    Icons.person,
                    color: isSelected ? const Color(0xFF00C4FF) : Colors.white70,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF00C4FF))
                      : null,
                  onTap: isDisabled ? null : () {
                    setState(() {
                      switch (playerType) {
                        case 'Striker':
                          selectedStriker = player.playerId;
                          break;
                        case 'Non-Striker':
                          selectedNonStriker = player.playerId;
                          break;
                        case 'Bowler':
                          selectedBowler = player.playerId;
                          break;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF00C4FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToMatch() {
    // Validate all selections
    if (selectedStriker == null || selectedNonStriker == null || selectedBowler == null) {
      _showSnackBar('Please select all players!', Colors.red);
      return;
    }
    
    if (selectedStriker == selectedNonStriker) {
      _showSnackBar('Striker and Non-Striker cannot be the same!', Colors.red);
      return;
    }
    
    // Get player names for confirmation
    final striker = TeamMember.getByPlayerId(selectedStriker!);
    final nonStriker = TeamMember.getByPlayerId(selectedNonStriker!);
    final bowler = TeamMember.getByPlayerId(selectedBowler!);
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text(
          'Confirm Players',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match ID: $currentMatchId',
              style: const TextStyle(color: Color(0xFF00C4FF), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Striker: ${striker?.teamName ?? "Unknown"}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Non-Striker: ${nonStriker?.teamName ?? "Unknown"}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Bowler: ${bowler?.teamName ?? "Unknown"}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C4FF),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to scoring page with selected players
              _showSnackBar('Starting match...', Colors.green);
              // Here you would navigate to the actual match scoring page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ScoringPage(...)));
            },
            child: const Text('Start', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMatchDataDialog() {
    final allMatches = MatchStorage.getAllMatches();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text(
          'Match Data Debug View', 
          style: TextStyle(color: Colors.white, fontSize: 18)
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: allMatches.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No matches created yet.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allMatches.length,
                  itemBuilder: (context, index) {
                    final match = allMatches[index];
                    final team1 = Team.getById(match.teamId1);
                    final team2 = Team.getById(match.teamId2);
                    final tossWinner = Team.getById(match.tossWonBy);
                    final battingTeam = Team.getById(match.getBattingTeamId());
                    final bowlingTeam = Team.getById(match.getBowlingTeamId());
                    
                    return Card(
                      color: const Color(0xFF2C2C2E),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match ID: ${match.matchId}',
                              style: const TextStyle(
                                color: Color(0xFF00C4FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 16),
                            
                            // Teams Section
                            const Text(
                              'TEAMS:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${team1?.teamName ?? match.teamId1} vs ${team2?.teamName ?? match.teamId2}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Match Settings
                            const Text(
                              'MATCH SETTINGS:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Overs: ${match.overs}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            
                            // Toss Details
                            const Text(
                              'TOSS DETAILS:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Winner: ${tossWinner?.teamName ?? match.tossWonBy}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              'Decision: ${match.isBattingFirst ? "Bat First" : "Bowl First"}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            
                            // Current Match Status
                            const Text(
                              'CURRENT STATUS:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batting: ${battingTeam?.teamName ?? match.getBattingTeamId()}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Bowling: ${bowlingTeam?.teamName ?? match.getBowlingTeamId()}',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Match Rules
                            const Text(
                              'MATCH RULES:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  match.isNoballAllowed ? Icons.check_circle : Icons.cancel,
                                  color: match.isNoballAllowed ? Colors.green : Colors.red,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'No-ball: ${match.isNoballAllowed ? "Allowed" : "Not Allowed"}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  match.isWideAllowed ? Icons.check_circle : Icons.cancel,
                                  color: match.isWideAllowed ? Colors.green : Colors.red,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Wide: ${match.isWideAllowed ? "Allowed" : "Not Allowed"}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Database Info
                            const Text(
                              'DATABASE INFO:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DB ID: ${match.id}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              'Team 1 ID: ${match.teamId1}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            Text(
                              'Team 2 ID: ${match.teamId2}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
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
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00C4FF)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Appbg1.mainGradient),
        width: double.infinity,
        child: SafeArea(
          child: isLoadingPlayers
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00C4FF),
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
                                children: [
                                  // Debug button for viewing match data
                                  GestureDetector(
                                    onTap: _showMatchDataDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.bug_report,
                                        color: Color(0xFF00C4FF),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.headphones,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
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
                                    const SizedBox(height: 5),
                                    Text(
                                      "Players: ${battingPlayers.length} batters, ${bowlingPlayers.length} bowlers",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white54,
                                        fontStyle: FontStyle.italic,
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
                                    _buildPlayerSelector(
                                      "Select Striker",
                                      selectedStriker,
                                      'Striker',
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
                                    _buildPlayerSelector(
                                      "Select Non-Striker",
                                      selectedNonStriker,
                                      'Non-Striker',
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
                                    _buildPlayerSelector(
                                      "Choose Bowler",
                                      selectedBowler,
                                      'Bowler',
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
                                        onPressed: _proceedToMatch,
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

  Widget _buildPlayerSelector(String hint, String? selectedPlayerId, String playerType) {
    final selectedPlayer = selectedPlayerId != null 
        ? TeamMember.getByPlayerId(selectedPlayerId)
        : null;
    
    return GestureDetector(
      onTap: () => _showPlayerSelectionDialog(playerType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        height: 44.23,
        decoration: BoxDecoration(
          color: Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedPlayer != null ? selectedPlayer.teamName : hint,
                style: TextStyle(
                  color: selectedPlayer != null ? Colors.black : Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: selectedPlayer != null ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}