import 'dart:convert';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/story.dart';
import '../services/auth_service.dart';

/// Repository handling local storage (Drift) and queuing sync tasks.
class StoryRepository {
  final AppDatabase _db;
  final SupabaseAuthService _authService;

  StoryRepository({
    required AppDatabase db,
    SupabaseAuthService? authService,
  })  : _db = db,
        _authService = authService ?? SupabaseAuthService();

  /// Reads all stories from the local SQLite database.
  Future<List<Story>> getStories() async {
    final storyEntities = await _db.select(_db.storiesTable).get();
    
    // To assemble we need the pages too
    final pagesByStory = <String, List<StoryPage>>{};
    final pageEntities = await _db.select(_db.storyPagesTable).get();
    
    for (var p in pageEntities) {
      if (!pagesByStory.containsKey(p.storyId)) {
        pagesByStory[p.storyId] = [];
      }
      pagesByStory[p.storyId]!.add(
        StoryPage(
          id: p.id,
          text: p.textContent,
          imageDescription: p.imageDescription,
          backgroundColor: p.backgroundColor,
        ),
      );
    }

    return storyEntities.map((s) {
      return Story(
        id: s.id,
        title: s.title,
        coverColor: s.coverColor,
        coverEmoji: s.coverEmoji,
        isFavorite: s.isFavorite,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        pages: pagesByStory[s.id] ?? [],
      );
    }).toList();
  }

  /// Saves a newly created story locally and triggers sync queue actions.
  Future<void> createStory(Story story) async {
    final user = _authService.getCurrentUser();
    
    await _db.transaction(() async {
      // 1. Insert local copy
      await _db.into(_db.storiesTable).insert(
        StoriesTableCompanion.insert(
          id: story.id,
          title: story.title,
          coverColor: story.coverColor,
          coverEmoji: story.coverEmoji,
          isFavorite: Value(story.isFavorite),
          createdAt: story.createdAt,
          updatedAt: story.updatedAt,
        ),
      );

      // 2. Queue story creation (author_id required by Supabase RLS)
      final storyJson = story.toJson();
      if (user != null) {
        storyJson['author_id'] = user.id;
      } else {
        // Without author_id, RLS will reject the insert
        throw StateError('Cannot sync story without authenticated user.');
      }
      
      await _db.into(_db.syncQueues).insert(
        SyncQueuesCompanion.insert(
          actionType: 'CREATE_STORY',
          payload: jsonEncode(storyJson),
        ),
      );

      // 3. Queue page creation
      for (var page in story.pages) {
        await _db.into(_db.storyPagesTable).insert(
          StoryPagesTableCompanion.insert(
            id: page.id,
            storyId: story.id,
            textContent: page.text,
            imageDescription: page.imageDescription,
            backgroundColor: page.backgroundColor,
          ),
        );

        final pageJson = page.toJson();
        pageJson['story_id'] = story.id;
        
        await _db.into(_db.syncQueues).insert(
          SyncQueuesCompanion.insert(
            actionType: 'CREATE_STORY_PAGE',
            payload: jsonEncode(pageJson),
          ),
        );
      }
    });
  }

  /// Updates an existing story and its pages.
  Future<void> updateStory(Story story) async {
    await _db.transaction(() async {
      // 1. Update local DB
      await _db.update(_db.storiesTable).replace(
        StoryEntity(
          id: story.id,
          title: story.title,
          coverColor: story.coverColor,
          coverEmoji: story.coverEmoji,
          isFavorite: story.isFavorite,
          createdAt: story.createdAt,
          updatedAt: story.updatedAt,
        ),
      );

      // 2. Queue story update (include author_id for RLS)
      final storyJson = story.toJson();
      final user = _authService.getCurrentUser();
      if (user != null) {
        storyJson['author_id'] = user.id;
      }
      await _db.into(_db.syncQueues).insert(
        SyncQueuesCompanion.insert(
          actionType: 'UPDATE_STORY',
          payload: jsonEncode(storyJson),
        ),
      );

      // We assume pages are just updated blindly for simplicity, 
      // or handled depending on the UI (assuming no pages added/deleted post-creation in this basic model)
      // Actually let's queue UPDATE_STORY_PAGE for each
      for (var page in story.pages) {
        await _db.update(_db.storyPagesTable).replace(
          StoryPageEntity(
            id: page.id,
            storyId: story.id,
            textContent: page.text,
            imageDescription: page.imageDescription,
            backgroundColor: page.backgroundColor,
          ),
        );

        final pageJson = page.toJson();
        pageJson['story_id'] = story.id;
        
        await _db.into(_db.syncQueues).insert(
          SyncQueuesCompanion.insert(
            actionType: 'UPDATE_STORY_PAGE',
            payload: jsonEncode(pageJson),
          ),
        );
      }
    });
  }

  /// Deletes a story. (Cascade handles local pages).
  Future<void> deleteStory(String storyId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.storiesTable)..where((t) => t.id.equals(storyId))).go();
      
      await _db.into(_db.syncQueues).insert(
        SyncQueuesCompanion.insert(
          actionType: 'DELETE_STORY',
          payload: jsonEncode({'id': storyId}),
        ),
      );
    });
  }

  /// Toggles favorite status.
  Future<void> toggleFavorite(String storyId, bool isFavorite) async {
    final user = _authService.getCurrentUser();
    
    await _db.transaction(() async {
      await (_db.update(_db.storiesTable)..where((t) => t.id.equals(storyId)))
          .write(StoriesTableCompanion(isFavorite: Value(isFavorite)));

      if (user != null) {
        await _db.into(_db.syncQueues).insert(
          SyncQueuesCompanion.insert(
            actionType: 'TOGGLE_FAVORITE',
            payload: jsonEncode({
              'story_id': storyId,
              'user_id': user.id,
              'is_favorite': isFavorite,
            }),
          ),
        );
      }
    });
  }

  /// Clears local database completely without queuing any sync deletions.
  /// Used when signing out to prevent data leaking to the next user.
  Future<void> clearLocalCacheOnly() async {
    await _db.transaction(() async {
      await _db.delete(_db.storyPagesTable).go();
      await _db.delete(_db.storiesTable).go();
      await _db.delete(_db.syncQueues).go();
    });
  }
}
