import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

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
                          icon: const Icon(CupertinoIcons.headphones, color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 24),
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCricketMatch(
                      date: '04/01/2025',
                      time: '04:36 PM',
                      team1: 'TEAM HYDRA',
                      team1Color: const Color(0xFF4CAF50),
                      team1Score: '80/0',
                      team1Overs: '(0.2)',
                      team2: 'CRICKET WARRIORS',
                      team2Color: const Color(0xFF9C27B0),
                      team2Score: '0/0',
                      team2Overs: '(Yet to bat)',
                      status: 'Resumed',
                      statusColor: const Color(0xFF7C4DFF),
                    ),
                    const SizedBox(height: 12),
                    _buildFootballMatch(
                      date: '03/01/2025',
                      time: '09:14 PM',
                      team1: 'REAL MADRID',
                      team1Color: const Color(0xFF9C27B0),
                      team1Score: 'LOSS',
                      team2: 'BARCELONA',
                      team2Color: const Color(0xFF4CAF50),
                      team2Score: 'WON',
                      status: 'Completed',
                      statusColor: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildCricketMatch(
                      date: '03/01/2025',
                      time: '04:36 PM',
                      team1: 'RCB',
                      team1Color: Colors.red,
                      team1Score: '49/0',
                      team1Overs: '(18.5)',
                      team2: 'CSK',
                      team2Color: Colors.yellow,
                      team2Score: '37/1',
                      team2Overs: '(Yet to bat)',
                      status: 'Resumed',
                      statusColor: const Color(0xFF7C4DFF),
                    ),
                    const SizedBox(height: 12),
                    _buildFootballMatch(
                      date: '31/01/2025',
                      time: '07:44 PM',
                      team1: 'LIVERPOOL',
                      team1Color: const Color(0xFF9C27B0),
                      team1Score: 'LOSS',
                      team2: 'MANCHESTER CITY',
                      team2Color: const Color(0xFF4CAF50),
                      team2Score: 'WON',
                      status: 'Completed',
                      statusColor: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildBadmintonMatch(
                      date: '28/01/2025',
                      time: '05:07 PM',
                      player: 'AKASH',
                      playerColor: const Color(0xFF9C27B0),
                      opponent: 'VARLEY',
                      opponentScore: 'WON BY 4 POINTS',
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCricketMatch({
    required String date,
    required String time,
    required String team1,
    required Color team1Color,
    required String team1Score,
    required String team1Overs,
    required String team2,
    required Color team2Color,
    required String team2Score,
    required String team2Overs,
    required String status,
    required Color statusColor,
  }) {
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
              const Text(
                'CRICKET',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '$date • $time',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Teams
          _buildTeamRow(team1, team1Color, team1Score, team1Overs),
          const SizedBox(height: 10),
          _buildTeamRow(team2, team2Color, team2Score, team2Overs),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Scorecard',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, size: 18, color: Colors.black54),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.black54),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFootballMatch({
    required String date,
    required String time,
    required String team1,
    required Color team1Color,
    required String team1Score,
    required String team2,
    required Color team2Color,
    required String team2Score,
    required String status,
    required Color statusColor,
  }) {
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
              const Text(
                'FOOTBALL',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '$date • $time',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Teams
          _buildTeamRow(team1, team1Color, team1Score, ''),
          const SizedBox(height: 10),
          _buildTeamRow(team2, team2Color, team2Score, ''),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Scorecard',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, size: 18, color: Colors.black54),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.black54),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadmintonMatch({
    required String date,
    required String time,
    required String player,
    required Color playerColor,
    required String opponent,
    required String opponentScore,
  }) {
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
              const Text(
                'BADMINTON',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '$date • $time',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Players
          Row(
            children: [
              CircleAvatar(
                backgroundColor: playerColor,
                radius: 14,
                child: Text(
                  player[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                player,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 14,
                child: Text(
                  opponent[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$opponent ($opponentScore)',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String team, Color color, String score, String overs) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 14,
          child: Text(
            team[0],
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