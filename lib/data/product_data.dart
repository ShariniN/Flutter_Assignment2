import 'package:flutter/material.dart';
import '/models/product.dart';

class ProductDetails {
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> variantOptions;
  final List<Map<String, dynamic>> features;
  final List<Map<String, String>> specifications;
  final String description;

  ProductDetails({
    required this.colors,
    required this.variantOptions,
    required this.features,
    required this.specifications,
    required this.description,
  });
}

class ProductData {
  static Map<String, ImageProvider>? _cachedImages;
  
  static Future<Map<String, ImageProvider>> get images async {
    _cachedImages ??= await _loadImages();
    return _cachedImages!;
  }

  static Future<Map<String, ImageProvider>> _loadImages() async {
    final Map<String, ImageProvider> imageCache = {};
    
    final allProducts = getAllProducts();
    final uniqueImageUrls = allProducts.map((product) => product.imageUrl).toSet();
    
    for (String imageUrl in uniqueImageUrls) {
      try {
        final imageProvider = AssetImage(imageUrl);
        imageCache[imageUrl] = imageProvider;
      } catch (e) {
        imageCache[imageUrl] = const AssetImage('images/placeholder.png');
      }
    }
    
    return imageCache;
  }

  static Future<ImageProvider> getCachedImage(String imageUrl) async {
    final imageCache = await images;
    return imageCache[imageUrl] ?? const AssetImage('images/placeholder.png');
  }

  static void clearImageCache() {
    _cachedImages = null;
  }

  static Future<void> refreshImageCache() async {
    _cachedImages = null;
    await images;
  }

