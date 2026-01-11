
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'team.dart';
import 'team_member.dart';
import 'match.dart';
import './objectbox.g.dart'; // Adjust path if objectbox.g.dart is in lib/ root

class ObjectBoxHelper {
  static Store? _store;
  static Box<Team>? _teamBox;
  static Box<TeamMember>? _teamMemberBox;
  static Box<Match>? _matchBox;

  /// Check if ObjectBox is initialized
  static bool get isInitialized => _store != null;

  /// Initialize ObjectBox store and boxes
  static Future<void> init() async {
    if (_store != null) {
      print('⚠️ ObjectBox already initialized');
      return;
    }

    try {
      print('🔄 Initializing ObjectBox...');
      
      final dir = await getApplicationDocumentsDirectory();
      final storePath = p.join(dir.path, 'objectbox');
      
      print('📁 Store path: $storePath');
      
      _store = await openStore(directory: storePath);
      _teamBox = _store!.box<Team>();
      _teamMemberBox = _store!.box<TeamMember>();
      _matchBox = _store!.box<Match>();
      
      print('✅ ObjectBox initialized successfully');
      print('📊 Database Stats:');
      print('   - Teams: ${_teamBox!.count()}');
      print('   - Team Members: ${_teamMemberBox!.count()}');
      print('   - Matches: ${_matchBox!.count()}');
    } catch (e, stackTrace) {
      print('❌ Failed to initialize ObjectBox: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get Team box (throws if not initialized)
  static Box<Team> get teamBox {
    if (_teamBox == null) {
      throw Exception(
        'ObjectBox not initialized. Call ObjectBoxHelper.init() first in main.dart'
      );
    }
    return _teamBox!;
  }

  /// Get TeamMember box (throws if not initialized)
  static Box<TeamMember> get teamMemberBox {
    if (_teamMemberBox == null) {
      throw Exception(
        'ObjectBox not initialized. Call ObjectBoxHelper.init() first in main.dart'
      );
    }
    return _teamMemberBox!;
  }

  /// Get Match box (throws if not initialized)
  static Box<Match> get matchBox {
    if (_matchBox == null) {
      throw Exception(
        'ObjectBox not initialized. Call ObjectBoxHelper.init() first in main.dart'
      );
    }
    return _matchBox!;
  }

  /// Get Store instance
  static Store get store {
    if (_store == null) {
      throw Exception(
        'ObjectBox not initialized. Call ObjectBoxHelper.init() first in main.dart'
      );
    }
    return _store!;
  }

  /// Close the ObjectBox store
  static void close() {
    if (_store != null) {
      _store!.close();
      _store = null;
      _teamBox = null;
      _teamMemberBox = null;
      _matchBox = null;
      print('🔒 ObjectBox store closed');
    }
  }

  /// Clear all data from database (use carefully!)
  static void clearAllData() {
    if (_teamBox != null && _teamMemberBox != null && _matchBox != null) {
      _teamBox!.removeAll();
      _teamMemberBox!.removeAll();
      _matchBox!.removeAll();
      print('🗑️ All data cleared from ObjectBox');
    }
  }

  /// Get database statistics
  static Map<String, int> getStats() {
    if (_teamBox == null || _teamMemberBox == null || _matchBox == null) {
      return {'teams': 0, 'teamMembers': 0, 'matches': 0};
    }
    
    return {
      'teams': _teamBox!.count(),
      'teamMembers': _teamMemberBox!.count(),
      'matches': _matchBox!.count(),
    };
  }

  /// Print database statistics
  static void printStats() {
    final stats = getStats();
    print('📊 Database Statistics:');
    print('   Teams: ${stats['teams']}');
    print('   Team Members: ${stats['teamMembers']}');
    print('   Matches: ${stats['matches']}');
  }

  /// Verify database integrity
  static bool verifyIntegrity() {
    try {
      if (!isInitialized) return false;
      
      // Try basic operations
      final teamCount = _teamBox!.count();
      final memberCount = _teamMemberBox!.count();
      final matchCount = _matchBox!.count();
      
      print('✅ Database integrity check passed');
      print('   Teams: $teamCount, Members: $memberCount, Matches: $matchCount');
      return true;
    } catch (e) {
      print('❌ Database integrity check failed: $e');
      return false;
    }
  }

  /// Clear only match data
  static void clearMatchData() {
    if (_matchBox != null) {
      _matchBox!.removeAll();
      print('🗑️ Match data cleared from ObjectBox');
    }
  }

  /// Clear only team member data
  static void clearTeamMemberData() {
    if (_teamMemberBox != null) {
      _teamMemberBox!.removeAll();
      print('🗑️ Team member data cleared from ObjectBox');
    }
  }

  /// Clear only team data
  static void clearTeamData() {
    if (_teamBox != null) {
      _teamBox!.removeAll();
      print('🗑️ Team data cleared from ObjectBox');
    }
  }

  /// Get detailed statistics
  static Map<String, dynamic> getDetailedStats() {
    if (!isInitialized) {
      return {
        'initialized': false,
        'teams': 0,
        'teamMembers': 0,
        'matches': 0,
      };
    }

    return {
      'initialized': true,
      'teams': _teamBox!.count(),
      'teamMembers': _teamMemberBox!.count(),
      'matches': _matchBox!.count(),
      'storePath': _store!.directoryPath,
    };
  }
}