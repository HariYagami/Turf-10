import 'dart:convert';
import 'dart:async'; // Add this import
import 'package:TURF_TOWN_/src/services/environment_service.dart'; // Add this
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import 'package:TURF_TOWN_/src/Pages/Teams/match_graph_page.dart';
import 'package:TURF_TOWN_/src/Pages/Teams/scoreboard_page.dart';
import 'package:TURF_TOWN_/src/models/batsman.dart';
import 'package:TURF_TOWN_/src/models/bowler.dart';

import 'package:TURF_TOWN_/src/models/innings.dart';
import 'package:TURF_TOWN_/src/models/match_history.dart';
import 'package:TURF_TOWN_/src/models/score.dart';
import 'package:TURF_TOWN_/src/models/team_member.dart';
import 'package:TURF_TOWN_/src/models/match.dart';
import 'package:TURF_TOWN_/src/models/team.dart';
import 'package:TURF_TOWN_/src/services/bluetooth_service.dart';
import 'package:TURF_TOWN_/src/views/Home.dart';
import 'package:flutter/material.dart';
import 'package:TURF_TOWN_/src/Pages/Teams/InitialTeamPage.dart' hide Appbg1;
import 'package:TURF_TOWN_/src/widgets/cricket_animations.dart';


class CricketScorerScreen extends StatefulWidget {
  final String matchId;
  final String inningsId;
  final String strikeBatsmanId;
  final String nonStrikeBatsmanId;
  final String bowlerId;

  const CricketScorerScreen({
    Key? key,
    required this.matchId,
    required this.inningsId,
    required this.strikeBatsmanId,
    required this.nonStrikeBatsmanId,
    required this.bowlerId,
  }) : super(key: key);

  @override
  State<CricketScorerScreen> createState() => _CricketScorerScreenState();
}

class _CricketScorerScreenState extends State<CricketScorerScreen> {
  late Match? currentMatch;
  late Innings? currentInnings;
  late Score? currentScore;
  late Batsman? strikeBatsman;
  late Batsman? nonStrikeBatsman;
  late Bowler? currentBowler;

  bool isInitializing = true;
  bool showExtrasOptions = false;
  bool isNoBall = false;
  bool isWide = false;
  bool isByes = false;

  bool noBallEnabled = true;
  bool wideEnabled = true;

  int runsInCurrentOver = 0;
  bool isRunout = false;
  int? pendingRunoutRuns;
  String? runoutBatsmanId;

  // Match completion flag - freeze buttons when match is complete
  bool isMatchComplete = false;

  // ScrollController for focusing scorecard during runout
  late ScrollController _scrollController;

  // Lottie animation flags
  bool _showBoundaryAnimation = false;
  String? _boundaryAnimationType; // '4' or '6'
  bool _showWicketAnimation = false;
  bool _showDuckAnimation = false;
  String? _lastDuckBatsman;
  bool _showRunoutHighlight = false;
  int _runoutHighlightIndex = 0;
  bool _showVictoryAnimation = false;

  // Runout mode blur and highlight - light blur (0.3) with teal tint
  bool _isRunoutModeActive = false;

  Timer? _ledUpdateTimer;
final _envService = EnvironmentService();

List<Map<String, dynamic>> actionHistory = [];
  String? lastOverBowlerId; 

@override
void initState() {
  super.initState();
  _scrollController = ScrollController();
  _initializeMatch();
  
  // 🔥 Initialize environment service for temperature
  print('🚀 CricketScorerScreen: Initializing EnvironmentService...');
  _envService.initialize();
  
  // 🧪 Test API immediately (remove this after confirming it works)
  Future.delayed(const Duration(seconds: 1), () {
    _envService.testWeatherAPI();
  });
  
  // 🔥 Update LED time & temperature every 60 seconds
  _ledUpdateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
    print('⏰ CricketScorerScreen: Periodic LED update triggered');
    _updateLEDTimeAndTemp();
  });
  
  // Initial LED update after 3 seconds (give time for weather to load)
  Future.delayed(const Duration(seconds: 3), () {
    print('🎬 CricketScorerScreen: Initial LED update');
    _updateLEDTimeAndTemp();
  });
}
 @override
void dispose() {
  _scrollController.dispose();
  _ledUpdateTimer?.cancel(); // 🔥 Cancel timer
  super.dispose();
} 

  Future<void> _initializeMatch() async {
    try {
      currentMatch = Match.getByMatchId(widget.matchId);
      if (currentMatch == null) throw Exception('Match not found');
      
      noBallEnabled = currentMatch!.isNoballAllowed;
      wideEnabled = currentMatch!.isWideAllowed;

      currentInnings = Innings.getByInningsId(widget.inningsId);
      if (currentInnings == null) throw Exception('Innings not found');

      currentScore = Score.getByInningsId(widget.inningsId);
      if (currentScore == null) {
        currentScore = Score.create(widget.inningsId);
      }

      strikeBatsman = Batsman.getByBatId(widget.strikeBatsmanId);
      nonStrikeBatsman = Batsman.getByBatId(widget.nonStrikeBatsmanId);
      currentBowler = Bowler.getByBowlerId(widget.bowlerId);

      if (currentScore != null) {
        currentScore!.strikeBatsmanId = widget.strikeBatsmanId;
        currentScore!.nonStrikeBatsmanId = widget.nonStrikeBatsmanId;
        currentScore!.currentBowlerId = widget.bowlerId;
        currentScore!.save();
      }

      setState(() => isInitializing = false);
    } catch (e) {
      print('Error initializing match: $e');
      _showErrorDialog('Failed to load match: $e');
    }
  }

  String _getBattingTeamName() {
    if (currentInnings == null) return 'Unknown';
    final team = Team.getById(currentInnings!.battingTeamId);
    return team?.teamName ?? 'Unknown';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F24),
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Color(0xFF9AA0A6))),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF6D7CFF))),
          ),
        ],
      ),
    );
  }

  bool _checkSecondInningsVictory() {
    if (currentInnings == null || !currentInnings!.isSecondInnings) return false;

    if (currentInnings!.hasValidTarget && currentScore != null) {
      try {
        if (currentInnings!.hasMetTarget(currentScore!.totalRuns)) {
          final firstInnings = Innings.getFirstInnings(widget.matchId);
          if (firstInnings != null) {
            final firstInningsScore = Score.getByInningsId(firstInnings.inningsId);
            if (firstInningsScore != null) {
              _showVictoryDialog(true, firstInningsScore);
              return true;
            }
          }
        }
      } catch (e) {
        print('Error checking victory: $e');
      }
    }
    return false;
  }

 void _showVictoryDialog(bool battingTeamWon, Score firstInningsScore) {
  currentInnings?.markCompleted();

  // Mark match as complete - freeze all buttons
  setState(() {
    isMatchComplete = true;
  });

  // Trigger victory animation
  _triggerVictoryAnimation();

  // Save to match history
  _saveMatchToHistory(battingTeamWon, firstInningsScore);

  // 🔥 CLEAR LED DISPLAY IMMEDIATELY
  _clearLEDDisplay();

  // Auto-redirect to history page after 5 seconds (animation duration 2 seconds + 3 seconds wait)
  Future.delayed(const Duration(seconds: 5), () {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    }
  });
}
// Save incomplete match to history as paused
Future<void> _clearLEDDisplay() async {
  try {
    final bleService = BleManagerService();
    
    if (!bleService.isConnected) {
      debugPrint('⚠️ Bluetooth not connected. Skipping LED clear.');
      return;
    }
    
    debugPrint('🧹 Clearing LED display...');
    
    // Fill entire display with black (clear screen)
    final commands = [
      'FILL 0 0 127 127 0 0 0',  // Clear entire 128x128 display
    ];
    
    await bleService.sendRawCommands(commands);
    
    debugPrint('✅ LED display cleared');
    
  } catch (e) {
    debugPrint('❌ LED clear failed: $e');
  }
}
void _saveMatchState() {
  try {
    if (currentMatch == null || currentInnings == null || currentScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Match data not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get all innings data
    final firstInnings = Innings.getFirstInnings(widget.matchId);
    final secondInnings = Innings.getSecondInnings(widget.matchId);
    final firstScore = firstInnings != null ? Score.getByInningsId(firstInnings.inningsId) : null;
    final secondScore = secondInnings != null ? Score.getByInningsId(secondInnings.inningsId) : null;

    // Serialize match state to JSON
    final matchStateJson = jsonEncode({
      'matchId': widget.matchId,
      'inningsId': widget.inningsId,
      'strikeBatsmanId': widget.strikeBatsmanId,
      'nonStrikeBatsmanId': widget.nonStrikeBatsmanId,
      'bowlerId': widget.bowlerId,
      // First innings data
      'firstInningsId': firstInnings?.inningsId,
      'firstInningsTeamId': firstInnings?.battingTeamId,
      'firstInningsRuns': firstScore?.totalRuns ?? 0,
      'firstInningsWickets': firstScore?.wickets ?? 0,
      'firstInningsOvers': firstScore?.overs ?? 0.0,
      'firstInningsExtras': firstScore?.totalExtras ?? 0,
      // Second innings data
      'secondInningsId': secondInnings?.inningsId,
      'secondInningsTeamId': secondInnings?.battingTeamId,
      'secondInningsRuns': secondScore?.totalRuns ?? 0,
      'secondInningsWickets': secondScore?.wickets ?? 0,
      'secondInningsOvers': secondScore?.overs ?? 0.0,
      'secondInningsExtras': secondScore?.totalExtras ?? 0,
      'secondInningsTarget': secondInnings?.targetRuns ?? 0,
      // Current match state
      'isCompleted': false,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Save to match history as paused match
    final existingHistory = MatchHistory.getByMatchId(widget.matchId);

    if (existingHistory != null) {
      // Update existing paused match
      existingHistory.isPaused = true;
      existingHistory.pausedState = matchStateJson;
      existingHistory.result = 'Match Paused';
      existingHistory.isCompleted = false;
      existingHistory.save();
    } else {
      // Create new paused match history
      MatchHistory.create(
        matchId: widget.matchId,
        teamAId: currentMatch!.teamId1,
        teamBId: currentMatch!.teamId2,
        matchDate: DateTime.now(),
        matchType: 'CRICKET',
        team1Runs: firstScore?.totalRuns ?? 0,
        team1Wickets: firstScore?.wickets ?? 0,
        team1Overs: firstScore?.overs ?? 0.0,
        team2Runs: secondScore?.totalRuns ?? 0,
        team2Wickets: secondScore?.wickets ?? 0,
        team2Overs: secondScore?.overs ?? 0.0,
        result: 'Match Paused',
        isCompleted: false,
        isPaused: true,
        pausedState: matchStateJson,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Match saved! You can resume it later.'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back after saving
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TeamPage()),
          (route) => false,
        );
      }
    });
  } catch (e) {
    print('Error saving match state: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving match: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void _saveMatchToHistory(bool battingTeamWon, Score firstInningsScore) {
  if (currentMatch == null || currentInnings == null || currentScore == null) return;
  
  final firstInnings = Innings.getFirstInnings(widget.matchId);
  if (firstInnings == null) return;
  
  String result;
  if (battingTeamWon) {
    final teamMembers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
    final totalTeamMembers = teamMembers.length;
    int wicketsRemaining = (totalTeamMembers - 1) - currentScore!.wickets;
    final winningTeam = Team.getById(currentInnings!.battingTeamId);
    result = '${winningTeam?.teamName ?? "Team"} won by $wicketsRemaining wickets';
  } else {
    int runsDifference = currentInnings!.targetRuns - currentScore!.totalRuns - 1;
    final winningTeam = Team.getById(currentInnings!.bowlingTeamId);
    result = '${winningTeam?.teamName ?? "Team"} won by $runsDifference runs';
  }
  
  final matchHistory = MatchHistory(
    matchId: widget.matchId,
    teamAId: firstInnings.battingTeamId,
    teamBId: firstInnings.bowlingTeamId,
    matchDate: DateTime.now(),
    matchType: 'CRICKET',
    team1Runs: firstInningsScore.totalRuns,
    team1Wickets: firstInningsScore.wickets,
    team1Overs: firstInningsScore.overs,
    team2Runs: currentScore!.totalRuns,
    team2Wickets: currentScore!.wickets,
    team2Overs: currentScore!.overs,
    result: result,
    isCompleted: true,
  );
  
  matchHistory.save();
}
void _showMatchTiedDialog(Score firstInningsScore) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F24),
      title: const Text(
        '🤝 Match Tied!',
        style: TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The match ended in a tie!',
            style: TextStyle(
              color: Color(0xFF9AA0A6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0f0f1e),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF9800), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Final Scores',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team ${currentInnings!.bowlingTeamId}:',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '${firstInningsScore.totalRuns}/${firstInningsScore.wickets}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team ${currentInnings!.battingTeamId}:',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '${currentScore!.totalRuns}/${currentScore!.wickets}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
       // In _showMatchTiedDialog method, replace the TextButton's onPressed:
TextButton(
  onPressed: () {
    Navigator.of(context).pop(); // Close dialog
    // Navigate to Home and reset to home tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const Home(),
      ),
      (route) => false,
    );
  },
  child: const Text(
    'View History',
    style: TextStyle(color: Color(0xFF6D7CFF)),
  ),
),
      ],
    ),
  );
}


