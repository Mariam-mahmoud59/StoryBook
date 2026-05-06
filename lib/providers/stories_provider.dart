import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';

class StoriesProvider extends ChangeNotifier {
  static const Uuid _uuid = Uuid();
  final StoryRepository _storyRepository;
  List<Story> _stories = [];
  bool _isLoading = false;

  StoriesProvider({required StoryRepository storyRepository})
      : _storyRepository = storyRepository;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  List<Story> get favorites => _stories.where((s) => s.isFavorite).toList();

  Future<void> loadStories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      _stories = await _storyRepository.getStories();
      
      // If the local database is empty and a user is signed in, pull their stories from the cloud.
      if (_stories.isEmpty && user != null) {
        await _storyRepository.syncFromCloud(user.id);
        _stories = await _storyRepository.getStories();
      }

      // If still empty (new user with no cloud stories), generate sample stories
      if (_stories.isEmpty) {
        for (var story in sampleStories()) {
          await _storyRepository.createStory(story);
        }
        _stories = await _storyRepository.getStories();
      }
    } catch (_) {
      _stories = sampleStories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addStory({
    required String title,
    required String coverColor,
    required String coverEmoji,
    required List<StoryPage> pages,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final story = Story(
      id: id,
      title: title,
      coverColor: coverColor,
      coverEmoji: coverEmoji,
      pages: pages,
      createdAt: now,
      updatedAt: now,
    );

    await _storyRepository.createStory(story);
    _stories.insert(0, story);
    notifyListeners();
    return id;
  }

  Future<void> updateStory(String id, Story updated) async {
    final index = _stories.indexWhere((s) => s.id == id);
    if (index != -1) {
      final newStory = updated.copyWith(updatedAt: DateTime.now());
      await _storyRepository.updateStory(newStory);
      _stories[index] = newStory;
      notifyListeners();
    }
  }

  Future<void> deleteStory(String id) async {
    await _storyRepository.deleteStory(id);
    _stories.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _stories.indexWhere((s) => s.id == id);
    if (index != -1) {
      final isNowFavorite = !_stories[index].isFavorite;
      await _storyRepository.toggleFavorite(id, isNowFavorite);
      _stories[index] = _stories[index].copyWith(
        isFavorite: isNowFavorite,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> clearAllStories() async {
    final ids = _stories.map((s) => s.id).toList();
    for (final id in ids) {
      await _storyRepository.deleteStory(id);
    }
    _stories = [];
    notifyListeners();
  }

  /// Clears in-memory stories and wipes the local database.
  /// Must be called on sign-out to prevent data leaking to the next user.
  Future<void> clearLocalData() async {
    // 1. Wipe the local SQLite tables so the next user starts fresh
    await _storyRepository.clearLocalCacheOnly();
    // 2. Ensure the in-memory list is empty
    _stories = [];
    notifyListeners();
  }

  Story? getStory(String id) {
    try {
      return _stories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Persist all in-memory stories to local storage.
  /// Called when the app is paused to prevent data loss.
  Future<void> saveAllStories() async {
    for (final story in _stories) {
      try {
        await _storyRepository.updateStory(story);
      } catch (_) {
        // Ignore individual save failures – best-effort persistence.
      }
    }
  }
}
