import 'package:flutter/material.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> with TickerProviderStateMixin {
  late AnimationController _slideController;
  
  List<AlertItem> alerts = [
    AlertItem(
      title: 'Spring turf open - flat 20% off today!',
      time: '2 mins ago',
      type: AlertType.success,
      isRead: false,
    ),
    AlertItem(
      title: 'Special offer!',
      subtitle: 'Book a nearby turf and save ₹100.',
      time: '10 mins ago',
      type: AlertType.neutral,
      isRead: false,
    ),
    AlertItem(
      title: 'Your pitch awaits!',
      subtitle: 'and it\'s cheaper today',
      time: '15 mins ago',
      type: AlertType.neutral,
      isRead: false,
    ),
    AlertItem(
      title: 'Drop shot deals!',
      subtitle: 'Book badminton turf now & save',
      time: '20 mins ago',
      type: AlertType.neutral,
      isRead: false,
    ),
    AlertItem(
      title: 'Good news!',
      subtitle: 'A nearby turf is ready for play.',
      time: '25 mins ago',
      type: AlertType.neutral,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _markAsRead(int index) {
    setState(() {
      alerts[index].isRead = true;
    });
  }

  void _deleteAlert(int index) {
    setState(() {
      alerts.removeAt(index);
    });
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
              // Header
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
                          icon: const Icon(Icons.notifications, color: Colors.white, size: 24),
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

              // Alerts Header with full width and increased font size
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity, // Full width
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF00BCD4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF00BCD4),
                        size: 26,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Alert !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Increased font size
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Alerts List with background
              Expanded(
                child: Stack(
                  children: [
                    // Background image with curved corners
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/stumps.jpg'),
                            fit: BoxFit.cover,
                            opacity: 0.8,
                          ),
                        ),
                      ),
                    ),
                    
                    // Alerts ListView
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _slideController,
                                curve: Interval(
                                  index * 0.1,
                                  (index * 0.1) + 0.5,
                                  curve: Curves.easeOut,
                                ),
                              )),
                              child: _buildAlertCard(alerts[index], index),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertItem alert, int index) {
    return Dismissible(
      key: Key(alert.title + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteAlert(index);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () => _markAsRead(index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            // Removed the colored border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Megaphone Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/megaphone.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Alert Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        color: alert.isRead 
                          ? Colors.white60
                          : Colors.white,
                        fontSize: 15,
                        fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                    if (alert.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        alert.subtitle!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      alert.time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (!alert.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00BCD4),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AlertType {
  success,
  warning,
  error,
  neutral,
}

class AlertItem {
  final String title;
  final String? subtitle;
  final String time;
  final AlertType type;
  bool isRead;

  AlertItem({
    required this.title,
    this.subtitle,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}