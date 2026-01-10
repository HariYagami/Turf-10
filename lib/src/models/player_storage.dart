import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlayerStorage {
  static const String _playersPrefix = 'team_players_';
  static const String _captainPrefix = 'team_captain_';

  // Get players for a team
  static Future<List<String>> getPlayers(String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString('$_playersPrefix$teamName');
    if (playersJson == null) return [];
    return List<String>.from(json.decode(playersJson));
  }

  // Save players for a team
  static Future<void> savePlayers(String teamName, List<String> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_playersPrefix$teamName', json.encode(players));
  }

  // Add player to team
  static Future<void> addPlayer(String teamName, String playerName) async {
    final players = await getPlayers(teamName);
    players.add(playerName);
    await savePlayers(teamName, players);
  }

  // Update player in team
  static Future<void> updatePlayer(String teamName, String oldName, String newName) async {
    final players = await getPlayers(teamName);
    final index = players.indexOf(oldName);
    if (index != -1) {
      players[index] = newName;
      await savePlayers(teamName, players);
      
      // Update captain if needed
      final captain = await getCaptain(teamName);
      if (captain == oldName) {
        await setCaptain(teamName, newName);
      }
    }
  }

  // Remove player from team
  static Future<void> removePlayer(String teamName, String playerName) async {
    final players = await getPlayers(teamName);
    players.remove(playerName);
    await savePlayers(teamName, players);
    
    // Remove captain if needed
    final captain = await getCaptain(teamName);
    if (captain == playerName) {
      await setCaptain(teamName, null);
    }
  }

  // Get captain
  static Future<String?> getCaptain(String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_captainPrefix$teamName');
  }

  // Set captain
  static Future<void> setCaptain(String teamName, String? captainName) async {
    final prefs = await SharedPreferences.getInstance();
    if (captainName == null) {
      await prefs.remove('$_captainPrefix$teamName');
    } else {
      await prefs.setString('$_captainPrefix$teamName', captainName);
    }
  }

  // Delete all data for a team
  static Future<void> deleteTeamData(String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_playersPrefix$teamName');
    await prefs.remove('$_captainPrefix$teamName');
  }

  // Update team name in storage (when team is renamed)
  static Future<void> updateTeamName(String oldName, String newName) async {
    final players = await getPlayers(oldName);
    final captain = await getCaptain(oldName);
    
    await savePlayers(newName, players);
    if (captain != null) {
      await setCaptain(newName, captain);
    }
    
    await deleteTeamData(oldName);
  }
}