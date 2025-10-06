import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReviewsDatabase {
  static final ReviewsDatabase _instance = ReviewsDatabase._internal();
  factory ReviewsDatabase() => _instance;

  static Database? _db;

  ReviewsDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reviews.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        user_name TEXT,
        rating INTEGER,
        comment TEXT,
        image_path TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Insert a new review
  Future<void> insertReview(Map<String, dynamic> review) async {
    final db = await database;
    await db.insert('reviews', review);
  }

  // Get all reviews for a product
  Future<List<Map<String, dynamic>>> getReviews(int productId) async {
    final db = await database;
    return await db.query(
      'reviews',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'timestamp DESC',
    );
  }

  // Delete a review
  Future<void> deleteReview(int id) async {
    final db = await database;
    await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }
}
