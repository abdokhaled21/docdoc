import 'package:flutter/material.dart';
import '../../../home/data/home_repository.dart';
import '../../domain/review.dart';
import '../../../../core/storage/local_storage.dart';

class ReviewsController extends ChangeNotifier {
  final _repo = HomeRepository.instance;
  final _storage = LocalStorage.instance;

  int? _doctorId;
  bool _loading = false;
  String? _error;
  List<Review> _reviews = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Review> get reviews => _reviews;

  Future<void> initForDoctor(int doctorId) async {
    if (_doctorId == doctorId && _reviews.isNotEmpty) return;
    _doctorId = doctorId;
    await _load();
  }

  Future<void> _load() async {
    if (_doctorId == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _storage.getReviewsRaw(_doctorId!);
      _reviews = Review.decodeList(raw);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> submit({required int rating, required String content}) async {
    if (_doctorId == null) return;
    if (rating < 1 || rating > 5) return;
    _loading = true;
    notifyListeners();
    try {
      final profile = await _repo.fetchProfile();
      final r = Review(
        authorName: profile.name.isEmpty ? 'User' : profile.name,
        rating: rating,
        content: content.trim(),
        createdAt: DateTime.now(),
      );
      final updated = [..._reviews, r];
      await _storage.setReviewsRaw(_doctorId!, Review.encodeList(updated));
      _reviews = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
