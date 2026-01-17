import 'package:TURF_TOWN_/src/Pages/Teams/scoreboard_page.dart';
import 'package:TURF_TOWN_/src/models/score.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:TURF_TOWN_/src/models/match_history.dart';
import 'package:TURF_TOWN_/src/models/team.dart';
import 'package:TURF_TOWN_/src/models/innings.dart';
import 'package:TURF_TOWN_/src/models/batsman.dart';
import 'package:TURF_TOWN_/src/models/bowler.dart';
import 'package:TURF_TOWN_/src/models/team_member.dart'; // CHANGED: Import TeamMember instead of Player


class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<MatchHistory> _matchHistories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchHistories();
  }

  void _loadMatchHistories() {
    setState(() {
      _isLoading = true;
    });

    try {
      final histories = MatchHistory.getAllCompleted();
      setState(() {
        _matchHistories = histories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading match histories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF140088), // deep purple
              Color(0xFF000000), // black
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Cricket',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Scorer',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.headphones,
                              color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings,
                              color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Recently Played Header with Shadow
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A4A),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'RECENTLY PLAYED',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // Matches List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _matchHistories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No match history yet',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completed matches will appear here',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              _loadMatchHistories();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _matchHistories.length,
                              itemBuilder: (context, index) {
                                final matchHistory = _matchHistories[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildMatchHistoryCard(matchHistory),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHistoryCard(MatchHistory matchHistory) {
    final teamA = Team.getById(matchHistory.teamAId);
    final teamB = Team.getById(matchHistory.teamBId);
 

    // Generate random colors for teams (you can customize this logic)
    final team1Color = _getTeamColor(matchHistory.teamAId);
    final team2Color = _getTeamColor(matchHistory.teamBId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Header
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      matchHistory.matchType.toUpperCase(),
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
    // Date removed
  ],
),
          const SizedBox(height: 12),

          // Teams
          _buildTeamRow(
            teamA?.teamName ?? 'Team A',
            team1Color,
            '${matchHistory.team1Runs}/${matchHistory.team1Wickets}',
            '(${matchHistory.team1Overs.toStringAsFixed(1)})',
          ),
          const SizedBox(height: 10),
          _buildTeamRow(
            teamB?.teamName ?? 'Team B',
            team2Color,
            '${matchHistory.team2Runs}/${matchHistory.team2Wickets}',
            '(${matchHistory.team2Overs.toStringAsFixed(1)})',
          ),
          const SizedBox(height: 12),

          // Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              matchHistory.result,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _navigateToScorecard(matchHistory);
                },
                child: const Text(
                  'Scorecard',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, size: 18, color: Colors.black54),
                onPressed: () {
                  _shareMatchAsPDF(matchHistory);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.black54),
                onPressed: () {
                  _showDeleteConfirmation(matchHistory);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToScorecard(MatchHistory matchHistory) {
    final innings = Innings.getFirstInnings(matchHistory.matchId);
    if (innings != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreboardPage(
            matchId: matchHistory.matchId,
            inningsId: innings.inningsId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scorecard not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 Future<void> _shareMatchAsPDF(MatchHistory matchHistory) async {
  final shareOption = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Share Match Scorecard'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('WhatsApp'),
            onTap: () => Navigator.pop(context, 'whatsapp'),
          ),
          ListTile(
            leading: const Icon(Icons.sms, color: Colors.blue),
            title: const Text('Messages'),
            onTap: () => Navigator.pop(context, 'messages'),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.purple),
            title: const Text('Instagram'),
            onTap: () => Navigator.pop(context, 'instagram'),
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.orange),
            title: const Text('Other'),
            onTap: () => Navigator.pop(context, 'other'),
          ),
        ],
      ),
    ),
  );

  if (shareOption == null) return;

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final teamA = Team.getById(matchHistory.teamAId);
    final teamB = Team.getById(matchHistory.teamBId);
    
    // Fetch innings data
    final allInnings = Innings.getByMatchId(matchHistory.matchId);
    final firstInnings = allInnings.isNotEmpty ? allInnings[0] : null;
    final secondInnings = allInnings.length > 1 ? allInnings[1] : null;
    
    // FIXED: Fetch Score for each innings to get extras
    final firstInningsScore = firstInnings != null ? Score.getByInningsId(firstInnings.inningsId) : null;
    final secondInningsScore = secondInnings != null ? Score.getByInningsId(secondInnings.inningsId) : null;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              color: PdfColors.blue900,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CRICKET MATCH SCORECARD',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    matchHistory.matchType.toUpperCase(),
                    style: pw.TextStyle(
                      color: PdfColors.grey300,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Match Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 2),
              ),
              child: pw.Column(
                children: [
                  _buildPDFTeamRow(
                    teamA?.teamName ?? 'Team A',
                    matchHistory.team1Runs,
                    matchHistory.team1Wickets,
                    matchHistory.team1Overs,
                    firstInningsScore?.totalExtras ?? 0, // FIXED: Use totalExtras from Score
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 20),
                  _buildPDFTeamRow(
                    teamB?.teamName ?? 'Team B',
                    matchHistory.team2Runs,
                    matchHistory.team2Wickets,
                    matchHistory.team2Overs,
                    secondInningsScore?.totalExtras ?? 0, // FIXED: Use totalExtras from Score
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Match Result
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green700, width: 2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MATCH RESULT',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    matchHistory.result,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                ],
              ),
            ),
            
            // First Innings Details
            if (firstInnings != null && firstInningsScore != null) ...[
              pw.SizedBox(height: 40),
              pw.Text(
                'FIRST INNINGS - ${firstInnings.battingTeamId == matchHistory.teamAId ? teamA?.teamName ?? "Team A" : teamB?.teamName ?? "Team B"}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildInningsDetails(firstInnings, firstInningsScore), // FIXED: Pass Score object
            ],
            
            // Second Innings Details
            if (secondInnings != null && secondInningsScore != null) ...[
              pw.SizedBox(height: 40),
              pw.Text(
                'SECOND INNINGS - ${secondInnings.battingTeamId == matchHistory.teamAId ? teamA?.teamName ?? "Team A" : teamB?.teamName ?? "Team B"}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 15),
              _buildInningsDetails(secondInnings, secondInningsScore), // FIXED: Pass Score object
            ],
            
            pw.SizedBox(height: 30),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Generated by Cricket Scorer App',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                DateTime.now().toString().split('.')[0],
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'match_${matchHistory.matchId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final shareText = '🏏 Cricket Match Result\n${teamA?.teamName ?? 'Team A'} vs ${teamB?.teamName ?? 'Team B'}';
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
      subject: 'Cricket Match Scorecard',
    );

  } catch (e) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error sharing match: $e'),
        backgroundColor: Colors.red,
      ),
    );
    print('Error generating PDF: $e');
  }
}
pw.Widget _buildInningsDetails(Innings innings, Score score) { // FIXED: Accept Score parameter
  // Get batsmen and bowlers for this innings
  final batsmen = Batsman.getByInningsId(innings.inningsId);
  final bowlers = Bowler.getByInningsId(innings.inningsId);
  
  // Build batting stats
  final battingStats = <Map<String, dynamic>>[];
  for (final batsman in batsmen) {
    final player = TeamMember.getByPlayerId(batsman.playerId);
    battingStats.add({
      'playerName': player?.teamName ?? 'Unknown',
      'runs': batsman.runs,
      'balls': batsman.ballsFaced,
      'fours': batsman.fours,
      'sixes': batsman.sixes,
      'strikeRate': batsman.strikeRate,
    });
  }
  
  // Build bowling stats
  final bowlingStats = <Map<String, dynamic>>[];
  for (final bowler in bowlers) {
    final player = TeamMember.getByPlayerId(bowler.playerId);
    bowlingStats.add({
      'playerName': player?.teamName ?? 'Unknown',
      'overs': bowler.overs,
      'maidens': bowler.maidens,
      'runs': bowler.runsConceded,
      'wickets': bowler.wickets,
      'economy': bowler.economy,
    });
  }
  
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Batting Stats
      if (battingStats.isNotEmpty) ...[
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'BATTING',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.Text(
              'Extras: ${score.extrasDisplay}', // FIXED: Use Score.extrasDisplay
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell('Batsman', isHeader: true),
                _buildTableCell('R', isHeader: true),
                _buildTableCell('B', isHeader: true),
                _buildTableCell('4s', isHeader: true),
                _buildTableCell('6s', isHeader: true),
                _buildTableCell('SR', isHeader: true),
              ],
            ),
            // Batting rows
            ...battingStats.map((stat) => pw.TableRow(
              children: [
                _buildTableCell(stat['playerName'] ?? 'Unknown'),
                _buildTableCell(stat['runs']?.toString() ?? '0'),
                _buildTableCell(stat['balls']?.toString() ?? '0'),
                _buildTableCell(stat['fours']?.toString() ?? '0'),
                _buildTableCell(stat['sixes']?.toString() ?? '0'),
                _buildTableCell(stat['strikeRate']?.toStringAsFixed(1) ?? '0.0'),
              ],
            )),
          ],
        ),
      ],
      
      if (battingStats.isNotEmpty && bowlingStats.isNotEmpty)
        pw.SizedBox(height: 30),
      
      // Bowling Stats
      if (bowlingStats.isNotEmpty) ...[
        pw.Text(
          'BOWLING',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell('Bowler', isHeader: true),
                _buildTableCell('O', isHeader: true),
                _buildTableCell('M', isHeader: true),
                _buildTableCell('R', isHeader: true),
                _buildTableCell('W', isHeader: true),
                _buildTableCell('Econ', isHeader: true),
              ],
            ),
            // Bowling rows
            ...bowlingStats.map((stat) => pw.TableRow(
              children: [
                _buildTableCell(stat['playerName'] ?? 'Unknown'),
                _buildTableCell(stat['overs']?.toStringAsFixed(1) ?? '0.0'),
                _buildTableCell(stat['maidens']?.toString() ?? '0'),
                _buildTableCell(stat['runs']?.toString() ?? '0'),
                _buildTableCell(stat['wickets']?.toString() ?? '0'),
                _buildTableCell(stat['economy']?.toStringAsFixed(2) ?? '0.00'),
              ],
            )),
          ],
        ),
      ],
    ],
  );
}
pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: isHeader ? 11 : 10,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: isHeader ? PdfColors.black : PdfColors.grey800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

 pw.Widget _buildPDFTeamRow(String teamName, int runs, int wickets, double overs, int extras) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(
        flex: 2,
        child: pw.Text(
          teamName,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              '$runs/$wickets',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '(${overs.toStringAsFixed(1)} overs)',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Extras: $extras',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
  void _showDeleteConfirmation(MatchHistory matchHistory) {
    final teamA = Team.getById(matchHistory.teamAId);
    final teamB = Team.getById(matchHistory.teamBId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text(
          'Are you sure you want to delete this match?\n\n${teamA?.teamName ?? 'Team A'} vs ${teamB?.teamName ?? 'Team B'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              matchHistory.delete();
              Navigator.pop(context);
              _loadMatchHistories();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Match deleted from history'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTeamColor(String teamId) {
    // Simple hash-based color generation for consistent team colors
    final hash = teamId.hashCode;
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0),
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.teal,
      const Color(0xFF7C4DFF),
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  Widget _buildTeamRow(String team, Color color, String score, String overs) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 14,
          child: Text(
            team.isNotEmpty ? team[0].toUpperCase() : 'T',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            team,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        if (overs.isNotEmpty)
          Text(
            ' $overs',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}