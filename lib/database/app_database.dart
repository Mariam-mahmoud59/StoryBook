import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/sync_queue_table.dart';
import 'tables/stories_table.dart';
import 'tables/story_pages_table.dart';

part 'app_database.g.dart';

/// The central Drift database for the Storybook app.
///
/// Currently manages the [SyncQueues] table used by the offline-first
/// sync engine, [StoriesTable], and [StoryPagesTable].
@DriftDatabase(tables: [SyncQueues, StoriesTable, StoryPagesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Bump this version whenever the schema changes and provide a
  /// migration strategy in [migration].
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add new tracking columns to the sync_queues table without erasing existing data
        await m.addColumn(syncQueues, syncQueues.retryCount);
        await m.addColumn(syncQueues, syncQueues.lastAttemptAt);
        await m.addColumn(syncQueues, syncQueues.lastError);
      }
    },
  );

  /// Opens a persistent SQLite database stored in the app's documents
  /// directory.
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'storybook.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