void _showLeaveMatchDialog() {
  // Dismiss blur overlay when back button is pressed
  setState(() {
    _isRunoutModeActive = false;
  });

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F24),
      title: const Text(
        'Leave Match?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: const Text(
        'What would you like to do?',
        style: TextStyle(
          color: Color(0xFF9AA0A6),
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: const Text(
            'Continue Match',
            style: TextStyle(color: Color(0xFF9AA0A6)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D7CFF),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            
            // 🔥 CLEAR LED DISPLAY BEFORE SAVING AND EXITING
            _clearLEDDisplay();
            
            // Give time for LED to clear before saving
            Future.delayed(const Duration(milliseconds: 500), () {
              _saveMatchState(); // This will save and navigate
            });
          },
          child: const Text(
            'Save & Exit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3B3B),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            
            // 🔥 CLEAR LED DISPLAY BEFORE EXITING
            _clearLEDDisplay();
            
            // Give time for LED to clear before navigating
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pop(); // Go back from current screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TeamPage()),
                (route) => false, // Remove all previous routes
              );
            });
          },
          child: const Text(
            'Discard & Exit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
void addRuns(int runs) {
  if (currentScore == null || strikeBatsman == null || currentBowler == null) return;

  // Handle runout mode
  if (isRunout) {
    addRunout(runs);
    return;
  }

  // Dismiss blur overlay when any score is pressed (non-runout mode)
  if (_isRunoutModeActive) {
    setState(() {
      _isRunoutModeActive = false;
    });
  }

  setState(() {
    actionHistory.add({
      'type': 'runs',
      'runs': runs,
      'strikeBatsmanId': strikeBatsman!.batId,
      'nonStrikeBatsmanId': nonStrikeBatsman!.batId,
      'batsmanRuns': strikeBatsman!.runs,
      'batsmanBalls': strikeBatsman!.ballsFaced,
      'batsmanFours': strikeBatsman!.fours,
      'batsmanSixes': strikeBatsman!.sixes,
      'batsmanDotBalls': strikeBatsman!.dotBalls,
      'batsmanExtras': strikeBatsman!.extras,
      'bowlerRuns': currentBowler!.runsConceded,
      'bowlerBalls': currentBowler!.balls,
      'bowlerWickets': currentBowler!.wickets,
      'bowlerMaidens': currentBowler!.maidens,
      'bowlerExtras': currentBowler!.extras,
      'totalRuns': currentScore!.totalRuns,
      'currentBall': currentScore!.currentBall,
      'overs': currentScore!.overs,
      'currentOver': List<String>.from(currentScore!.currentOver),
      'runsInCurrentOver': runsInCurrentOver,
      'isNoBall': isNoBall,
      'isWide': isWide,
      'isByes': isByes,
      'byes': currentScore!.byes,
      'wides': currentScore!.wides,
      'noBalls': currentScore!.noBalls,
    });

    int totalRunsToAdd = 0;
    int batsmanRuns = 0;
    int extrasRuns = 0;
    String ballDisplay = runs.toString();
    bool countBallForBatsman = true;
    bool countBallForBowler = true;
    
    if (isNoBall) {
      extrasRuns = 1;
      totalRunsToAdd = 1;
      countBallForBatsman = false;
      countBallForBowler = false;
      currentScore!.noBalls += 1;
      
      if (isByes) {
        totalRunsToAdd += runs;
        currentScore!.byes += runs;
        ballDisplay = 'NB+$runs';
        strikeBatsman!.extras += extrasRuns;
        strikeBatsman!.save();
      } else if (runs > 0) {
        totalRunsToAdd += runs;
        batsmanRuns = runs;
        ballDisplay = 'NB$runs';
        strikeBatsman!.updateStats(batsmanRuns, extrasRuns: extrasRuns, countBall: countBallForBatsman);
      } else {
        ballDisplay = 'NB';
        strikeBatsman!.extras += extrasRuns;
        strikeBatsman!.save();
      }
      
      runsInCurrentOver += totalRunsToAdd;
      
    } else if (isWide) {
      if (isByes) {
        totalRunsToAdd = 1 + runs;
        extrasRuns = totalRunsToAdd;
        currentScore!.wides += totalRunsToAdd;
        ballDisplay = runs > 0 ? 'WD+$runs' : 'WD';
      } else if (runs > 0) {
        totalRunsToAdd = 1 + runs;
        extrasRuns = totalRunsToAdd;
        currentScore!.wides += totalRunsToAdd;
        ballDisplay = 'WD$runs';
      } else {
        totalRunsToAdd = 1;
        extrasRuns = 1;
        currentScore!.wides += 1;
        ballDisplay = 'WD';
      }
      
      countBallForBatsman = false;
      countBallForBowler = false;
      
      strikeBatsman!.extras += extrasRuns;
      strikeBatsman!.save();
      
      runsInCurrentOver += totalRunsToAdd;
      
    } else if (isByes) {
      extrasRuns = runs;
      totalRunsToAdd = runs;
      ballDisplay = 'B$runs';
      currentScore!.byes += runs;
      
      strikeBatsman!.updateStats(0, extrasRuns: extrasRuns, countBall: true);
      
      runsInCurrentOver += runs;
      
    } else {
      totalRunsToAdd = runs;
      batsmanRuns = runs;
      
      strikeBatsman!.updateStats(batsmanRuns, extrasRuns: 0, countBall: true);
      
      runsInCurrentOver += runs;
    }

    currentBowler!.updateStats(
      totalRunsToAdd, 
      false, 
      extrasRuns: extrasRuns, 
      countBall: countBallForBowler
    );

    var tempOver = currentScore!.currentOver;
    tempOver.add(ballDisplay);
    currentScore!.currentOver = tempOver;

    if (countBallForBowler) _updateOverTracking();

    currentScore!.totalRuns += totalRunsToAdd;
    currentScore!.crr = currentScore!.overs > 0 ? (currentScore!.totalRuns / currentScore!.overs) : 0.0;
    currentScore!.save();

    // UPDATE LED DISPLAY - ADD THIS
    _updateLEDAfterScore();

    // Trigger boundary animations
    if (runs == 4) {
      _triggerBoundaryAnimation('4');
    } else if (runs == 6) {
      _triggerBoundaryAnimation('6');
    }

    if (currentInnings != null && currentInnings!.isSecondInnings) {
      if (_checkSecondInningsVictory()) return;
    }

   if (countBallForBowler && currentScore!.currentBall % 6 == 0) {
  if (runsInCurrentOver == 0) {
    currentBowler!.incrementMaiden();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Maiden Over! 🎯'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  runsInCurrentOver = 0;

  // SWAP FOR EVEN RUNS AT END OF OVER
  if (runs % 2 == 0) _switchStrike();
  
  if (_isInningsComplete()) {
    _endInnings();
    return;
  }

  _showChangeBowlerDialog();
  _resetCurrentOver();
  
  // 🔥 UPDATE LED AFTER OVER COMPLETION AND STRIKE SWAP
  _updateLEDAfterScore();
  
} else if (runs % 2 == 1 && !isByes && !isWide) {
  // SWAP FOR ODD RUNS DURING OVER
  _switchStrike();
  
  // 🔥 UPDATE LED IMMEDIATELY AFTER ODD RUN SWAP
  _updateLEDAfterScore();
}
    isNoBall = false;
    isWide = false;
    isByes = false;
    showExtrasOptions = false;
  });
}

  void addWicket() {
  if (currentScore == null || strikeBatsman == null || currentBowler == null) return;

  setState(() {
    actionHistory.add({
      'type': 'wicket',
      'strikeBatsmanId': strikeBatsman!.batId,
      'nonStrikeBatsmanId': nonStrikeBatsman!.batId,
      'batsmanIsOut': strikeBatsman!.isOut,
      'batsmanBowlerWhoGotWicket': strikeBatsman!.bowlerIdWhoGotWicket,
      'batsmanExtras': strikeBatsman!.extras,
      'bowlerWickets': currentBowler!.wickets,
      'bowlerBalls': currentBowler!.balls,
      'bowlerRuns': currentBowler!.runsConceded,
      'bowlerMaidens': currentBowler!.maidens,
      'bowlerExtras': currentBowler!.extras,
      'runsInCurrentOver': runsInCurrentOver,
      'wickets': currentScore!.wickets,
      'currentBall': currentScore!.currentBall,
      'currentOver': List<String>.from(currentScore!.currentOver),
    });

    strikeBatsman!.markAsOut(bowlerIdWhoGotWicket: currentBowler!.bowlerId);
    currentScore!.wickets++;
    currentBowler!.updateStats(0, true, extrasRuns: 0, countBall: true);

    // Trigger wicket animation
    _triggerWicketAnimation();

    // Check for duck (0 runs)
    if (strikeBatsman!.runs == 0) {
      _triggerDuckAnimation(strikeBatsman!.batId);
    }

    var tempOver = currentScore!.currentOver;
    tempOver.add('W');
    currentScore!.currentOver = tempOver;

    _updateOverTracking();

    if (currentInnings != null) {
      final teamMembers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
      final totalTeamMembers = teamMembers.length;
      
      if (currentScore!.wickets >= totalTeamMembers - 1) {
        currentScore!.save();
        // UPDATE LED DISPLAY - ADD THIS
        _updateLEDAfterScore();
        _endInnings();
        return;
      }
    }

    if (_isInningsComplete()) {
      currentScore!.save();
      // UPDATE LED DISPLAY - ADD THIS
      _updateLEDAfterScore();
      _endInnings();
      return;
    }

    currentScore!.save();
    
    // UPDATE LED DISPLAY - ADD THIS
    _updateLEDAfterScore();

    _showSelectNextBatsmanDialog();

    if (currentScore!.currentBall % 6 == 0) {
      if (runsInCurrentOver == 0) {
        currentBowler!.incrementMaiden();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maiden Over! 🎯'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
      runsInCurrentOver = 0;
      
      _showChangeBowlerDialog();
      _resetCurrentOver();
      _switchStrike();
    }
  });
}

void addRunout(int runs) {
  setState(() {
    pendingRunoutRuns = runs;
    _showRunoutBatsmanSelectionDialog(runs);
  });
}

void _showRunoutBatsmanSelectionDialog(int runs) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F24),
      title: const Text(
        'Select Batsman Who Got Run Out',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              TeamMember.getByPlayerId(strikeBatsman!.playerId)?.teamName ?? 'Striker',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Striker',
              style: TextStyle(color: Color(0xFF9AA0A6)),
            ),
            onTap: () {
              Navigator.pop(context);
              runoutBatsmanId = strikeBatsman!.batId;
              _showFielderSelectionDialog(runs, runoutBatsmanId!);
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            title: Text(
              TeamMember.getByPlayerId(nonStrikeBatsman!.playerId)?.teamName ?? 'Non-Striker',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Non-Striker',
              style: TextStyle(color: Color(0xFF9AA0A6)),
            ),
            onTap: () {
              Navigator.pop(context);
              runoutBatsmanId = nonStrikeBatsman!.batId;
              _showFielderSelectionDialog(runs, runoutBatsmanId!);
            },
          ),
        ],
      ),
    ),
  );
}

