<<<<<<< HEAD
import 'package:TURF_TOWN_/src/Pages/Teams/InitialTeamPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Advanced extends StatelessWidget {
  const Advanced({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cricket Scorer',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF140088),
          secondary: Color(0xFF00BCD4),
        ),
      ),
      home: const MatchSettingsPage(),
    );
  }
}

class MatchSettingsPage extends StatefulWidget {
  const MatchSettingsPage({super.key});
=======
import 'package:flutter/material.dart';

class MatchSettingsPage extends StatefulWidget {
  final bool? currentAllowNoball;
  final bool? currentAllowWide;

  const MatchSettingsPage({
    super.key,
    this.currentAllowNoball,
    this.currentAllowWide,
  });
>>>>>>> recovered-20260202

  @override
  State<MatchSettingsPage> createState() => _MatchSettingsPageState();
}

class _MatchSettingsPageState extends State<MatchSettingsPage> {
<<<<<<< HEAD
  bool noBallEnabled = false;
  bool wideBallEnabled = false;

  final TextEditingController noBallController = TextEditingController();
  final TextEditingController wideBallController = TextEditingController();

  int get noBallRuns =>
      int.tryParse(noBallController.text.trim().isEmpty ? '0' : noBallController.text) ?? 0;
  int get wideBallRuns =>
      int.tryParse(wideBallController.text.trim().isEmpty ? '0' : wideBallController.text) ?? 0;

  @override
  void dispose() {
    noBallController.dispose();
    wideBallController.dispose();
    super.dispose();
=======
  bool allowNoball = true;
  bool allowWide = true;

  @override
  void initState() {
    super.initState();
    allowNoball = widget.currentAllowNoball ?? true;
    allowWide = widget.currentAllowWide ?? true;
  }

  void _saveSettings() {
    Navigator.pop(context, {
      'allowNoball': allowNoball,
      'allowWide': allowWide,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
>>>>>>> recovered-20260202
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 🔹 Gradient AppBar Header
          Container(
            width: double.infinity,
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF283593),
                  Color(0xFF1A237E),
                  Color(0xFF000000),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🏏 Left Title
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Cricket ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.09,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Scorer',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: w * 0.045,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
=======
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF283593),
        elevation: 0,
        title: const Text(
          'Match Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF283593), Color(0xFF1A237E), Color(0xFF000000)],
            stops: [0.0, 0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2026),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00C4FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.settings,
                            color: Color(0xFF00C4FF),
                            size: 24,
                          ),
                          SizedBox(width: w * 0.02),
                          const Text(
                            'Match Configuration',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: w * 0.04),
                      const Divider(color: Color(0xFF5C5C5E)),
                      SizedBox(height: w * 0.04),
                      const Text(
                        'Extra Deliveries',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: w * 0.03),
                      _buildSettingRow(
                        label: 'Allow No Ball',
                        description: 'Enable no-ball deliveries in this match',
                        value: allowNoball,
                        onChanged: (value) {
                          setState(() => allowNoball = value);
                        },
                        icon: Icons.sports_cricket,
                        w: w,
                      ),
                      SizedBox(height: w * 0.03),
                      _buildSettingRow(
                        label: 'Allow Wide',
                        description: 'Enable wide deliveries in this match',
                        value: allowWide,
                        onChanged: (value) {
                          setState(() => allowWide = value);
                        },
                        icon: Icons.straighten,
                        w: w,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w * 0.04),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF00C4FF),
                        size: 20,
                      ),
                      SizedBox(width: w * 0.02),
                      const Expanded(
                        child: Text(
                          'These settings will apply to the entire match',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: w * 0.06),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C4FF),
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.12,
                        vertical: w * 0.04,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 5,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Save Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
>>>>>>> recovered-20260202
                          ),
                        ),
                      ],
                    ),
                  ),
<<<<<<< HEAD

                  // 🎧 ⚙️ Right Icons
                  Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.white70, size: 26),
                      const SizedBox(width: 14),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚙️ Settings coming soon!"),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Main Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2026),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Match Settings",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔸 No Ball Card
                    _buildSettingsCard(
                      icon: Icons.sports_baseball,
                      title: "No Ball",
                      isActive: noBallEnabled,
                      onToggle: () =>
                          setState(() => noBallEnabled = !noBallEnabled),
                      child: noBallEnabled
                          ? _buildRunInputRow(
                        label: "No ball run",
                        icon: Icons.directions_run_rounded,
                        controller: noBallController,
                      )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // 🔸 Wide Ball Card
                    _buildSettingsCard(
                      icon: Icons.accessibility_new,
                      title: "Wide Ball",
                      isActive: wideBallEnabled,
                      onToggle: () =>
                          setState(() => wideBallEnabled = !wideBallEnabled),
                      child: wideBallEnabled
                          ? _buildRunInputRow(
                        label: "Wide ball run",
                        icon: Icons.directions_run_rounded,
                        controller: wideBallController,
                      )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 30),

                    // 🔹 Save Button (Gradient)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF140088), Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamPage()));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              content: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF140088), Colors.black],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "✅ Saved! No Ball: $noBallRuns | Wide Ball: $wideBallRuns",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          "Save Settings",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
=======
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String description,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required double w,
  }) {
    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value 
                  ? const Color(0xFF00C4FF).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFF00C4FF) : Colors.white70,
              size: 24,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00C4FF),
            activeTrackColor: const Color(0xFF00C4FF).withOpacity(0.5),
>>>>>>> recovered-20260202
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  // 🔹 Settings Card
  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Card(
      color: const Color(0xFF242830),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                  isActive ? const Color(0xFF140088) : Colors.white24,
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF140088),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isActive ? "ON" : "OFF",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isActive ? child : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Input Row (Persistent Controller)
  Widget _buildRunInputRow({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00BCD4)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: const InputDecoration(
              isDense: true,
              hintText: '',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF140088)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
=======
}
>>>>>>> recovered-20260202
