import 'package:assignment1/screens/profile.dart';
import 'package:assignment1/screens/electronics_store.dart';
import 'package:flutter/material.dart';
import '/screens/category_page.dart';
import '/screens/cart_screen.dart';
import '/data/product_data.dart';

class NavigationLayout extends StatefulWidget {
  final Widget body;
  final String title;
  final int currentIndex;
  final Function(int)? onTabChanged;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? additionalActions;

  const NavigationLayout({
    Key? key,
    required this.body,
    required this.title,
    this.currentIndex = 0,
    this.onTabChanged,
    this.showBackButton = false,
    this.onBackPressed,
    this.additionalActions,
  }) : super(key: key);

  @override
  State<NavigationLayout> createState() => _NavigationLayoutState();
}

class _NavigationLayoutState extends State<NavigationLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(NavigationLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index && index == 1) {
      _showCategoriesBottomSheet();
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (widget.onTabChanged != null) {
      widget.onTabChanged!(index);
    }

    switch (index) {
      case 0:
        _navigateToHome();
        break;
      case 1:
        _showCategoriesBottomSheet();
        break;
      case 2:
        _navigateToCart();
        break;
      case 3:
        _navigateToProfile();
        break;
    }
  }

  void _navigateToHome() {
    if (ModalRoute.of(context)?.settings.name != '/electronics_store') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ElectronicsStore()),
        (route) => false,
      );
    }
  }

  void _showCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoriesSheet(),
    );
  }

  Widget _buildCategoriesSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryNames = ProductData.getCategoryDisplayNames();
    final categoryIcons = ProductData.getCategoryIcons();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: categoryNames.entries.map((entry) {
                final categoryType = entry.key;
                final displayName = entry.value;
                final icon = categoryIcons[categoryType] ?? Icons.category;
                
                return _buildCategoryItem(
                  displayName, 
                  icon, 
                  isDark, 
                  categoryType
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, bool isDark, String categoryType) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _navigateToCategory(categoryType);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5A5CE6), Color(0xFF7C83FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF5A5CE6), 
              blurRadius: 1,
              
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5A5CE6), Color(0xFF7C83FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(String categoryType) {
    final products = ProductData.getProductsByCategory(categoryType);
    final displayName = ProductData.getCategoryDisplayNames()[categoryType] ?? 'Products';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          categoryType: categoryType,
          categoryName: displayName,
          products: products,
        ),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        title: Text(
          widget.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: widget.showBackButton,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _navigateToCart,
          ),
        ],
      ),
      body: widget.body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          selectedItemColor: Color(0xFF5A5CE6),
          unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}