// Add this dialog method
void _showFielderSelectionDialog(int runs, String runoutBatsmanId) {
  if (currentInnings == null) return;

  final bowlingTeamPlayers = TeamMember.getByTeamId(currentInnings!.bowlingTeamId);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F24),
      title: const Text(
        'Run Out By',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: bowlingTeamPlayers.map((player) {
            return ListTile(
              title: Text(
                player.teamName,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'ID: ${player.playerId}',
                style: const TextStyle(color: Color(0xFF8F9499)),
              ),
              onTap: () {
                Navigator.pop(context);
                _finalizeRunout(runs, runoutBatsmanId, player.playerId);
              },
            );
          }).toList(),
        ),
      ),
    ),
  );
}

// Add this method to finalize runout
void _finalizeRunout(int runs, String runoutBatsmanId, String fielderId) {
  if (currentScore == null || currentBowler == null) return;

  setState(() {
    final runoutBatsman = Batsman.getByBatId(runoutBatsmanId);
    
    if (runoutBatsman == null) return;

    // Store action in history
    actionHistory.add({
      'type': 'runout',
      'runs': runs,
      'runoutBatsmanId': runoutBatsmanId,
      'fielderId': fielderId,
      'strikeBatsmanId': strikeBatsman!.batId,
      'nonStrikeBatsmanId': nonStrikeBatsman!.batId,
      'strikerRuns': strikeBatsman!.runs,
      'strikerBalls': strikeBatsman!.ballsFaced,
      'strikerFours': strikeBatsman!.fours,
      'strikerSixes': strikeBatsman!.sixes,
      'strikerDotBalls': strikeBatsman!.dotBalls,
      'strikerExtras': strikeBatsman!.extras,
      'runoutBatsmanIsOut': runoutBatsman.isOut,
      'runoutBatsmanDismissalType': runoutBatsman.dismissalType,
      'runoutBatsmanFielderId': runoutBatsman.fielderIdWhoRanOut,
      'bowlerRuns': currentBowler!.runsConceded,
      'bowlerBalls': currentBowler!.balls,
      'bowlerWickets': currentBowler!.wickets,
      'bowlerMaidens': currentBowler!.maidens,
      'bowlerExtras': currentBowler!.extras,
      'totalRuns': currentScore!.totalRuns,
      'wickets': currentScore!.wickets,
      'currentBall': currentScore!.currentBall,
      'overs': currentScore!.overs,
      'currentOver': List<String>.from(currentScore!.currentOver),
      'runsInCurrentOver': runsInCurrentOver,
    });

    // Update striker's stats with runs
    strikeBatsman!.updateStats(runs, extrasRuns: 0, countBall: true);

    // Mark the run out batsman as out
    runoutBatsman.markAsOut(
      dismissalType: 'runout',
      fielderIdWhoRanOut: fielderId,
    );

    // Trigger runout highlight animation
    _triggerRunoutHighlight(runoutBatsmanId);

    // Check for duck on runout
    if (runoutBatsman.runs == 0) {
      _triggerDuckAnimation(runoutBatsmanId);
    }

    // Update score
    currentScore!.totalRuns += runs;
    currentScore!.wickets++;

    // Update bowler stats (legal ball, runs conceded, no wicket credited)
    currentBowler!.updateStats(runs, false, extrasRuns: 0, countBall: true);

    // Update current over display
    var tempOver = currentScore!.currentOver;
    tempOver.add('${runs}RO');
    currentScore!.currentOver = tempOver;

    _updateOverTracking();

    currentScore!.crr = currentScore!.overs > 0 ? (currentScore!.totalRuns / currentScore!.overs) : 0.0;
    currentScore!.save();

    // UPDATE LED DISPLAY - ADD THIS
    _updateLEDAfterScore();

    runsInCurrentOver += runs;

    // Check if innings is complete
    if (currentInnings != null) {
      final teamMembers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
      final totalTeamMembers = teamMembers.length;
      
      if (currentScore!.wickets >= totalTeamMembers - 1) {
        _endInnings();
        return;
      }
    }

    if (_isInningsComplete()) {
      _endInnings();
      return;
    }

    // Check second innings victory
    if (currentInnings != null && currentInnings!.isSecondInnings) {
      if (_checkSecondInningsVictory()) return;
    }

    // Show next batsman dialog if the run out batsman was one of the current batsmen
    if (runoutBatsmanId == strikeBatsman!.batId) {
      _showSelectNextBatsmanDialog();
      setState(() {
        // Update striker to be the non-striker
        strikeBatsman = nonStrikeBatsman;
      });
    } else if (runoutBatsmanId == nonStrikeBatsman!.batId) {
      _showSelectNextBatsmanDialog();
    }

    // Switch strike if odd runs
    if (runs % 2 == 1) {
      _switchStrike();
    }

    // Check for over completion
    if (currentScore!.currentBall % 6 == 0) {
      if (runsInCurrentOver == 0) {
        currentBowler!.incrementMaiden();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maiden Over! 🎯'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
      runsInCurrentOver = 0;
      _showChangeBowlerDialog();
      _resetCurrentOver();
    }

    // Reset runout state
    isRunout = false;
    pendingRunoutRuns = null;
    this.runoutBatsmanId = null;
  });
}

 void _showSelectNextBatsmanDialog() {
  if (currentInnings == null) return;

  final allBatsmenInInnings = Batsman.getByInningsAndTeam(
    currentInnings!.inningsId,
    currentInnings!.battingTeamId,
  );

  final teamPlayers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
  final playersWhoBatted = allBatsmenInInnings.map((b) => b.playerId).toSet();
  final availablePlayers = teamPlayers.where((p) => 
    !playersWhoBatted.contains(p.playerId)
  ).toList();

  if (availablePlayers.isEmpty) {
    currentScore!.save();
    _endInnings();
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F24),
      title: const Text('Select Next Batsman', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Available Batsmen:',
                style: TextStyle(color: Color(0xFF6D7CFF), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            ...availablePlayers.map((player) {
              return ListTile(
                title: Text(player.teamName, style: const TextStyle(color: Colors.white)),
                subtitle: Text('ID: ${player.playerId}', style: const TextStyle(color: Color(0xFF8F9499))),
                onTap: () {
                  final newBatsman = Batsman.create(
                    inningsId: currentInnings!.inningsId,
                    teamId: currentInnings!.battingTeamId,
                    playerId: player.playerId,
                  );
                  
                  setState(() {
                    strikeBatsman = newBatsman;
                    currentScore!.strikeBatsmanId = newBatsman.batId;
                    currentScore!.save();
                  });
                  
                  Navigator.pop(context);
                  
                  // 🔥 ADD THIS - UPDATE LED IMMEDIATELY AFTER BATSMAN CHANGE
                  _updateLEDAfterScore();
                },
              );
            }).toList(),
          ],
        ),
      ),
    ),
  );
}
 void _showChangeBowlerDialog() {
  if (currentInnings == null) return;

  // Get all bowlers who have bowled in this innings
  final allBowlers = Bowler.getByInningsAndTeam(
    currentInnings!.inningsId,
    currentInnings!.bowlingTeamId,
  );

  // Get team players
  final teamPlayers = TeamMember.getByTeamId(currentInnings!.bowlingTeamId);
  final existingPlayerIds = allBowlers.map((b) => b.playerId).toSet();
  
  // Get available players who haven't bowled yet
  final newBowlerPlayers = teamPlayers.where((p) => 
    !existingPlayerIds.contains(p.playerId)
  ).toList();

  // Filter available bowlers: exclude the CURRENT bowler (who just completed the over)
  final availableBowlers = allBowlers.where((b) {
    // Exclude the bowler who just finished their over (current bowler)
    // currentBowler should be the Bowler object of who just bowled
    if (currentBowler != null && b.bowlerId == currentBowler!.bowlerId) {
      return false;
    }
    
    return true;
  }).toList();

  // Combine all available bowlers (existing + new) into a unified list
  List<Map<String, dynamic>> allAvailableBowlers = [];
  
  // Add existing bowlers
  for (var bowler in availableBowlers) {
    final player = TeamMember.getByPlayerId(bowler.playerId);
    allAvailableBowlers.add({
      'type': 'existing',
      'bowler': bowler,
      'player': player,
      'name': player?.teamName ?? 'Unknown',
      'stats': '${bowler.wickets}-${bowler.runsConceded} (${bowler.overs.toStringAsFixed(1)}) M:${bowler.maidens}',
    });
  }
  
  // Add new bowlers
  for (var player in newBowlerPlayers) {
    allAvailableBowlers.add({
      'type': 'new',
      'player': player,
      'name': player.teamName,
      'stats': 'New bowler',
    });
  }

  // Check if any bowlers are available
  if (allAvailableBowlers.isEmpty) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F24),
        title: const Text('No Bowlers Available', style: TextStyle(color: Colors.white)),
        content: const Text(
          'No bowlers are currently available. The current bowler cannot bowl consecutive overs, and no other bowlers are available.',
          style: TextStyle(color: Color(0xFF9AA0A6)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endInnings();
            },
            child: const Text('End Innings', style: TextStyle(color: Color(0xFFFF3B3B))),
          ),
        ],
      ),
    );
    return;
  }

  int backPressCount = 0;

  // Show unified dialog with all available bowlers
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        backPressCount++;
        if (backPressCount == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a bowler to continue'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        } else if (backPressCount >= 2) {
          // Auto-select first available bowler
          final firstBowler = allAvailableBowlers.first;
          Navigator.pop(context); // Close dialog first
          _selectBowler(firstBowler);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-selected bowler: ${firstBowler['name']}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          return false; // Prevent default back behavior
        }
        return false;
      },
      child: AlertDialog(
        backgroundColor: const Color(0xFF1C1F24),
        title: const Text('Select Next Bowler', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentBowler != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Note: ${_getBowlerNameById(currentBowler!.bowlerId)} cannot bowl consecutive overs',
                    style: const TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allAvailableBowlers.length,
                  itemBuilder: (context, index) {
                    final bowlerData = allAvailableBowlers[index];
                    return ListTile(
                      title: Text(
                        bowlerData['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        bowlerData['stats'],
                        style: TextStyle(
                          color: bowlerData['type'] == 'new' 
                              ? const Color(0xFF6D7CFF)
                              : const Color(0xFF8F9499),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _selectBowler(bowlerData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Helper method to get bowler name by ID
String _getBowlerNameById(String bowlerId) {
  final bowler = Bowler.getByBowlerId(bowlerId);
  if (bowler != null) {
    final player = TeamMember.getByPlayerId(bowler.playerId);
    return player?.teamName ?? 'Unknown';
  }
  return 'Unknown';
}

void _selectBowler(Map<String, dynamic> bowlerData) {
  setState(() {
    if (bowlerData['type'] == 'existing') {
      // Select existing bowler
      lastOverBowlerId = currentBowler?.bowlerId;
      currentBowler = bowlerData['bowler'];
      currentScore!.currentBowlerId = currentBowler!.bowlerId;
    } else {
      // Create new bowler
      final player = bowlerData['player'];
      final newBowler = Bowler.create(
        inningsId: currentInnings!.inningsId,
        teamId: currentInnings!.bowlingTeamId,
        playerId: player.playerId,
      );
      lastOverBowlerId = currentBowler?.bowlerId;
      currentBowler = newBowler;
      currentScore!.currentBowlerId = newBowler.bowlerId;
    }
    runsInCurrentOver = 0;
    currentScore!.save();
  });
  
  // 🔥 ADD THIS - UPDATE LED IMMEDIATELY WHEN BOWLER CHANGES
  Future.delayed(const Duration(milliseconds: 100), () {
    _updateLEDAfterScore();
  });
}

  bool _isInningsComplete() {
    if (currentMatch == null || currentScore == null) return false;
    int totalBalls = currentMatch!.overs * 6;
    return currentScore!.currentBall >= totalBalls;
  }



void _endInnings() {
  if (currentInnings == null || currentScore == null) return;
  
  currentInnings!.markCompleted();
  
  if (currentInnings!.isSecondInnings) {
    final firstInnings = Innings.getFirstInnings(widget.matchId);
    
    if (firstInnings != null) {
      final firstInningsScore = Score.getByInningsId(firstInnings.inningsId);
      if (firstInningsScore != null && currentInnings!.hasValidTarget) {
        try {
          if (currentInnings!.hasMetTarget(currentScore!.totalRuns)) {
            _showVictoryDialog(true, firstInningsScore);
            return;
          } else {
            _showVictoryDialog(false, firstInningsScore);
            return;
          }
        } catch (e) {
          print('Error checking target: $e');
        }
      }
    }
  } else {
    // First innings complete
    final teamMembers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
    final totalTeamMembers = teamMembers.length;
    // All out when wickets = total members - 1 (e.g., 10 wickets for 11 players)
    bool wasAllOut = currentScore!.wickets >= totalTeamMembers - 1;
    
    String message = wasAllOut 
        ? '🏏 All Out! Team ${currentInnings!.battingTeamId} scored ${currentScore!.totalRuns} runs in ${currentScore!.overs.toStringAsFixed(1)} overs (${currentScore!.wickets}/${totalTeamMembers - 1} wickets)'
        : '⏱️ Innings Complete! Team ${currentInnings!.battingTeamId} scored ${currentScore!.totalRuns}/${currentScore!.wickets} in ${currentMatch!.overs} overs';
    
    int targetRuns = currentScore!.totalRuns + 1;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F24),
        title: Text(
          wasAllOut ? 'All Out!' : 'First Innings Complete',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: Color(0xFF9AA0A6))),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0f0f1e),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9800), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 Second Innings Target',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target:',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        '$targetRuns runs',
                        style: const TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D7CFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _startSecondInnings();
            },
            child: const Text(
              'Start Second Innings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return;
  }
}

 void _startSecondInnings() async {
  try {
    if (currentMatch == null || currentInnings == null || currentScore == null) {
      throw Exception('Match data not available');
    }

    // Create second innings with teams switched
    final secondInnings = Innings.createSecondInnings(
      matchId: widget.matchId,
      battingTeamId: currentInnings!.bowlingTeamId, // Previous bowling team now bats
      bowlingTeamId: currentInnings!.battingTeamId, // Previous batting team now bowls
      firstInningsScore: currentScore!.totalRuns, // First innings total score
    );

    // Show dialog to select opening batsmen for second innings
    _showSelectOpeningBatsmenDialog(secondInnings);
    
  } catch (e) {
    _showErrorDialog('Error starting second innings: $e');
    print('Error in _startSecondInnings: $e');
  }
}

void _showSelectOpeningBatsmenDialog(Innings secondInnings) {
  // Get players from the NEW batting team (was bowling in first innings)
  final battingTeamPlayers = TeamMember.getByTeamId(secondInnings.battingTeamId);
  
  if (battingTeamPlayers.isEmpty) {
    _showErrorDialog('No players found for batting team!');
    return;
  }

  // Get all batsmen who have already played in ANY innings of this match
  final allMatchInnings = [
    Innings.getFirstInnings(widget.matchId),
    secondInnings,
  ].whereType<Innings>().toList();
  
  // Collect all player IDs who have batted in any innings for this team
  Set<String> playersWhoBattedInMatch = {};
  for (final innings in allMatchInnings) {
    if (innings.battingTeamId == secondInnings.battingTeamId) {
      final batsmenInInnings = Batsman.getByInningsAndTeam(
        innings.inningsId,
        secondInnings.battingTeamId,
      );
      playersWhoBattedInMatch.addAll(batsmenInInnings.map((b) => b.playerId));
    }
  }

  // Filter available players - only those who haven't batted yet
  final availablePlayers = battingTeamPlayers.where((p) => 
    !playersWhoBattedInMatch.contains(p.playerId)
  ).toList();

  if (availablePlayers.isEmpty) {
    _showErrorDialog('No available players for second innings! All players have already batted.');
    return;
  }

  String? selectedStriker;
  String? selectedNonStriker;
  String? selectedBowler;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        final bowlingTeamPlayers = TeamMember.getByTeamId(secondInnings.bowlingTeamId);
        
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1F24),
          title: const Text(
            'Select Opening Players for Innings 2',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target: ${secondInnings.targetRuns} runs',
                  style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Striker selection
                const Text('Striker:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedStriker,
                  hint: const Text('Select Striker', style: TextStyle(color: Colors.white54)),
                  dropdownColor: const Color(0xFF1C1F24),
                  items: availablePlayers
                      .where((p) => p.playerId != selectedNonStriker)
                      .map((player) => DropdownMenuItem(
                            value: player.playerId,
                            child: Text(
                              player.teamName,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStriker = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Non-striker selection
                const Text('Non-Striker:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedNonStriker,
                  hint: const Text('Select Non-Striker', style: TextStyle(color: Colors.white54)),
                  dropdownColor: const Color(0xFF1C1F24),
                  items: availablePlayers
                      .where((p) => p.playerId != selectedStriker)
                      .map((player) => DropdownMenuItem(
                            value: player.playerId,
                            child: Text(
                              player.teamName,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedNonStriker = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Bowler selection
                const Text('Opening Bowler:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedBowler,
                  hint: const Text('Select Bowler', style: TextStyle(color: Colors.white54)),
                  dropdownColor: const Color(0xFF1C1F24),
                  items: bowlingTeamPlayers
                      .map((player) => DropdownMenuItem(
                            value: player.playerId,
                            child: Text(
                              player.teamName,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedBowler = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF9AA0A6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D7CFF),
              ),
              onPressed: selectedStriker != null && selectedNonStriker != null && selectedBowler != null
                  ? () {
                      Navigator.of(context).pop();
                      _finalizeSecondInnings(
                        secondInnings,
                        selectedStriker!,
                        selectedNonStriker!,
                        selectedBowler!,
                      );
                    }
                  : null,
              child: const Text(
                'Start Innings',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ),
  );
}
void _finalizeSecondInnings(
  Innings secondInnings,
  String strikerId,
  String nonStrikerId,
  String bowlerId,
) async {
  try {
    // Create batsmen for second innings
    final striker = Batsman.create(
      inningsId: secondInnings.inningsId,
      teamId: secondInnings.battingTeamId,
      playerId: strikerId,
    );
    
    final nonStriker = Batsman.create(
      inningsId: secondInnings.inningsId,
      teamId: secondInnings.battingTeamId,
      playerId: nonStrikerId,
    );
    
    // Create bowler for second innings
    final bowler = Bowler.create(
      inningsId: secondInnings.inningsId,
      teamId: secondInnings.bowlingTeamId,
      playerId: bowlerId,
    );
    
    // Navigate to the same screen with new innings data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CricketScorerScreen(
          matchId: widget.matchId,
          inningsId: secondInnings.inningsId,
          strikeBatsmanId: striker.batId,
          nonStrikeBatsmanId: nonStriker.batId,
          bowlerId: bowler.bowlerId,
        ),
      ),
    );
    
  } catch (e) {
    _showErrorDialog('Error finalizing second innings: $e');
    print('Error in _finalizeSecondInnings: $e');
  }
}

  void _showAllOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F24),
        title: const Text('All Out!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Team is all out for ${currentScore?.totalRuns ?? 0} runs in ${currentScore?.overs ?? 0} overs',
          style: const TextStyle(color: Color(0xFF9AA0A6)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF6D7CFF))),
          ),
        ],
      ),
    );
  }

  void toggleExtrasOptions() {
    setState(() => showExtrasOptions = !showExtrasOptions);
  }

  void toggleNoBall() {
    if (!noBallEnabled) return;
    setState(() {
      isNoBall = !isNoBall;
      if (isNoBall) isWide = false;
    });
  }

  void toggleWide() {
    if (!wideEnabled) return;
    setState(() {
      isWide = !isWide;
      if (isWide) isNoBall = false;
    });
  }

  void toggleByes() {
    setState(() => isByes = !isByes);
  }

void swapPlayers() {
  setState(() {
    // Perform the strike switch
    _switchStrike();
    
    // Save the updated score
    currentScore?.save();
  });
  
  // 🔥 UPDATE LED IMMEDIATELY AFTER SWAP
  _updateLEDAfterScore();
  
  // Show brief feedback
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Players swapped ✓'),
      duration: Duration(milliseconds: 800),
      backgroundColor: Color(0xFF6D7CFF),
    ),
  );
}

 void undoLastBall() {
  if (actionHistory.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No action to undo'), duration: Duration(seconds: 2)),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C1F24),
      title: const Text('Confirm Undo', style: TextStyle(color: Colors.white)),
      content: Text(
        'Are you sure you want to undo the last ${actionHistory.last['type']}?',
        style: const TextStyle(color: Color(0xFF9AA0A6)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF9AA0A6))),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _performUndo();
          },
          child: const Text('Confirm', style: TextStyle(color: Color(0xFF6D7CFF))),
        ),
      ],
    ),
  );
}
 void _performUndo() {
  if (actionHistory.isEmpty || currentScore == null) return;

  setState(() {
    Map<String, dynamic> lastAction = actionHistory.removeLast();
    String actionType = lastAction['type'];

    if (actionType == 'runs') {
      final strikerBatId = lastAction['strikeBatsmanId'];
      final nonStrikerBatId = lastAction['nonStrikeBatsmanId'];
      
      final strikerBat = Batsman.getByBatId(strikerBatId);
      if (strikerBat != null) {
        strikerBat.runs = lastAction['batsmanRuns'];
        strikerBat.ballsFaced = lastAction['batsmanBalls'];
        strikerBat.fours = lastAction['batsmanFours'];
        strikerBat.sixes = lastAction['batsmanSixes'];
        strikerBat.dotBalls = lastAction['batsmanDotBalls'];
        strikerBat.extras = lastAction['batsmanExtras'];
        strikerBat.strikeRate = strikerBat.ballsFaced > 0 
            ? (strikerBat.runs / strikerBat.ballsFaced) * 100 
            : 0.0;
        strikerBat.save();
      }
      
      strikeBatsman = Batsman.getByBatId(strikerBatId);
      nonStrikeBatsman = Batsman.getByBatId(nonStrikerBatId);

      if (currentBowler != null) {
        currentBowler!.runsConceded = lastAction['bowlerRuns'];
        currentBowler!.balls = lastAction['bowlerBalls'];
        currentBowler!.wickets = lastAction['bowlerWickets'];
        currentBowler!.maidens = lastAction['bowlerMaidens'];
        currentBowler!.extras = lastAction['bowlerExtras'];
        
        int completedOvers = currentBowler!.balls ~/ 6;
        int remainingBalls = currentBowler!.balls % 6;
        currentBowler!.overs = completedOvers + (remainingBalls / 10.0);
        
        double totalOvers = completedOvers + (remainingBalls / 6.0);
        currentBowler!.economy = totalOvers > 0 ? (currentBowler!.runsConceded / totalOvers) : 0.0;
        
        currentBowler!.save();
        currentBowler = Bowler.getByBowlerId(currentBowler!.bowlerId);
      }

      // RESTORE SCORE EXTRAS COUNTS - ADDED
      if (lastAction.containsKey('byes')) {
        currentScore!.byes = lastAction['byes'];
      }
      if (lastAction.containsKey('wides')) {
        currentScore!.wides = lastAction['wides'];
      }
      if (lastAction.containsKey('noBalls')) {
        currentScore!.noBalls = lastAction['noBalls'];
      }

      currentScore!.totalRuns = lastAction['totalRuns'];
      currentScore!.currentBall = lastAction['currentBall'];
      currentScore!.overs = lastAction['overs'];
      currentScore!.currentOver = List<String>.from(lastAction['currentOver']);
      currentScore!.crr = currentScore!.overs > 0 ? (currentScore!.totalRuns / currentScore!.overs) : 0.0;
      
      if (lastAction.containsKey('runsInCurrentOver')) {
        runsInCurrentOver = lastAction['runsInCurrentOver'];
      }
      
      isNoBall = false;
      isWide = false;
      isByes = false;
      
    } else if (actionType == 'wicket') {
      final strikerBatId = lastAction['strikeBatsmanId'];
      final nonStrikerBatId = lastAction['nonStrikeBatsmanId'];
      
      final batsman = Batsman.getByBatId(strikerBatId);
      if (batsman != null) {
        batsman.isOut = lastAction['batsmanIsOut'];
        batsman.bowlerIdWhoGotWicket = lastAction['batsmanBowlerWhoGotWicket'];
        batsman.extras = lastAction['batsmanExtras'];
        batsman.save();
      }
      
      strikeBatsman = Batsman.getByBatId(strikerBatId);
      nonStrikeBatsman = Batsman.getByBatId(nonStrikerBatId);

      if (currentBowler != null) {
        currentBowler!.wickets = lastAction['bowlerWickets'];
        currentBowler!.balls = lastAction['bowlerBalls'];
        currentBowler!.runsConceded = lastAction['bowlerRuns'];
        currentBowler!.maidens = lastAction['bowlerMaidens'];
        currentBowler!.extras = lastAction['bowlerExtras'];
        
        int completedOvers = currentBowler!.balls ~/ 6;
        int remainingBalls = currentBowler!.balls % 6;
        currentBowler!.overs = completedOvers + (remainingBalls / 10.0);
        
        double totalOvers = completedOvers + (remainingBalls / 6.0);
        currentBowler!.economy = totalOvers > 0 ? (currentBowler!.runsConceded / totalOvers) : 0.0;
        
        currentBowler!.save();
        currentBowler = Bowler.getByBowlerId(currentBowler!.bowlerId);
      }

      // RESTORE SCORE EXTRAS COUNTS FOR WICKET UNDO
      if (lastAction.containsKey('byes')) {
        currentScore!.byes = lastAction['byes'];
      }
      if (lastAction.containsKey('wides')) {
        currentScore!.wides = lastAction['wides'];
      }
      if (lastAction.containsKey('noBalls')) {
        currentScore!.noBalls = lastAction['noBalls'];
      }

      currentScore!.wickets = lastAction['wickets'];
      currentScore!.currentBall = lastAction['currentBall'];
      currentScore!.currentOver = List<String>.from(lastAction['currentOver']);
      currentScore!.crr = currentScore!.overs > 0 ? (currentScore!.totalRuns / currentScore!.overs) : 0.0;
      
      if (lastAction.containsKey('runsInCurrentOver')) {
        runsInCurrentOver = lastAction['runsInCurrentOver'];
      }
      
    } else if (actionType == 'runout') {
      // Restore striker stats
      final strikerBatId = lastAction['strikeBatsmanId'];
      final strikerBat = Batsman.getByBatId(strikerBatId);
      if (strikerBat != null) {
        strikerBat.runs = lastAction['strikerRuns'];
        strikerBat.ballsFaced = lastAction['strikerBalls'];
        strikerBat.fours = lastAction['strikerFours'];
        strikerBat.sixes = lastAction['strikerSixes'];
        strikerBat.dotBalls = lastAction['strikerDotBalls'];
        strikerBat.extras = lastAction['strikerExtras'];
        strikerBat.strikeRate = strikerBat.ballsFaced > 0 
            ? (strikerBat.runs / strikerBat.ballsFaced) * 100 
            : 0.0;
        strikerBat.save();
      }

      // Restore run out batsman
      final runoutBatId = lastAction['runoutBatsmanId'];
      final runoutBat = Batsman.getByBatId(runoutBatId);
      if (runoutBat != null) {
        runoutBat.isOut = lastAction['runoutBatsmanIsOut'];
        runoutBat.dismissalType = lastAction['runoutBatsmanDismissalType'];
        runoutBat.fielderIdWhoRanOut = lastAction['runoutBatsmanFielderId'];
        runoutBat.save();
      }

      strikeBatsman = Batsman.getByBatId(strikerBatId);
      nonStrikeBatsman = Batsman.getByBatId(lastAction['nonStrikeBatsmanId']);

      // Restore bowler stats
      if (currentBowler != null) {
        currentBowler!.runsConceded = lastAction['bowlerRuns'];
        currentBowler!.balls = lastAction['bowlerBalls'];
        currentBowler!.wickets = lastAction['bowlerWickets'];
        currentBowler!.maidens = lastAction['bowlerMaidens'];
        currentBowler!.extras = lastAction['bowlerExtras'];
        
        int completedOvers = currentBowler!.balls ~/ 6;
        int remainingBalls = currentBowler!.balls % 6;
        currentBowler!.overs = completedOvers + (remainingBalls / 10.0);
        
        double totalOvers = completedOvers + (remainingBalls / 6.0);
        currentBowler!.economy = totalOvers > 0 ? (currentBowler!.runsConceded / totalOvers) : 0.0;
        
        currentBowler!.save();
        currentBowler = Bowler.getByBowlerId(currentBowler!.bowlerId);
      }

      // Restore score
      currentScore!.totalRuns = lastAction['totalRuns'];
      currentScore!.wickets = lastAction['wickets'];
      currentScore!.currentBall = lastAction['currentBall'];
      currentScore!.overs = lastAction['overs'];
      currentScore!.currentOver = List<String>.from(lastAction['currentOver']);
      currentScore!.crr = currentScore!.overs > 0 ? (currentScore!.totalRuns / currentScore!.overs) : 0.0;
      
      if (lastAction.containsKey('runsInCurrentOver')) {
        runsInCurrentOver = lastAction['runsInCurrentOver'];
      }
      
      isRunout = false;
      pendingRunoutRuns = null;
      runoutBatsmanId = null;
    }

    currentScore!.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Action undone successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  });
}
Future<void> _updateLEDAfterScore() async {
  try {
    final bleService = BleManagerService();
    
    if (!bleService.isConnected) {
      debugPrint('⚠️ Bluetooth not connected. Skipping LED update.');
      return;
    }
    
    debugPrint('📤 Updating LED display (atomic commands)...');
    
    // Get player names
    final strikerPlayer = TeamMember.getByPlayerId(strikeBatsman!.playerId);
    final nonStrikerPlayer = TeamMember.getByPlayerId(nonStrikeBatsman!.playerId);
    
    String truncateName(String name) {
      final truncated = name.length > 6 ? name.substring(0, 6) : name;
      return truncated.toUpperCase();
    }
    
    final strikerName = truncateName(strikerPlayer?.teamName ?? 'BAT1');
    final nonStrikerName = truncateName(nonStrikerPlayer?.teamName ?? 'BAT2');
    
    // ✅ FIXED: Use atomic CHANGE commands (clear + write in one operation)
    
    // Define fixed positions and widths
    const int scoreRunsX = 50;
    const int scoreRunsY = 30;
    const int scoreRunsWidth = 35;
    const int scoreRunsHeight = 18;
    
    const int scoreWicketsX = 104;
    const int scoreWicketsY = 30;
    const int scoreWicketsWidth = 33;
    const int scoreWicketsHeight = 18;
    
    const int crrX = 29;
    const int crrY = 50;
    const int crrWidth = 26;
    const int crrHeight = 10;
    
    const int oversX = 84;
    const int oversY = 50;
    const int oversWidth = 16;
    const int oversHeight = 10;
    
    const int bowlerStatsX = 58;
    const int bowlerStatsY = 60;
    const int bowlerStatsWidth = 24;
    const int bowlerStatsHeight = 10;
    
    const int bowlerOversX = 84;
    const int bowlerOversY = 60;
    const int bowlerOversWidth = 20;
    const int bowlerOversHeight = 10;
    
    const int strikerNameX = 10;
    const int strikerNameY = 76;
    const int strikerNameWidth = 32;
    const int strikerNameHeight = 10;
    
    const int strikerStatsX = 46;
    const int strikerStatsY = 76;
    const int strikerStatsWidth = 82;
    const int strikerStatsHeight = 10;
    
    const int nonStrikerNameX = 10;
    const int nonStrikerNameY = 85;
    const int nonStrikerNameWidth = 32;
    const int nonStrikerNameHeight = 10;
    
    const int nonStrikerStatsX = 46;
    const int nonStrikerStatsY = 85;
    const int nonStrikerStatsWidth = 82;
    const int nonStrikerStatsHeight = 10;
    
    // Prepare data strings
    final runs = currentScore!.totalRuns.toString();
    final wickets = currentScore!.wickets.toString();
    final overs = currentScore!.overs.toStringAsFixed(1);
    final crr = currentScore!.crr.toStringAsFixed(2);
    
    final strikerRuns = strikeBatsman!.runs.toString();
    final strikerBalls = strikeBatsman!.ballsFaced.toString();
    final nonStrikerRuns = nonStrikeBatsman!.runs.toString();
    final nonStrikerBalls = nonStrikeBatsman!.ballsFaced.toString();
    
    final bowlerWickets = currentBowler!.wickets.toString();
    final bowlerRuns = currentBowler!.runsConceded.toString();
    final bowlerOvers = currentBowler!.overs.toStringAsFixed(1);
    
    // ✅ ATOMIC CHANGE COMMANDS (clear + write in one operation)
    final commands = [
      'FILL 0 0 127 127 0 0 0',  // Clear entire display before sending new data
      'CHANGE $scoreRunsX $scoreRunsY $scoreRunsWidth $scoreRunsHeight 2 255 255 255 $runs',
      'CHANGE $scoreWicketsX $scoreWicketsY $scoreWicketsWidth $scoreWicketsHeight 2 255 255 255 $wickets',
      'CHANGE $crrX $crrY $crrWidth $crrHeight 1 255 255 0 $crr',
      'CHANGE $oversX $oversY $oversWidth $oversHeight 1 0 255 0 $overs',
      'CHANGE $bowlerStatsX $bowlerStatsY $bowlerStatsWidth $bowlerStatsHeight 1 0 255 0 $bowlerWickets/$bowlerRuns',
      'CHANGE $bowlerOversX $bowlerOversY $bowlerOversWidth $bowlerOversHeight 1 0 255 0 ($bowlerOvers)',
      'CHANGE $strikerNameX $strikerNameY $strikerNameWidth $strikerNameHeight 1 255 255 255 $strikerName',
      'CHANGE $strikerStatsX $strikerStatsY $strikerStatsWidth $strikerStatsHeight 1 200 255 200 $strikerRuns($strikerBalls)',
      'CHANGE $nonStrikerNameX $nonStrikerNameY $nonStrikerNameWidth $nonStrikerNameHeight 1 200 200 255 $nonStrikerName',
      'CHANGE $nonStrikerStatsX $nonStrikerStatsY $nonStrikerStatsWidth $nonStrikerStatsHeight 1 200 255 200 $nonStrikerRuns($nonStrikerBalls)',
    ];
    
    await bleService.sendRawCommands(commands);
    
    debugPrint('✅ LED display updated - Runs: $runs/$wickets, Overs: $overs, CRR: $crr');
    
  } catch (e) {
    debugPrint('❌ LED update failed: $e');
  }
}