  static final Map<String, List<Product>> _productsByCategory = {
    'phone': [
      Product(
        id: 'phone_1',
        title: 'Apple iPhone 14 Pro',
        subtitle: '512GB Gold',
        price: 429000, 
        brand: 'Apple',
        imageUrl: 'images/Apple i phone 14 Pro 128GB Space Black--1693477546.jpg',
        color: Colors.grey[100],
        category: 'phone',
        rating: 4.8,
      ),
      Product(
        id: 'phone_2',
        title: 'Apple iPhone 11',
        subtitle: '128GB White',
        price: 153000,
        brand: 'Apple',
        imageUrl: 'images/apple-iphone-15-128gb-latest-price-in-sri-lanka-3.jpg',
        color: Colors.grey[200],
        category: 'phone',
        rating: 4.5,
      ),
      Product(
        id: 'phone_3',
        title: 'Samsung Galaxy S23',
        subtitle: '256GB Black',
        price: 269700,
        brand: 'Samsung',
        imageUrl: 'images/Galaxy S25.png',
        color: Colors.grey[100],
        category: 'phone',
        rating: 4.6,
      ),
      Product(
        id: 'phone_4',
        title: 'Google Pixel 7',
        subtitle: '128GB Blue',
        price: 179700,
        brand: 'Google',
        imageUrl: 'images/google pixel 5.jpg',
        color: Colors.grey[200],
        category: 'phone',
        rating: 4.4,
      ),
      Product(
        id: 'phone_5',
        title: 'Xiaomi Mi 13',
        subtitle: '256GB Green',
        price: 209700,
        brand: 'Xiaomi',
        imageUrl: 'images/xiaomi 14.jpg',
        color: Colors.grey[100],
        category: 'phone',
        rating: 4.3,
      ),
    ],
    'laptop': [
      Product(
        id: 'laptop_1',
        title: 'MacBook Pro 14"',
        subtitle: 'M2 Pro, 512GB',
        price: 749700,
        brand: 'Apple',
        imageUrl: 'images/macbook air m3.jpg',
        color: Colors.grey[100],
        category: 'laptop',
        rating: 4.9,
      ),
      Product(
        id: 'laptop_2',
        title: 'Dell XPS 13',
        subtitle: 'Intel i7, 16GB RAM',
        price: 389700,
        brand: 'Dell',
        imageUrl: 'images/dell xps 15.jpg',
        color: Colors.grey[200],
        category: 'laptop',
        rating: 4.5,
      ),
      Product(
        id: 'laptop_3',
        title: 'HP Spectre x360',
        subtitle: '13.3", 512GB SSD',
        price: 359700,
        brand: 'HP',
        imageUrl: 'images/hp-spectre.jpg',
        color: Colors.grey[100],
        category: 'laptop',
        rating: 4.4,
      ),
      Product(
        id: 'laptop_4',
        title: 'Lenovo ThinkPad X1',
        subtitle: 'Carbon Gen 10',
        price: 569700,
        brand: 'Lenovo',
        imageUrl: 'images/lenovo-thinkpad.jpg',
        color: Colors.grey[200],
        category: 'laptop',
        rating: 4.6,
      ),
    ],
    'audio': [
      Product(
        id: 'audio_1',
        title: 'AirPods Pro 2',
        subtitle: 'USB-C, Noise Cancelling',
        price: 74700,
        brand: 'Apple',
        imageUrl: 'images/Apple-AirPods-Pro-2.png',
        color: Colors.grey[100],
        category: 'audio',
        rating: 4.7,
      ),
      Product(
        id: 'audio_2',
        title: 'Sony WH-1000XM4',
        subtitle: 'Wireless Noise Cancelling',
        price: 104700,
        brand: 'Sony',
        imageUrl: 'images/SONY-WH-1000XM5-1.jpg',
        color: Colors.grey[200],
        category: 'audio',
        rating: 4.8,
      ),
      Product(
        id: 'audio_3',
        title: 'Bose QuietComfort',
        subtitle: 'Bluetooth Headphones',
        price: 98700,
        brand: 'Bose',
        imageUrl: 'images/Bose-QuietComfort-Ultra-Headphones-4.jpg',
        color: Colors.grey[100],
        category: 'audio',
        rating: 4.6,
      ),
      Product(
        id: 'audio_4',
        title: 'JBL Flip 6',
        subtitle: 'Portable Speaker',
        price: 38700,
        brand: 'JBL',
        imageUrl: 'images/jbl-flip-6.jpeg',
        color: Colors.grey[200],
        category: 'audio',
        rating: 4.3,
      ),
    ],
    'wearables': [
      Product(
        id: 'wearable_1',
        title: 'Apple Watch Series 9',
        subtitle: '45mm GPS + Cellular',
        price: 158700,
        brand: 'Apple',
        imageUrl: 'images/Apple-Watch-Ultra-2-49mm-Titanium-GPS-Cellular-1.jpg',
        color: Colors.grey[100],
        category: 'wearables',
        rating: 4.8,
      ),
      Product(
        id: 'wearable_2',
        title: 'Samsung Galaxy Watch 6',
        subtitle: '44mm Bluetooth',
        price: 98700,
        brand: 'Samsung',
        imageUrl: 'images/watch 6.jpg',
        color: Colors.grey[200],
        category: 'wearables',
        rating: 4.5,
      ),
      Product(
        id: 'wearable_3',
        title: 'Fitbit Versa 4',
        subtitle: 'Health & Fitness',
        price: 59700,
        brand: 'Fitbit',
        imageUrl: 'images/fitbit sense 2.jpg',
        color: Colors.grey[100],
        category: 'wearables',
        rating: 4.2,
      ),
      Product(
        id: 'wearable_4',
        title: 'Garmin Venu 3',
        subtitle: 'GPS Smartwatch',
        price: 134700,
        brand: 'Garmin',
        imageUrl: 'images/venu 3.jpg',
        color: Colors.grey[200],
        category: 'wearables',
        rating: 4.6,
      ),
    ],
    'accessories': [
      Product(
        id: 'accessory_1',
        title: 'USB-C to Lightning Cable',
        subtitle: '2m Braided',
        price: 8700,
        brand: 'Apple',
        imageUrl: 'images/usb c charger.jpg',
        color: Colors.grey[100],
        category: 'accessories',
        rating: 4.3,
      ),
      Product(
        id: 'accessory_2',
        title: 'Wireless Charging Pad',
        subtitle: '15W Fast Charging',
        price: 14700,
        brand: 'Belkin',
        imageUrl: 'images/wireless-charging.jpg',
        color: Colors.grey[200],
        category: 'accessories',
        rating: 4.4,
      ),
      Product(
        id: 'accessory_3',
        title: 'Phone Case Clear',
        subtitle: 'Drop Protection',
        price: 5700,
        brand: 'OtterBox',
        imageUrl: 'images/clear-phonecase.jpg',
        color: Colors.grey[100],
        category: 'accessories',
        rating: 4.5,
      ),
      Product(
        id: 'accessory_4',
        title: 'Portable Power Bank',
        subtitle: '10000mAh USB-C',
        price: 11700,
        brand: 'Anker',
        imageUrl: 'images/powerbank.jpg',
        color: Colors.grey[200],
        category: 'accessories',
        rating: 4.6,
      ),
    ],
  };

