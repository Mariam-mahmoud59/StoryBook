import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';

class StoriesProvider extends ChangeNotifier {
  final StoryRepository _storyRepository;
  List<Story> _stories = [];

  StoriesProvider({required StoryRepository storyRepository})
      : _storyRepository = storyRepository;

  List<Story> get stories => _stories;
  List<Story> get favorites => _stories.where((s) => s.isFavorite).toList();

  Future<void> loadStories() async {
    try {
      _stories = await _storyRepository.getStories();
      if (_stories.isEmpty) {
        // If empty, perhaps load some sample stories
        for (var story in sampleStories()) {
          await _storyRepository.createStory(story);
        }
        _stories = await _storyRepository.getStories();
      }
    } catch (_) {
      _stories = sampleStories();
    }
    notifyListeners();
  }

  Future<String> addStory({
    required String title,
    required String coverColor,
    required String coverEmoji,
    required List<StoryPage> pages,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
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

  Story? getStory(String id) {
    try {
      return _stories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

