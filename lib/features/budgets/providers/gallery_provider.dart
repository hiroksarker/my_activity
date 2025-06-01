import 'package:flutter/material.dart';
import '../models/gallery_photo.dart';
import '../db/budgets_database.dart';

class GalleryProvider with ChangeNotifier {
  List<GalleryPhoto> _photos = [];

  List<GalleryPhoto> get photos => _photos;

  Future<void> loadGallery(int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    final maps = await db.query('gallery_photos', where: 'tripId = ?', whereArgs: [tripId]);
    _photos = maps.map((map) => GalleryPhoto.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addGalleryPhoto(GalleryPhoto photo) async {
    final db = await BudgetsDatabase.instance.database;
    await db.insert('gallery_photos', photo.toMap());
    await loadGallery(photo.tripId);
  }

  Future<void> deleteGalleryPhoto(int id, int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    await db.delete('gallery_photos', where: 'id = ?', whereArgs: [id]);
    await loadGallery(tripId);
  }
}