Future<void> _updateLEDTimeAndTemp() async {
  try {
    final bleService = BleManagerService();
    
    if (!bleService.isConnected) {
      debugPrint('⚠️ Bluetooth not connected. Skipping time/temp update.');
      return;
    }
    
    debugPrint('🕐 Updating time and temperature...');
    
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final temp = (_envService.currentTemperature ?? 27).round();
    final tempStr = temp.toString();
    
    debugPrint('📊 Time: $timeStr | Temp: ${tempStr}°C');
    
    // ✅ ATOMIC CHANGE COMMANDS (from Doc 1)
    const int timeX = 3;
    const int timeY = 2;
    const int timeWidth = 33;
    const int timeHeight = 10;
    
    const int tempStartX = 102;
    const int tempY = 2;
    const int tempWidth = 12;
    const int tempHeight = 10;
    
    final commands = [
      'CHANGE $timeX $timeY $timeWidth $timeHeight 1 255 255 200 $timeStr',
      'CHANGE $tempStartX $tempY $tempWidth $tempHeight 1 200 255 200 $tempStr',
    ];
    
    await bleService.sendRawCommands(commands);
    
    debugPrint('✅ Time: $timeStr, Temp: ${tempStr}°C updated on LED');
    
  } catch (e) {
    debugPrint('❌ Time/temp update failed: $e');
  }
}

