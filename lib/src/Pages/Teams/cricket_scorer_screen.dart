import 'package:TURF_TOWN_/src/models/batsman.dart';
import 'package:TURF_TOWN_/src/models/bowler.dart';
import 'package:TURF_TOWN_/src/models/innings.dart';
import 'package:TURF_TOWN_/src/models/score.dart';
import 'package:TURF_TOWN_/src/models/team_member.dart';
import 'package:TURF_TOWN_/src/models/match.dart';
import 'package:flutter/material.dart';

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

  Map<String, dynamic>? lastAction;

  @override
  void initState() {
    super.initState();
    _initializeMatch();
  }

  Future<void> _initializeMatch() async {
    try {
      // Load match
      currentMatch = Match.getByMatchId(widget.matchId);
      if (currentMatch == null) {
        throw Exception('Match not found');
      }

      // Load innings
      currentInnings = Innings.getByInningsId(widget.inningsId);
      if (currentInnings == null) {
        throw Exception('Innings not found');
      }

      // Get or create score
      currentScore = Score.getByInningsId(widget.inningsId);
      if (currentScore == null) {
        currentScore = Score.create(widget.inningsId);
      }

      // Load batsmen
      strikeBatsman = Batsman.getByBatId(widget.strikeBatsmanId);
      nonStrikeBatsman = Batsman.getByBatId(widget.nonStrikeBatsmanId);
      
      // Load bowler
      currentBowler = Bowler.getByBowlerId(widget.bowlerId);

      // Update score with current players
      if (currentScore != null) {
        currentScore!.strikeBatsmanId = widget.strikeBatsmanId;
        currentScore!.nonStrikeBatsmanId = widget.nonStrikeBatsmanId;
        currentScore!.currentBowlerId = widget.bowlerId;
        currentScore!.save();
      }

      setState(() {
        isInitializing = false;
      });
    } catch (e) {
      print('Error initializing match: $e');
      _showErrorDialog('Failed to load match: $e');
    }
  }



 Widget _buildInningsInfo() {
  if (currentInnings == null || currentMatch == null) {
    return const SizedBox.shrink();
  }

  // Get first innings data for target calculation (only for second innings)
  Innings? firstInnings;
  Score? firstInningsScore;
  
  if (currentInnings!.isSecondInnings) { // Use the getter instead of checking inningsNumber
    firstInnings = Innings.getFirstInnings(widget.matchId);
    if (firstInnings != null) {
      firstInningsScore = Score.getByInningsId(firstInnings.inningsId);
    }
  }

  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: const Color(0xFF0f0f1e),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1a8b8b), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentInnings!.isFirstInnings ? 'Innings 1' : 'Innings 2',
          style: const TextStyle(
            color: Color(0xFF1a8b8b),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Match ID', currentMatch!.matchId),
        _buildInfoRow('Innings ID', currentInnings!.inningsId),
        _buildInfoRow('Batting Team ID', currentInnings!.battingTeamId),
        _buildInfoRow('Bowling Team ID', currentInnings!.bowlingTeamId),
        _buildInfoRow('Striker ID', strikeBatsman?.playerId ?? 'N/A'),
        _buildInfoRow('Non-Striker ID', nonStrikeBatsman?.playerId ?? 'N/A'),
        _buildInfoRow('Total Overs', '${currentMatch!.overs}'),
        
        // Only show target info in second innings
        if (currentInnings!.isSecondInnings && currentInnings!.hasValidTarget) ...[
          const Divider(color: Colors.white24, height: 20),
          _buildInfoRow(
            'Target', 
            '${currentInnings!.targetRuns} runs',
            valueColor: const Color(0xFFFF9800),
          ),
          if (firstInningsScore != null) ...[
            _buildInfoRow(
              'Innings 1 Score', 
              '${firstInningsScore.totalRuns}/${firstInningsScore.wickets}',
            ),
            _buildInfoRow(
              'Required Run Rate', 
              _calculateRequiredRunRate(currentInnings!.targetRuns).toStringAsFixed(2),
            ),
          ],
        ],
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

double _calculateRequiredRunRate(int targetRuns) {
  if (currentScore == null || currentMatch == null) return 0.0;
  
  int runsNeeded = targetRuns - currentScore!.totalRuns;
  double oversRemaining = currentMatch!.overs - currentScore!.overs;
  
  if (oversRemaining <= 0 || runsNeeded <= 0) return 0.0;
  return runsNeeded / oversRemaining;
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


bool _checkSecondInningsVictory() {
  // Use the new getter to check if it's second innings
  if (currentInnings == null || !currentInnings!.isSecondInnings) {
    return false;
  }

  // Use the hasMetTarget method from Innings model
  if (currentInnings!.hasValidTarget && currentScore != null) {
    try {
      if (currentInnings!.hasMetTarget(currentScore!.totalRuns)) {
        // Get first innings score for display
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
  
  String message;
  if (battingTeamWon) {
    int wicketsRemaining = 10 - currentScore!.wickets;
    double oversRemaining = currentMatch!.overs - currentScore!.overs;
    message = 'Team ${currentInnings!.battingTeamId} won by $wicketsRemaining wickets with ${oversRemaining.toStringAsFixed(1)} overs remaining!\n\n'
        'Target: ${currentInnings!.targetRuns}\n'
        'Scored: ${currentScore!.totalRuns}/${currentScore!.wickets}';
  } else {
    int runsDifference = currentInnings!.targetRuns - currentScore!.totalRuns - 1;
    message = 'Team ${currentInnings!.bowlingTeamId} won by $runsDifference runs!\n\n'
        'Target: ${currentInnings!.targetRuns}\n'
        'Scored: ${currentScore!.totalRuns}/${currentScore!.wickets}';
  }
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C2026),
      title: Text(
        battingTeamWon ? '🎉 Victory!' : 'Match Over',
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text(
            'Back to Home',
            style: TextStyle(color: Color(0xFF00C4FF)),
          ),
        ),
      ],
    ),
  );
}

void addRuns(int runs) {
  if (currentScore == null || strikeBatsman == null || currentBowler == null) return;

  setState(() {
    // Save current state for undo
    lastAction = {
      'type': 'runs',
      'runs': runs,
      'strikeBatsmanId': strikeBatsman!.batId,
      'batsmanRuns': strikeBatsman!.runs,
      'batsmanBalls': strikeBatsman!.ballsFaced,
      'batsmanFours': strikeBatsman!.fours,
      'batsmanSixes': strikeBatsman!.sixes,
      'bowlerRuns': currentBowler!.runsConceded,
      'bowlerBalls': currentBowler!.balls,
      'totalRuns': currentScore!.totalRuns,
      'currentBall': currentScore!.currentBall,
      'overs': currentScore!.overs,
      'currentOver': List<String>.from(currentScore!.currentOver),
      'isNoBall': isNoBall,
      'isWide': isWide,
      'isByes': isByes,
    };

    int totalRunsToAdd = runs;
    String ballDisplay = runs.toString();

    // Handle No Ball
    if (isNoBall) {
      totalRunsToAdd += 1;
      if (isByes) {
        ballDisplay = 'NB+$runs';
      } else {
        strikeBatsman!.updateStats(runs);
        ballDisplay = 'NB$runs';
      }
    }
    // Handle Wide
    else if (isWide) {
      totalRunsToAdd += 1;
      ballDisplay = isByes ? 'WD+$runs' : 'WD$runs';
    }
    // Handle Byes
    else if (isByes) {
      ballDisplay = 'B$runs';
    }
    // Normal run
    else {
      strikeBatsman!.updateStats(runs);
    }

    // Update bowler stats - only count as legal ball if not no-ball or wide
    if (!isNoBall && !isWide) {
      currentBowler!.updateStats(totalRunsToAdd, false);
    } else {
      // For extras, update runs but not balls
      currentBowler!.runsConceded += totalRunsToAdd;
      currentBowler!.save();
    }

    // Add ball to current over
    var tempOver = currentScore!.currentOver;
    tempOver.add(ballDisplay);
    currentScore!.currentOver = tempOver;

    // Only update over tracking for legal deliveries
    if (!isNoBall && !isWide) {
      _updateOverTracking();
    }

    currentScore!.totalRuns += totalRunsToAdd;
    currentScore!.crr = currentScore!.overs > 0 
        ? (currentScore!.totalRuns / currentScore!.overs) 
        : 0.0;

    currentScore!.save();

    // IMPORTANT: Check for victory in second innings AFTER updating score
    if (currentInnings != null && currentInnings!.isSecondInnings) {
      if (_checkSecondInningsVictory()) {
        return; // Stop execution if team won
      }
    }

    // Check for end of over
    if (!isNoBall && !isWide && currentScore!.currentBall % 6 == 0) {
      if (runs % 2 == 0) {
        _switchStrike();
      }
      
      // Check if innings should end (all overs completed)
      if (_isInningsComplete()) {
        _endInnings();
        return;
      }
      
      _showChangeBowlerDialog();
      _resetCurrentOver();
    } else if (runs % 2 == 1 && !isByes) {
      _switchStrike();
    }
    
    // Reset extras flags
    isNoBall = false;
    isWide = false;
    isByes = false;
  });
}

  void addWicket() {
  if (currentScore == null || strikeBatsman == null || currentBowler == null) return;

  setState(() {
    // Save current state for undo
    lastAction = {
      'type': 'wicket',
      'strikeBatsmanId': strikeBatsman!.batId,
      'batsmanIsOut': strikeBatsman!.isOut,
      'bowlerWickets': currentBowler!.wickets,
      'wickets': currentScore!.wickets,
      'currentBall': currentScore!.currentBall,
      'currentOver': List<String>.from(currentScore!.currentOver),
    };

    // Mark batsman as out
    strikeBatsman!.markAsOut(bowlerIdWhoGotWicket: currentBowler!.bowlerId);
    currentScore!.wickets++;
    currentBowler!.updateStats(0, true);

    // Add wicket to current over
    var tempOver = currentScore!.currentOver;
    tempOver.add('W');
    currentScore!.currentOver = tempOver;

    _updateOverTracking();

    // CRITICAL: Check if all team members are out
    if (currentInnings != null) {
      // Get total number of team members
      final teamMembers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
      final totalTeamMembers = teamMembers.length;
      
      // If all team members are out, end innings immediately
      if (currentScore!.wickets >= totalTeamMembers) {
        currentScore!.save();
        _endInnings();
        return;
      }
    }

    // Check if innings complete by overs
    if (_isInningsComplete()) {
      currentScore!.save();
      _endInnings();
      return;
    }

    // Show dialog to select next batsman (only if not all out)
    _showSelectNextBatsmanDialog();

    // Check for end of over
    if (currentScore!.currentBall % 6 == 0) {
      _showChangeBowlerDialog();
      _resetCurrentOver();
      _switchStrike();
    }

    currentScore!.save();
  });
}
  void _showSelectNextBatsmanDialog() {
    if (currentInnings == null) return;

    // Get all batsmen for this innings
    final allBatsmen = Batsman.getByInningsAndTeam(
      currentInnings!.inningsId,
      currentInnings!.battingTeamId,
    );

    // Filter available batsmen (not out and not currently batting)
    final availableBatsmen = allBatsmen.where((b) => 
      !b.isOut && 
      b.batId != strikeBatsman?.batId && 
      b.batId != nonStrikeBatsman?.batId
    ).toList();

    // If no batsmen created yet, get players from team
    if (availableBatsmen.isEmpty) {
      final teamPlayers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
      final existingPlayerIds = allBatsmen.map((b) => b.playerId).toSet();
      final availablePlayers = teamPlayers.where((p) => 
        !existingPlayerIds.contains(p.playerId)
      ).toList();

      if (availablePlayers.isEmpty) {
        _showAllOutDialog();
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C2026),
          title: const Text(
            'Select Next Batsman',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];
                return ListTile(
                  title: Text(
                    player.teamName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'ID: ${player.playerId}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    // Create new batsman
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
                  },
                );
              },
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C2026),
          title: const Text(
            'Select Next Batsman',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableBatsmen.length,
              itemBuilder: (context, index) {
                final batsman = availableBatsmen[index];
                final player = TeamMember.getByPlayerId(batsman.playerId);
                return ListTile(
                  title: Text(
                    player?.teamName ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Runs: ${batsman.runs} (${batsman.ballsFaced})',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    setState(() {
                      strikeBatsman = batsman;
                      currentScore!.strikeBatsmanId = batsman.batId;
                      currentScore!.save();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }

  void _showChangeBowlerDialog() {
    if (currentInnings == null) return;

    // Get all bowlers for this innings
    final allBowlers = Bowler.getByInningsAndTeam(
      currentInnings!.inningsId,
      currentInnings!.bowlingTeamId,
    );

    // Get available bowlers (different from current)
    final availableBowlers = allBowlers.where((b) => 
      b.bowlerId != currentBowler?.bowlerId
    ).toList();

    // If no bowlers created yet, get players from team
    if (availableBowlers.isEmpty && allBowlers.length < 2) {
      final teamPlayers = TeamMember.getByTeamId(currentInnings!.bowlingTeamId);
      final existingPlayerIds = allBowlers.map((b) => b.playerId).toSet();
      final availablePlayers = teamPlayers.where((p) => 
        !existingPlayerIds.contains(p.playerId)
      ).toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C2026),
          title: const Text(
            'Select Next Bowler',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];
                return ListTile(
                  title: Text(
                    player.teamName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'ID: ${player.playerId}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    // Create new bowler
                    final newBowler = Bowler.create(
                      inningsId: currentInnings!.inningsId,
                      teamId: currentInnings!.bowlingTeamId,
                      playerId: player.playerId,
                    );
                    
                    setState(() {
                      currentBowler = newBowler;
                      currentScore!.currentBowlerId = newBowler.bowlerId;
                      currentScore!.save();
                    });
                    
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C2026),
          title: const Text(
            'Select Next Bowler',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableBowlers.length,
              itemBuilder: (context, index) {
                final bowler = availableBowlers[index];
                final player = TeamMember.getByPlayerId(bowler.playerId);
                return ListTile(
                  title: Text(
                    player?.teamName ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${bowler.wickets}-${bowler.runsConceded} (${bowler.overs})',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    setState(() {
                      currentBowler = bowler;
                      currentScore!.currentBowlerId = bowler.bowlerId;
                      currentScore!.save();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }

  bool _isInningsComplete() {
    if (currentMatch == null || currentScore == null) return false;
    
    // Check if all overs completed
    int totalBalls = currentMatch!.overs * 6;
    return currentScore!.currentBall >= totalBalls;
  }

// Replace the _endInnings() method with this updated version:

void _endInnings() {
  if (currentInnings == null || currentScore == null) return;
  
  currentInnings!.markCompleted();
  
  String message;
  
  if (currentInnings!.isSecondInnings) {
    // Second innings ended - determine winner
    final firstInnings = Innings.getFirstInnings(widget.matchId);
    
    if (firstInnings != null) {
      final firstInningsScore = Score.getByInningsId(firstInnings.inningsId);
      if (firstInningsScore != null && currentInnings!.hasValidTarget) {
        try {
          // Check if batting team met the target
          if (currentInnings!.hasMetTarget(currentScore!.totalRuns)) {
            // Batting team won
            _showVictoryDialog(true, firstInningsScore);
            return;
          } else {
            // Batting team failed to chase - bowling team (first innings team) wins
            _showVictoryDialog(false, firstInningsScore);
            return;
          }
        } catch (e) {
          print('Error checking target: $e');
        }
      }
    }
  } else {
    // First innings complete - show summary and start second innings
    // Get total team members to check if all out
    final teamMembers = TeamMember.getByTeamId(currentInnings!.battingTeamId);
    final totalTeamMembers = teamMembers.length;
    bool wasAllOut = currentScore!.wickets >= totalTeamMembers;
    
    message = wasAllOut 
        ? '🏏 All Out! Team ${currentInnings!.battingTeamId} scored ${currentScore!.totalRuns} runs in ${currentScore!.overs.toStringAsFixed(1)} overs (${currentScore!.wickets}/$totalTeamMembers wickets)'
        : '⏱️ Innings Complete! Team ${currentInnings!.battingTeamId} scored ${currentScore!.totalRuns}/${currentScore!.wickets} in ${currentMatch!.overs} overs';
    
    // Calculate target
    int targetRuns = currentScore!.totalRuns + 1;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: Row(
          children: [
            Icon(
              wasAllOut ? Icons.sports_cricket : Icons.timer,
              color: const Color(0xFF00C4FF),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'First Innings Complete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Innings Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0f0f1e),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1a8b8b), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Final Score:',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
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
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overs Bowled:',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        currentScore!.overs.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (wasAllOut) ...[
                    const SizedBox(height: 4),
                    Text(
                      '⚠️ All $totalTeamMembers Players Out',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Target Information
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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
                  const SizedBox(height: 8),
                  Text(
                    'Team ${currentInnings!.bowlingTeamId} needs $targetRuns runs to win in ${currentMatch!.overs} overs',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C4FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _startSecondInnings();
            },
            child: const Text(
              'Start Second Innings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
    return;
  }
  
 
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C2026),
      title: const Text(
        'Innings Complete',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        'Innings has ended',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Color(0xFF00C4FF)),
          ),
        ),
      ],
    ),
  );
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
          backgroundColor: const Color(0xFF1C2026),
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
                  dropdownColor: const Color(0xFF1C2026),
                  items: battingTeamPlayers
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
                  dropdownColor: const Color(0xFF1C2026),
                  items: battingTeamPlayers
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
                  dropdownColor: const Color(0xFF1C2026),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C4FF),
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
        backgroundColor: const Color(0xFF1C2026),
        title: const Text(
          'All Out!',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Team is all out for ${currentScore?.totalRuns ?? 0} runs in ${currentScore?.overs ?? 0} overs',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00C4FF)),
            ),
          ),
        ],
      ),
    );
  }

  void toggleExtrasOptions() {
    setState(() {
      showExtrasOptions = !showExtrasOptions;
    });
  }

  void toggleNoBall() {
    setState(() {
      isNoBall = !isNoBall;
      if (isNoBall) {
        isWide = false;
      }
    });
  }

  void toggleWide() {
    setState(() {
      isWide = !isWide;
      if (isWide) {
        isNoBall = false;
      }
    });
  }

  void toggleByes() {
    setState(() {
      isByes = !isByes;
    });
  }

  void swapPlayers() {
    setState(() {
      _switchStrike();
      currentScore?.save();
    });
  }

  void undoLastBall() {
    if (lastAction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No action to undo'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text(
          'Confirm Undo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to undo the last ${lastAction!['type']}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performUndo();
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Color(0xFF00C4FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _performUndo() {
    if (lastAction == null || currentScore == null) return;

    setState(() {
      String actionType = lastAction!['type'];

      if (actionType == 'runs') {
        // Restore batsman stats
        if (strikeBatsman != null) {
          strikeBatsman!.runs = lastAction!['batsmanRuns'];
          strikeBatsman!.ballsFaced = lastAction!['batsmanBalls'];
          strikeBatsman!.fours = lastAction!['batsmanFours'];
          strikeBatsman!.sixes = lastAction!['batsmanSixes'];
          strikeBatsman!.save();
        }

        // Restore bowler stats
        if (currentBowler != null) {
          currentBowler!.runsConceded = lastAction!['bowlerRuns'];
          currentBowler!.balls = lastAction!['bowlerBalls'];
          currentBowler!.save();
        }

        // Restore score
        currentScore!.totalRuns = lastAction!['totalRuns'];
        currentScore!.currentBall = lastAction!['currentBall'];
        currentScore!.overs = lastAction!['overs'];
        currentScore!.currentOver = List<String>.from(lastAction!['currentOver']);
        
      } else if (actionType == 'wicket') {
        // Restore batsman who was out
        final batsmanId = lastAction!['strikeBatsmanId'];
        final batsman = Batsman.getByBatId(batsmanId);
        if (batsman != null) {
          batsman.isOut = lastAction!['batsmanIsOut'];
          batsman.save();
        }

        // Restore bowler stats
        if (currentBowler != null) {
          currentBowler!.wickets = lastAction!['bowlerWickets'];
          currentBowler!.save();
        }

        // Restore score
        currentScore!.wickets = lastAction!['wickets'];
        currentScore!.currentBall = lastAction!['currentBall'];
        currentScore!.currentOver = List<String>.from(lastAction!['currentOver']);
      }

      currentScore!.save();
      lastAction = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action undone successfully'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    });
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
    
    // Swap actual batsman objects
    Batsman? tempBat = strikeBatsman;
    strikeBatsman = nonStrikeBatsman;
    nonStrikeBatsman = tempBat;
  }

  void _resetCurrentOver() {
    if (currentScore == null) return;
    currentScore!.currentOver = [];
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1a8b8b),
          ),
        ),
      );
    }

    if (currentScore == null || strikeBatsman == null || nonStrikeBatsman == null || currentBowler == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        body: const Center(
          child: Text(
            'Error loading match data',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final strikerPlayer = TeamMember.getByPlayerId(strikeBatsman!.playerId);
    final nonStrikerPlayer = TeamMember.getByPlayerId(nonStrikeBatsman!.playerId);
    final bowlerPlayer = TeamMember.getByPlayerId(currentBowler!.playerId);

    return Scaffold(
    backgroundColor: const Color(0xFF1a1a2e),
    appBar: _buildAppBar(),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Score Board',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // ADD THIS: Innings Information Display
            _buildInningsInfo(),
            
            // Score Card
            Container(
              padding: const EdgeInsets.all(16), decoration: BoxDecoration(
                  color: const Color(0xFF0f0f1e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Score',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              '${currentScore!.totalRuns}/${currentScore!.wickets}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Overs',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              currentScore!.overs.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'CRR',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              currentScore!.crr.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Target: ${currentMatch!.overs} overs',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Batsmen Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f0f1e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBatsmanRow(
                      strikerPlayer?.teamName ?? 'Unknown',
                      strikeBatsman!.runs,
                      strikeBatsman!.ballsFaced,
                      strikeBatsman!.strikeRate,
                      true,
                    ),
                    const Divider(color: Colors.grey),
                    _buildBatsmanRow(
                      nonStrikerPlayer?.teamName ?? 'Unknown',
                      nonStrikeBatsman!.runs,
                      nonStrikeBatsman!.ballsFaced,
                      nonStrikeBatsman!.strikeRate,
                      false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bowler Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f0f1e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bowlerPlayer?.teamName ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${currentBowler!.wickets}-${currentBowler!.runsConceded} (${currentBowler!.overs})',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Current Over Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f0f1e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Over',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentScore!.currentOver.isEmpty
                          ? [
                              const Text(
                                'No balls bowled yet',
                                style: TextStyle(color: Colors.white54),
                              )
                            ]
                          : currentScore!.currentOver.map((ball) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getBallColor(ball),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ball,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Extras Options
              if (showExtrasOptions)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f0f1e),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Extras',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildExtraButton('No Ball', isNoBall, toggleNoBall),
                          _buildExtraButton('Wide', isWide, toggleWide),
                          _buildExtraButton('Byes', isByes, toggleByes),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Scoring Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f0f1e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Run buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRunButton('0', 0),
                        _buildRunButton('1', 1),
                        _buildRunButton('2', 2),
                        _buildRunButton('3', 3),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRunButton('4', 4),
                        _buildRunButton('5', 5),
                        _buildRunButton('6', 6),
                        _buildWicketButton(),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    'Extras',
                    Icons.add_circle_outline,
                    toggleExtrasOptions,
                  ),
                  _buildActionButton(
                    'Swap',
                    Icons.swap_horiz,
                    swapPlayers,
                  ),
                  _buildActionButton(
                    'Undo',
                    Icons.undo,
                    undoLastBall,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0f0f1e),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Live Scoring',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBatsmanRow(
    String name,
    int runs,
    int balls,
    double strikeRate,
    bool isStriker,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (isStriker)
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: Color(0xFF1a8b8b),
                ),
              if (isStriker) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isStriker ? Colors.white : Colors.white70,
                    fontWeight: isStriker ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          '$runs ($balls)',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(width: 16),
        Text(
          'SR: ${strikeRate.toStringAsFixed(1)}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRunButton(String label, int runs) {
    return ElevatedButton(
      onPressed: () => addRuns(runs),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1a8b8b),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWicketButton() {
    return ElevatedButton(
      onPressed: addWicket,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'W',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExtraButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1a8b8b) : Colors.transparent,
          border: Border.all(
            color: isActive ? const Color(0xFF1a8b8b) : Colors.white54,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2a2a3e),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Color _getBallColor(String ball) {
    if (ball == 'W') return const Color(0xFFD32F2F);
    if (ball == '4') return const Color(0xFF4CAF50);
    if (ball == '6') return const Color(0xFF2196F3);
    if (ball.startsWith('WD') || ball.startsWith('NB')) {
      return const Color(0xFFFF9800);
    }
    return const Color(0xFF424242);
  }
}