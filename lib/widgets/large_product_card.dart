import 'package:flutter/material.dart';

class LargeProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const LargeProductCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  }) : super(key: key);

  Widget _getProductImage(String title) {
    IconData iconData;
    Color iconColor = Colors.black87;
    
    switch (title.toLowerCase()) {
      case 'apple iphone max':
        iconData = Icons.phone_iphone;
        break;
      case 'apple vision pro':
        iconData = Icons.vrpano;
        iconColor = Colors.black;
        break;
      case 'macbook air':
        iconData = Icons.laptop_mac;
        iconColor = Colors.black87;
        break;
      case 'ipad pro':
        iconData = Icons.tablet_mac;
        iconColor = Colors.black87;
        break;
      default:
        iconData = Icons.devices;
        break;
    }
    
    return Icon(
      iconData,
      size: 80,
      color: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 220,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
        ],
        border: isDark 
          ? Border.all(color: Colors.grey[800]!, width: 1)
          : null,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor,
                    backgroundColor,
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _getProductImage(title),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Text(
                        'Shop now',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}