Widget _buildHeader(double w) {
  return Row(
    children: [
      // Back arrow button with confirmation
      GestureDetector(
        onTap: _showLeaveMatchDialog,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_back, color: Colors.white, size: w * 0.07),
        ),
      ),
      const Expanded(
        child: Center(
          child: Text(
            'Cricket Scorer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // Trending up icon (Statistics)
    IconButton(
  icon: const Icon(Icons.trending_up, color: Colors.white, size: 28),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchGraphPage(
          matchId: widget.matchId,
          inningsId: widget.inningsId,
        ),
      ),
    );
  },
),
     // Scoreboard icon
IconButton(
  icon: const Icon(Icons.scoreboard, color: Colors.white, size: 28),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreboardPage(
          matchId: widget.matchId,
          inningsId: widget.inningsId,
        ),
      ),
    );
  },
),
    ],
  );
}

Widget _buildRunoutButton() {
  return GestureDetector(
    onTap: isMatchComplete ? null : () {
      setState(() {
        isRunout = !isRunout;  // Toggle runout mode
        _isRunoutModeActive = isRunout;  // Activate blur overlay
        if (isRunout) {
          // Reset other extras when runout is activated
          isNoBall = false;
          isWide = false;
          isByes = false;

          // Scroll to focus on scorecard when runout is activated
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      });
    },
    child: Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isRunout 
              ? [Color(0xFFFFD700), Color(0xFFFFA500)]  // Active state
              : [Color(0xFFB8860B), Color(0xFFDAA520)], // Inactive state
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: isRunout ? Border.all(color: Color(0xFFFFD700), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(isRunout ? 0.8 : 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
          // Extra glow effect when runout mode is active
          if (_isRunoutModeActive)
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: const Center(
        child: Text(
          'RO',
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

  void _updateOverTracking() {
    if (currentScore == null) return;
    
    currentScore!.currentBall++;
    int completedOvers = currentScore!.currentBall ~/ 6;
    int ballsInCurrentOver = currentScore!.currentBall % 6;
    currentScore!.overs = completedOvers + (ballsInCurrentOver / 10.0);
  }

  void _switchStrike() {
    if (currentScore == null) return;
    
    String temp = currentScore!.strikeBatsmanId;
    currentScore!.strikeBatsmanId = currentScore!.nonStrikeBatsmanId;
    currentScore!.nonStrikeBatsmanId = temp;
    
    Batsman? tempBat = strikeBatsman;
    strikeBatsman = nonStrikeBatsman;
    nonStrikeBatsman = tempBat;
}
void _resetCurrentOver() {
if (currentScore == null) return;
currentScore!.currentOver = [];
}

// Animation Builder - Choose animation based on type
Widget _buildLottieAnimation(String assetPath) {
  if (assetPath.contains('Scored 4')) {
    return const BoundaryFourAnimation();
  } else if (assetPath.contains('SIX')) {
    return const BoundarySixAnimation();
  } else if (assetPath.contains('CRICKET OUT') || assetPath.contains('Out')) {
    return const WicketAnimation();
  } else if (assetPath.contains('Duck')) {
    return const DuckAnimation();
  } else if (assetPath == 'victory') {
    return const VictoryAnimation();
  } else if (assetPath == 'over') {
    return const BoundaryFourAnimation(); // Reuse 4 animation for over completion
  }

  // Fallback
  return const SizedBox.shrink();
}

// Lottie Animation Methods
void _triggerBoundaryAnimation(String animationType) {
  setState(() {
    _boundaryAnimationType = animationType; // '4' or '6'
    _showBoundaryAnimation = true;
  });

  // Auto-hide after animation completes (1200ms)
  Future.delayed(const Duration(milliseconds: 1200), () {
    if (mounted) {
      setState(() {
        _showBoundaryAnimation = false;
      });
    }
  });
}

void _triggerWicketAnimation() {
  setState(() {
    _showWicketAnimation = true;
  });

  // Show animation for 3 seconds before showing dialog
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      setState(() {
        _showWicketAnimation = false;
      });
    }
  });
}

void _triggerDuckAnimation(String batsmanId) {
  setState(() {
    _lastDuckBatsman = batsmanId;
    _showDuckAnimation = true;
  });

  // Auto-hide after animation completes (1000ms)
  Future.delayed(const Duration(milliseconds: 1000), () {
    if (mounted) {
      setState(() {
        _showDuckAnimation = false;
      });
    }
  });
}

void _triggerVictoryAnimation() {
  setState(() {
    _showVictoryAnimation = true;
  });

  // Show animation for 2 seconds before showing victory dialog
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() {
        _showVictoryAnimation = false;
      });
    }
  });
}

