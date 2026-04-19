import 'package:drift/drift.dart';
import 'stories_table.dart';

/// Drift table definition for offline-first Story Pages.
@DataClassName('StoryPageEntity')
class StoryPagesTable extends Table {
  /// The unique UUID of the page.
  TextColumn get id => text()();

  /// Reference to the parent story. Cascade delete will remove pages if the story is deleted.
  TextColumn get storyId => text().references(StoriesTable, #id, onDelete: KeyAction.cascade)();

  /// The text content of this page.
  TextColumn get textContent => text()();

  /// Description to act as a prompt for image generation, or alt text.
  TextColumn get imageDescription => text()();

  /// The background hex color for this page.
  TextColumn get backgroundColor => text()();

  @override
  Set<Column> get primaryKey => {id};
}
