import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'team.dart';
import 'objectbox.g.dart';

class ObjectBoxHelper {
  static Store? _store;
  static Box<Team>? _teamBox;

  static Future<void> init() async {
    if (_store != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _store = await openStore(directory: p.join(dir.path, 'objectbox'));
    _teamBox = _store!.box<Team>();
  }

  static Box<Team> get teamBox {
    if (_teamBox == null) {
      throw Exception('ObjectBox not initialized. Call init() first.');
    }
    return _teamBox!;
  }

  static void close() {
    _store?.close();
    _store = null;
    _teamBox = null;
  }
}