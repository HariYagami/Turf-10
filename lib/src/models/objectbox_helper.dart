
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'team.dart';
import 'team_member.dart';
import './objectbox.g.dart'; // Adjust path if objectbox.g.dart is in lib/ root

class ObjectBoxHelper {
  static Store? _store;
  static Box<Team>? _teamBox;
  static Box<TeamMember>? _teamMemberBox;

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
      
      print('✅ ObjectBox initialized successfully');
      print('📊 Database Stats:');
      print('   - Teams: ${_teamBox!.count()}');
      print('   - Team Members: ${_teamMemberBox!.count()}');
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
      print('🔒 ObjectBox store closed');
    }
  }

  /// Clear all data from database (use carefully!)
  static void clearAllData() {
    if (_teamBox != null && _teamMemberBox != null) {
      _teamBox!.removeAll();
      _teamMemberBox!.removeAll();
      print('🗑️ All data cleared from ObjectBox');
    }
  }

  /// Get database statistics
  static Map<String, int> getStats() {
    if (_teamBox == null || _teamMemberBox == null) {
      return {'teams': 0, 'teamMembers': 0};
    }
    
    return {
      'teams': _teamBox!.count(),
      'teamMembers': _teamMemberBox!.count(),
    };
  }

  /// Print database statistics
  static void printStats() {
    final stats = getStats();
    print('📊 Database Statistics:');
    print('   Teams: ${stats['teams']}');
    print('   Team Members: ${stats['teamMembers']}');
  }

  /// Verify database integrity
  static bool verifyIntegrity() {
    try {
      if (!isInitialized) return false;
      
      // Try basic operations
      final teamCount = _teamBox!.count();
      final memberCount = _teamMemberBox!.count();
      
      print('✅ Database integrity check passed');
      print('   Teams: $teamCount, Members: $memberCount');
      return true;
    } catch (e) {
      print('❌ Database integrity check failed: $e');
      return false;
    }
  }
}