  static final Map<String, ProductDetails> _productDetailsByCategory = {
    'phone': ProductDetails(
      colors: [
        {'name': 'Space Gray', 'color': const Color(0xFF2C2C2C)},
        {'name': 'Silver', 'color': const Color(0xFFC0C0C0)},
        {'name': 'Gold', 'color': const Color(0xFFD4AF37)},
        {'name': 'Deep Purple', 'color': const Color(0xFF5A4B8C)},
      ],
      variantOptions: [
        {'size': '128GB', 'priceOffset': 0},
        {'size': '256GB', 'priceOffset': 30000},
        {'size': '512GB', 'priceOffset': 90000},
        {'size': '1TB', 'priceOffset': 150000},
      ],
      features: [
        {'icon': Icons.smartphone, 'title': 'Display', 'description': '6.1-inch Super Retina XDR'},
        {'icon': Icons.camera_alt, 'title': 'Camera', 'description': '48MP Main Camera System'},
        {'icon': Icons.memory, 'title': 'Chip', 'description': 'A16 Bionic chip'},
        {'icon': Icons.battery_full, 'title': 'Battery', 'description': 'All-day battery life'},
      ],
      specifications: [
        {'title': 'Display Size', 'value': '6.1 inches'},
        {'title': 'Operating System', 'value': 'iOS 16'},
        {'title': 'Connectivity', 'value': '5G, Wi-Fi 6, Bluetooth 5.3'},
        {'title': 'Water Resistance', 'value': 'IP68'},
      ],
      description: 'Experience the ultimate smartphone with advanced camera technology, powerful performance, and innovative features designed to enhance your daily life.',
    ),
    'laptop': ProductDetails(
      colors: [
        {'name': 'Space Gray', 'color': const Color(0xFF2C2C2C)},
        {'name': 'Silver', 'color': const Color(0xFFC0C0C0)},
        {'name': 'Gold', 'color': const Color(0xFFD4AF37)},
      ],
      variantOptions: [
        {'size': '128GB', 'priceOffset': 0},
        {'size': '256GB', 'priceOffset': 30000},
        {'size': '512GB', 'priceOffset': 90000},
        {'size': '1TB', 'priceOffset': 150000},
      ],
      features: [
        {'icon': Icons.computer, 'title': 'Display', 'description': '13.3-inch Retina Display'},
        {'icon': Icons.memory, 'title': 'Processor', 'description': 'M2 Chip with 8-core CPU'},
        {'icon': Icons.storage, 'title': 'Memory', 'description': '8GB Unified Memory'},
        {'icon': Icons.battery_charging_full, 'title': 'Battery', 'description': 'Up to 18 hours'},
      ],
      specifications: [
        {'title': 'Screen Size', 'value': '13.3 inches'},
        {'title': 'Operating System', 'value': 'macOS'},
        {'title': 'RAM', 'value': '8GB'},
        {'title': 'Ports', 'value': '2x Thunderbolt, MagSafe 3'},
      ],
      description: 'Powerful performance meets stunning design. Built for productivity, creativity, and everything in between with industry-leading battery life.',
    ),
    'audio': ProductDetails(
      colors: [
        {'name': 'Black', 'color': Colors.black},
        {'name': 'White', 'color': Colors.white},
        {'name': 'Blue', 'color': Colors.blue},
      ],
      variantOptions: [
        {'size': 'Standard', 'priceOffset': 0},
        {'size': 'Premium', 'priceOffset': 15000},
      ],
      features: [
        {'icon': Icons.headphones, 'title': 'Audio', 'description': 'High-fidelity sound'},
        {'icon': Icons.bluetooth, 'title': 'Connectivity', 'description': 'Bluetooth 5.0'},
        {'icon': Icons.battery_std, 'title': 'Battery', 'description': 'Up to 30 hours playback'},
        {'icon': Icons.noise_control_off, 'title': 'Noise Control', 'description': 'Active Noise Cancellation'},
      ],
      specifications: [
        {'title': 'Type', 'value': 'Over-ear/In-ear'},
        {'title': 'Connectivity', 'value': 'Bluetooth 5.0'},
        {'title': 'Battery Life', 'value': 'Up to 30 hours'},
        {'title': 'Noise Cancellation', 'value': 'Active'},
      ],
      description: 'Immerse yourself in exceptional sound quality with advanced audio technology and premium comfort for extended listening sessions.',
    ),
    'wearables': ProductDetails(
      colors: [
        {'name': 'Midnight', 'color': Colors.black},
        {'name': 'Starlight', 'color': const Color(0xFFF5F5DC)},
        {'name': 'Product Red', 'color': Colors.red},
      ],
      variantOptions: [
        {'size': 'Small', 'priceOffset': 0},
        {'size': 'Large', 'priceOffset': 9000},
      ],
      features: [
        {'icon': Icons.watch, 'title': 'Display', 'description': 'Always-On Retina Display'},
        {'icon': Icons.favorite, 'title': 'Health', 'description': 'Advanced health monitoring'},
        {'icon': Icons.fitness_center, 'title': 'Fitness', 'description': 'Built-in GPS'},
        {'icon': Icons.water_drop, 'title': 'Water Resistant', 'description': 'WR50 water resistance'},
      ],
      specifications: [
        {'title': 'Display', 'value': 'OLED Always-On'},
        {'title': 'GPS', 'value': 'Built-in'},
        {'title': 'Water Resistance', 'value': 'WR50'},
        {'title': 'Compatibility', 'value': 'iOS/Android'},
      ],
      description: 'Your ultimate health and fitness companion. Track your workouts, monitor your health, and stay connected throughout your day.',
    ),
    'accessories': ProductDetails(
      colors: [
        {'name': 'Default', 'color': Colors.grey},
      ],
      variantOptions: [
        {'size': 'Standard', 'priceOffset': 0},
      ],
      features: [
        {'icon': Icons.info, 'title': 'Quality', 'description': 'Premium build quality'},
        {'icon': Icons.verified, 'title': 'Warranty', 'description': '1-year limited warranty'},
      ],
      specifications: [
        {'title': 'Material', 'value': 'Premium Quality'},
        {'title': 'Compatibility', 'value': 'Universal'},
      ],
      description: 'Premium quality accessory designed to enhance your device experience with reliable performance and elegant design.',
    ),
  };

