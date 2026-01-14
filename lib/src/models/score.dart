import 'package:TURF_TOWN_/src/models/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'objectbox_helper.dart';

@Entity()
class Score {
  @Id()
  int id;
  
  @Unique()
  String inningsId;
  
  int totalRuns;
  int wickets;
  int currentBall;
  double overs;
  double crr;
  double nrr;
  
  String strikeBatsmanId;
  String nonStrikeBatsmanId;
  String currentBowlerId;
  String nextBatsmanId;
  
  // Note: ObjectBox doesn't support List<String> directly
  // We'll store as comma-separated string
  String currentOverStr;
  
  Score({
    this.id = 0,
    required this.inningsId,
    this.totalRuns = 0,
    this.wickets = 0,
    this.currentBall = 0,
    this.overs = 0.0,
    this.crr = 0.0,
    this.nrr = 7.09,
    this.strikeBatsmanId = '',
    this.nonStrikeBatsmanId = '',
    this.currentBowlerId = '',
    this.nextBatsmanId = '',
    this.currentOverStr = '',
  });
  
  // Helper getters/setters for currentOver
  List<String> get currentOver {
    if (currentOverStr.isEmpty) return [];
    return currentOverStr.split(',');
  }
  
  set currentOver(List<String> value) {
    currentOverStr = value.join(',');
  }
  
  void save() {
    ObjectBoxHelper.scoreBox.put(this);
  }
  
  static Score? getByInningsId(String inningsId) {
    final query = ObjectBoxHelper.scoreBox
        .query(Score_.inningsId.equals(inningsId))
        .build();
    final score = query.findFirst();
    query.close();
    return score;
  }
  
  static Score create(String inningsId) {
    final score = Score(inningsId: inningsId);
    ObjectBoxHelper.scoreBox.put(score);
    return score;
  }
  
  void resetScore() {
    totalRuns = 0;
    wickets = 0;
    currentBall = 0;
    overs = 0.0;
    crr = 0.0;
    currentOverStr = '';
    save();
  }
}