import '../models/story.dart';

void main() {
  final story1 = Story(
    id: '1',
    title: 'The Dragon and the Moon',
    coverColor: '#FFD6E8',
    coverEmoji: '🐉',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    pages: [
      StoryPage(
          id: 'p1', text: 'Once upon a time, a tiny dragon loved the moon.'),
      StoryPage(id: 'p2', text: 'One night, the moon invited him to the sky.'),
      StoryPage(id: 'p3', text: 'They became best friends among the stars.'),
    ],
  );

  final story2 = Story(
    id: '2',
    title: 'Bunny in Space',
    coverColor: '#C0E5FF',
    coverEmoji: '🐰',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    pages: [
      StoryPage(id: 'p1', text: 'Bella the Bunny dreamed of space.'),
      StoryPage(id: 'p2', text: 'She built a rocket from carrots.'),
      StoryPage(id: 'p3', text: 'She flew to the moon and smiled.'),
    ],
  );

  // Map<int, Story>
  Map<int, Story> stories = {
    1: story1,
    2: story2,
  };

  // for loop + if/else
  for (var entry in stories.entries) {
    print('Story ID: ${entry.key}');
    print('Title: ${entry.value.title}');
    print('Page Count: ${entry.value.pages.length}');

    for (int i = 0; i < entry.value.pages.length; i++) {
      final page = entry.value.pages[i];

      if (page.text.isNotEmpty) {
        print('Page ${i + 1}: ${page.text}');
      } else {
        print('Page ${i + 1}: This page has no text.');
      }
    }

    print('----------------------');
  }

  // Error handling: page number does not exist
  int requestedPageNumber = 10;
  Story selectedStory = stories[1]!;

  if (requestedPageNumber > 0 &&
      requestedPageNumber <= selectedStory.pages.length) {
    print(selectedStory.pages[requestedPageNumber - 1].text);
  } else {
    print('Error: Page number $requestedPageNumber does not exist.');
  }
}