  static List<Product> getProductsByCategory(String category) {
    return _productsByCategory[category] ?? [];
  }

  static List<Product> getAllProducts() {
    List<Product> allProducts = [];
    for (var products in _productsByCategory.values) {
      allProducts.addAll(products);
    }
    return allProducts;
  }

  static ProductDetails? getProductDetailsByCategory(String category) {
    return _productDetailsByCategory[category];
  }

  static List<Map<String, dynamic>> getColorsByCategory(String category) {
    return _productDetailsByCategory[category]?.colors ?? [
      {'name': 'Default', 'color': Colors.grey},
    ];
  }

  static List<Map<String, dynamic>> getVariantOptionsByCategory(String category, double basePrice) {
    final details = _productDetailsByCategory[category];
    if (details == null) return [{'size': 'Standard', 'price': basePrice}];
    
    return details.variantOptions.map((option) => {
      'size': option['size'],
      'price': basePrice + option['priceOffset'],
    }).toList();
  }

  static List<Map<String, dynamic>> getFeaturesByCategory(String category) {
    return _productDetailsByCategory[category]?.features ?? [
      {'icon': Icons.info, 'title': 'Quality', 'description': 'Premium build quality'},
      {'icon': Icons.verified, 'title': 'Warranty', 'description': '1-year limited warranty'},
    ];
  }

  static List<Map<String, String>> getSpecificationsByCategory(String category, Product product, String selectedColor) {
    final details = _productDetailsByCategory[category];
    List<Map<String, String>> specs = [
      {'title': 'Brand', 'value': product.brand},
    ];
    
    if (details != null) {
      specs.addAll(details.specifications);
    }
    
    if (selectedColor != 'Default') {
      specs.add({'title': 'Color', 'value': selectedColor});
    }
    
    return specs;
  }

  static String getDescriptionByCategory(String category) {
    return _productDetailsByCategory[category]?.description ?? 
           'Premium quality product designed to enhance your experience with reliable performance and elegant design.';
  }

  static List<String> getBrandsByCategory(String category) {
    final products = getProductsByCategory(category);
    final brands = products.map((product) => product.brand).toSet().toList();
    brands.sort();
    return brands;
  }

  static Map<String, double> getPriceRangeByCategory(String category) {
    final products = getProductsByCategory(category);
    
    final prices = products.map((product) => product.price).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }

  static Map<String, String> getCategoryDisplayNames() {
    return {
      'phone': 'Smartphones',
      'laptop': 'Laptops',
      'audio': 'Audio',
      'wearables': 'Wearables',
      'accessories': 'Accessories',
    };
  }

  static Map<String, IconData> getCategoryIcons() {
    return {
      'phone': Icons.smartphone,
      'laptop': Icons.laptop,
      'audio': Icons.headphones,
      'wearables': Icons.watch,
      'accessories': Icons.cable,
    };
  }
}