void _triggerRunoutHighlight(String batsmanId) {
  setState(() {
    _showRunoutHighlight = true;
    _runoutHighlightIndex = 0;
  });

  // Cycle through highlight indices 0-6
  int cycleCount = 0;
  const int totalCycles = 7;
  const Duration cycleDuration = Duration(milliseconds: 150);

  Future.doWhile(() async {
    await Future.delayed(cycleDuration);
    if (mounted && cycleCount < totalCycles) {
      setState(() {
        _runoutHighlightIndex = cycleCount;
      });
      cycleCount++;
      return true;
    }
    return false;
  }).then((_) {
    if (mounted) {
      setState(() {
        _showRunoutHighlight = false;
      });
    }
  });
}

@override
Widget build(BuildContext context) {
  if (isInitializing) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Appbg1.mainGradient,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6D7CFF)),
        ),
      ),
    );
  }

  if (currentScore == null || strikeBatsman == null || nonStrikeBatsman == null || currentBowler == null) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: Appbg1.mainGradient,
        ),
        child: const Center(
          child: Text('Error loading match data', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  final strikerPlayer = TeamMember.getByPlayerId(strikeBatsman!.playerId);
  final nonStrikerPlayer = TeamMember.getByPlayerId(nonStrikeBatsman!.playerId);
  final bowlerPlayer = TeamMember.getByPlayerId(currentBowler!.playerId);

  return WillPopScope(
    onWillPop: () async {
      _showLeaveMatchDialog();
      return false; // Prevents automatic pop
    },
    child: Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: Appbg1.mainGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar - FIXED: Only one header now
                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildHeader(MediaQuery.of(context).size.width),
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Main Score Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1F24),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Target display for second innings
                            if (currentInnings != null && currentInnings!.isSecondInnings && currentInnings!.hasValidTarget)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: Appbg1.mainGradient,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFF9800), width: 2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${currentInnings!.targetRuns - currentScore!.totalRuns} runs needed',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'off',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${((currentMatch!.overs * 6) - currentScore!.currentBall)} balls',
                                      style: const TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getBattingTeamName(),
                                      style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'CRR : ${currentScore!.crr.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFF9AA0A6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${currentScore!.totalRuns}-${currentScore!.wickets}',
                                      style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '(${currentScore!.overs.toStringAsFixed(1)})',
                                      style: const TextStyle(
                                        color: Color(0xFF9AA0A6),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Batsmen Stats
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: Appbg1.mainGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6D7CFF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Batsman',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(
                                  width: 40,
                                  child: Text('R', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 40,
                                  child: Text('B', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 40,
                                  child: Text('4s', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 40,
                                  child: Text('6s', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 50,
                                  child: Text('SR', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 1.5,
                              color: const Color(0xFF4D4D4D),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, color: Color(0xFF6D7CFF), size: 6),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          strikerPlayer?.teamName ?? 'Unknown',
                                          style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${strikeBatsman!.runs}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${strikeBatsman!.ballsFaced}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${strikeBatsman!.fours}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${strikeBatsman!.sixes}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    '${strikeBatsman!.strikeRate.toStringAsFixed(0)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      nonStrikerPlayer?.teamName ?? 'Unknown',
                                      style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${nonStrikeBatsman!.runs}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13)),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${nonStrikeBatsman!.ballsFaced}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13)),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${nonStrikeBatsman!.fours}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13)),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text('${nonStrikeBatsman!.sixes}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13)),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    '${nonStrikeBatsman!.strikeRate.toStringAsFixed(0)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bowler Stats
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: Appbg1.mainGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6D7CFF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Bowler',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(
                                  width: 40,
                                  child: Text('O', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 40,
                                  child: Text('M', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 40,
                                  child: Text('R', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 40,
                                  child: Text('W', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  width: 45,
                                  child: Text('ER', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 1.5,
                              color: const Color(0xFF4D4D4D),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    bowlerPlayer?.teamName ?? 'Unknown',
                                    style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${currentBowler!.overs.toStringAsFixed(1)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${currentBowler!.maidens}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${currentBowler!.runsConceded}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${currentBowler!.wickets}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 45,
                                  child: Text(
                                    '${currentBowler!.economy.toStringAsFixed(1)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Current Over
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1F25),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'OVER',
                              style: TextStyle(
                                color: Color(0xFF7A7F85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: currentScore!.currentOver.isEmpty
                                  ? const Text(
                                      'Waiting for delivery...',
                                      style: TextStyle(color: Color(0xFF7A7F85), fontSize: 12),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      children: currentScore!.currentOver.map((ball) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getBallColor(ball),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            ball,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Extras Options (if shown)
                      if (showExtrasOptions)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF20242A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildExtrasButton('No Ball', isNoBall, toggleNoBall, enabled: noBallEnabled),
                                _buildExtrasButton('Wide', isWide, toggleWide, enabled: wideEnabled),
                                _buildExtrasButton('Byes', isByes, toggleByes),
                              ],
                            ),
                          ),
                        ),

                      if (showExtrasOptions) const SizedBox(height: 16),

                      // Run Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRunButton('4', 4),
                            _buildRunButton('3', 3),
                            _buildRunButton('1', 1),
                            _buildRunButton('0', 0),
                            _buildRunButton('2', 2),
                            _buildRunButton('5', 5),
                            _buildRunButton('6', 6),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                    // Action Buttons Row
// Action Buttons Row - UPDATED WITH SWAP BUTTON
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      // Extras button
      GestureDetector(
        onTap: toggleExtrasOptions,
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: Color(0xFF000000), size: 24),
          ),
        ),
      ),
      
      // Wicket button
      _buildWicketButton(),
      
      // Swap button - NEW
      GestureDetector(
        onTap: swapPlayers,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BCD4).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.swap_horiz,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      
      // Runout button
      _buildRunoutButton(),
      
      // Undo button
      GestureDetector(
        onTap: undoLastBall,
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              // Glow effect when runout mode is active
              if (_isRunoutModeActive)
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.undo, color: Color(0xFF333333), size: 24),
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
          // Lottie Animation Overlays with Error Handling
          if (_showBoundaryAnimation)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: _buildLottieAnimation(
                        _boundaryAnimationType == '4'
                            ? 'assets/images/Scored 4.lottie'
                            : 'assets/images/SIX ANIMATION.lottie',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_showWicketAnimation)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: _buildLottieAnimation(
                      'assets/images/CRICKET OUT ANIMATION.lottie',
                    ),
                  ),
                ),
              ),
            ),
          if (_showDuckAnimation)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: _buildLottieAnimation(
                      'assets/images/Duck Out.lottie',
                    ),
                  ),
                ),
              ),
            ),
          // Victory Animation Overlay
          if (_showVictoryAnimation)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: _buildLottieAnimation('victory'),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildRunButton(String label, int value) {
  // Special styling for 4 and 6 buttons
  bool isBoundaryButton = (value == 4 || value == 6);

  return GestureDetector(
    onTap: isMatchComplete ? null : () => addRuns(value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isBoundaryButton ? 56 : 50,
      height: isBoundaryButton ? 71 : 65,
      decoration: BoxDecoration(
        // Different gradients for boundary buttons (4 and 6)
        gradient: isMatchComplete
            ? const LinearGradient(
                colors: [Color(0xFF666666), Color(0xFF555555), Color(0xFF444444)], // Gray for disabled
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : (value == 4
                ? const LinearGradient(
                    colors: [Color(0xFF26C6DA), Color(0xFF00BCD4), Color(0xFF0097A7)], // Soft teal/turquoise for 4
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : value == 6
                    ? const LinearGradient(
                        colors: [Color(0xFFCE93D8), Color(0xFFBA68C8), Color(0xFFAB47BC)], // Soft lavender/purple for 6
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFF6D7CFF), Color(0xFF2D3DFF)], // White to blue gradient for others
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isMatchComplete
                ? Colors.black.withValues(alpha: 0.3)
                : (isBoundaryButton
                    ? (value == 4 ? const Color(0xFF26C6DA) : const Color(0xFFCE93D8)).withValues(alpha: 0.6)
                    : const Color(0xFF6D7CFF).withValues(alpha: 0.4)),
            blurRadius: isBoundaryButton ? 15 : 10,
            spreadRadius: isBoundaryButton ? 3 : 2,
            offset: const Offset(0, 4),
          ),
          // Glow effect when runout mode is active
          if (_isRunoutModeActive)
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
        ],
        border: Border.all(
          color: isMatchComplete
              ? Colors.grey.withValues(alpha: 0.3)
              : (_isRunoutModeActive
                  ? const Color(0xFFFFD700).withValues(alpha: 0.9)  // Golden border when RO active
                  : (isBoundaryButton
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.3))),
          width: _isRunoutModeActive ? 3 : (isBoundaryButton ? 2 : 1),  // Thicker border in RO mode
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: isMatchComplete ? 0.5 : 1.0,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: isBoundaryButton ? 26 : 24,
              fontWeight: isBoundaryButton ? FontWeight.w900 : FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: const Offset(1, 1),
                  blurRadius: isBoundaryButton ? 3 : 2,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
Widget _buildWicketButton() {
return GestureDetector(
onTap: isMatchComplete ? null : addWicket,
child: Container(
width: 55,
height: 55,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient: const LinearGradient(
colors: [Color(0xFFFF3B3B), Color(0xFFFF0000)],
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
),
boxShadow: [
BoxShadow(
color: const Color(0xFFFF0000).withOpacity(0.6),
blurRadius: 10,
spreadRadius: 2,
),
// Glow effect when runout mode is active
if (_isRunoutModeActive)
BoxShadow(
color: const Color(0xFFFFD700).withValues(alpha: 0.8),
blurRadius: 12,
spreadRadius: 2,
offset: const Offset(0, 0),
),
],
),
child: const Center(
child: Text(
'W',
style: TextStyle(
color: Color(0xFFFFFFFF),
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
),
),
);
}
Widget _buildExtrasButton(String label, bool isActive, VoidCallback onTap, {bool enabled = true}) {
return GestureDetector(
onTap: (enabled && !isMatchComplete) ? onTap : null,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
decoration: BoxDecoration(
color: !enabled
? Colors.grey.withOpacity(0.3)
: isActive
? const Color(0xFF6D7CFF)
: Colors.white.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: !enabled
? Colors.grey
: isActive
? const Color(0xFF6D7CFF)
: Colors.white.withOpacity(0.3),
width: 1.5,
),
boxShadow: [
// Glow effect when runout mode is active
if (_isRunoutModeActive && !isMatchComplete)
BoxShadow(
color: const Color(0xFFFFD700).withValues(alpha: 0.8),
blurRadius: 10,
spreadRadius: 1,
offset: const Offset(0, 0),
),
],
),
child: Text(
label,
style: TextStyle(
color: !enabled ? Colors.grey : Colors.white,
fontWeight: FontWeight.w600,
),
),
),
);
}
Color _getBallColor(String ball) {
if (ball == 'W') return const Color(0xFFFF6B6B);
if (ball == '4') return const Color(0xFF4CAF50);
if (ball == '6') return const Color(0xFF2196F3);
if (ball.startsWith('WD') || ball.startsWith('NB')) return const Color(0xFFFF9800);
if (ball == '0') return const Color(0xFF666666);
return const Color(0xFF555555);
}
}