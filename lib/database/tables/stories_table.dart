import 'package:drift/drift.dart';

/// Drift table definition for offline-first Stories.
@DataClassName('StoryEntity')
class StoriesTable extends Table {
  /// The unique UUID of the story.
  TextColumn get id => text()();

  /// The title of the story.
  TextColumn get title => text()();

  /// The background hex color for the cover.
  TextColumn get coverColor => text()();

  /// The emoji displayed on the cover.
  TextColumn get coverEmoji => text()();

  /// Indicates if the story is favorited by the local user.
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// When the story was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the story was last modified.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
