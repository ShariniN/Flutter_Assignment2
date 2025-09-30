import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: ListView.builder(
        itemCount: _buildSections().length,
        itemBuilder: (context, index) {
          return _buildSections()[index];
        },
      ),
    );
  }

  List<Widget> _buildSections() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return [
      Container(
        width: double.infinity,
        color: isDark ? Colors.grey[900] : Colors.white,
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Person1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'person1@email.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Orders', '12', Icons.shopping_bag_outlined),
            Container(height: 40, width: 1, color: Colors.grey[400]),
            _buildStatItem('Wishlist', '8', Icons.favorite_outline),
            Container(height: 40, width: 1, color: Colors.grey[400]),
            _buildStatItem('Reviews', '5', Icons.star_outline),
          ],
        ),
      ),
      SizedBox(height: 20),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              subtitle: 'Track your purchases',
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.favorite_outline,
              title: 'Wishlist',
              subtitle: 'Your saved items',
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              subtitle: 'Manage delivery addresses',
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              subtitle: 'Cards and digital wallets',
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSwitchMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Get notified about orders',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildDivider(),
            _buildSwitchMenuItem(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help with your account',
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy terms',
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            "Sign Out",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ),
      ),
      SizedBox(height: 40),
    ];
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey[400]),
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Divider(
      height: 1,
      color: isDark ? Colors.grey[700] : Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Sign Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}