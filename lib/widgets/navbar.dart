import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../screens/category_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

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
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
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
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _showCategoriesBottomSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<List<Category>>(
        future: _apiService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 300,
              child: Center(child: Text('Failed to load categories')),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SizedBox(
              height: 300,
              child: Center(child: Text('No categories found')),
            );
          }
          final categories = snapshot.data!;
          return _buildCategoriesSheet(categories);
        },
      ),
    );
  }

  Widget _buildCategoriesSheet(List<Category> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              children: categories.map((category) {
                return _buildCategoryItem(category, isDark);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category, bool isDark) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await _navigateToCategory(category);
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
            BoxShadow(color: Color(0xFF5A5CE6), blurRadius: 1),
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
                  Icons.category,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                category.name,
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

  Future<void> _navigateToCategory(Category category) async {
    try {
      final products = await _apiService.getProductsByCategory(category.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryScreen(
            categoryName: category.name,
            categoryId: category.id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(),
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
        actions: widget.additionalActions,
      ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        selectedItemColor: Color(0xFF5A5CE6),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        elevation: 0,
        items: const [
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
    );
  }
}