import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/story.dart';
import '../providers/stories_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';
import '../widgets/kid_button.dart';

enum _SaveStatus { idle, saving, saved }

class StoryEditorScreen extends StatefulWidget {
  final String? storyId;
  const StoryEditorScreen({super.key, this.storyId});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  static const Uuid _uuid = Uuid();
  static const List<String> _storySuggestions = [
    'Once upon a time...',
    'Suddenly...',
    'The hero discovered...',
    'A new friend appeared...',
    'Then something magical happened...',
    'They learned an important lesson...',
  ];
  bool get isNew => widget.storyId == null;

  late TextEditingController _titleController;
  late TextEditingController _storyTextController;
  late FocusNode _storyTextFocusNode;
  String _coverColor = '#FFD6E8';
  String _coverEmoji = '📖';
  List<StoryPage> _pages = [];
  int _activePage = 0;
  bool _showEmojiPicker = false;
  _SaveStatus _saveStatus = _SaveStatus.idle;
  String? _boundPageId;

  static const _coverColors = [
    '#FFD6E8',
    '#C0E5FF',
    '#C2F5E9',
    '#E5DEFF',
    '#FFF3CD',
    '#FFE0B2',
    '#F8D7DA',
    '#D1ECF1',
  ];

  static const _coverEmojis = [
    '📖',
    '🐉',
    '🦄',
    '🐰',
    '🧚',
    '🌟',
    '🦋',
    '🐬',
    '🌈',
    '🏰',
  ];

  String _generateId() => _uuid.v4();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'My New Story');
    _storyTextController = TextEditingController();
    _storyTextFocusNode = FocusNode();
    _pages = [StoryPage(id: _generateId(), backgroundColor: _coverColors[0])];
    _bindStoryTextToActivePage();

    if (!isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final story = context.read<StoriesProvider>().getStory(widget.storyId!);
        if (story != null) {
          setState(() {
            _titleController.text = story.title;
            _coverColor = story.coverColor;
            _coverEmoji = story.coverEmoji;
            _pages = story.pages
                .map((p) => StoryPage(
                      id: p.id,
                      text: p.text,
                      imageDescription: p.imageDescription,
                      backgroundColor: p.backgroundColor,
                    ))
                .toList();
            _bindStoryTextToActivePage();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyTextController.dispose();
    _storyTextFocusNode.dispose();
    super.dispose();
  }

  void _bindStoryTextToActivePage() {
    if (_pages.isEmpty) return;
    final page = _pages[_activePage];
    if (_boundPageId == page.id && _storyTextController.text == page.text) {
      return;
    }
    _boundPageId = page.id;
    _storyTextController.value = TextEditingValue(
      text: page.text,
      selection: TextSelection.collapsed(offset: page.text.length),
    );
  }

  void _insertSuggestion(String suggestion) {
    final text = _storyTextController.text;
    final selection = _storyTextController.selection;

    final hasValidSelection = selection.isValid &&
        selection.start >= 0 &&
        selection.end >= 0 &&
        selection.start <= text.length &&
        selection.end <= text.length;

    final start = hasValidSelection ? selection.start : text.length;
    final end = hasValidSelection ? selection.end : text.length;

    final needsSpaceBefore =
        start > 0 && !text.substring(0, start).endsWith(' ');
    final needsSpaceAfter =
        end < text.length && !text.substring(end).startsWith(' ');

    final insertText =
        '${needsSpaceBefore ? ' ' : ''}$suggestion${needsSpaceAfter ? ' ' : ''}';
    final newText = text.replaceRange(start, end, insertText);

    _storyTextController.text = newText;
    final newOffset = start + insertText.length;
    _storyTextController.selection = TextSelection.collapsed(offset: newOffset);

    _storyTextFocusNode.requestFocus();
    _updateActivePage('text', newText);
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  void _updateActivePage(String field, String value) {
    final p = _pages[_activePage];
    setState(() {
      _pages[_activePage] = StoryPage(
        id: p.id,
        text: field == 'text' ? value : p.text,
        imageDescription: field == 'image' ? value : p.imageDescription,
        backgroundColor: field == 'color' ? value : p.backgroundColor,
      );
    });
  }

  void _addPage() {
    HapticFeedback.mediumImpact();
    setState(() {
      _pages.add(StoryPage(
        id: _generateId(),
        backgroundColor: _coverColors[_pages.length % _coverColors.length],
      ));
      _activePage = _pages.length - 1;
      _bindStoryTextToActivePage();
    });
  }

  void _nextPage() {
    if (_activePage < _pages.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _activePage++;
        _bindStoryTextToActivePage();
      });
    }
  }

  void _previousPage() {
    if (_activePage > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _activePage--;
        _bindStoryTextToActivePage();
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;

    if (pickedFile != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _coverEmoji = pickedFile.path;
        _showEmojiPicker = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (pickedFile != null) {
        HapticFeedback.mediumImpact();
        _updateActivePage('image', pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _deletePage() {
    if (_pages.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A story needs at least one page.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete Page',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            'Are you sure you want to remove this page? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              setState(() {
                _pages.removeAt(_activePage);
                _activePage = (_activePage - 1).clamp(0, _pages.length - 1);
                _bindStoryTextToActivePage();
              });
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _save({bool andNavigate = true}) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your story a title!')),
      );
      return;
    }

    setState(() => _saveStatus = _SaveStatus.saving);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final provider = context.read<StoriesProvider>();

    if (isNew) {
      final id = await provider.addStory(
        title: _titleController.text.trim(),
        coverColor: _coverColor,
        coverEmoji: _coverEmoji,
        pages: _pages,
      );
      HapticFeedback.heavyImpact();
      setState(() => _saveStatus = _SaveStatus.saved);
      if (mounted && andNavigate) {
        Navigator.pushReplacementNamed(context, '/viewer/$id');
      }
    } else {
      final story = provider.getStory(widget.storyId!);
      if (story != null) {
        provider.updateStory(
          widget.storyId!,
          story.copyWith(
            title: _titleController.text.trim(),
            coverColor: _coverColor,
            coverEmoji: _coverEmoji,
            pages: _pages,
          ),
        );
      }
      HapticFeedback.heavyImpact();
      setState(() => _saveStatus = _SaveStatus.saved);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _saveStatus = _SaveStatus.idle);
    }
  }

  void _openPreview() {
    final id = widget.storyId ?? 'unsaved';
    if (isNew) {
      final provider = context.read<StoriesProvider>();
      provider
          .addStory(
        title: _titleController.text.trim().isEmpty
            ? 'My New Story'
            : _titleController.text.trim(),
        coverColor: _coverColor,
        coverEmoji: _coverEmoji,
        pages: _pages,
      )
          .then((savedId) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/preview/$savedId');
      });
    } else {
      _save(andNavigate: false).then((_) {
        if (mounted) {
          Navigator.pushNamed(context, '/preview/$id');
        }
      });
    }
  }

  Widget _saveIndicator() {
    switch (_saveStatus) {
      case _SaveStatus.saving:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.7)),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Saving...',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedForeground),
            ),
          ],
        );
      case _SaveStatus.saved:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 16, color: Color(0xFF4CAF50)),
            SizedBox(width: 6),
            Text(
              'Saved!',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50)),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9));
      case _SaveStatus.idle:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages.isNotEmpty ? _pages[_activePage] : null;

    return Scaffold(
      body: GradientBackground(
        variant: GradientVariant.mint,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    _iconBtn(
                      Icons.close_rounded,
                      // ignore: deprecated_member_use
                      Colors.white.withOpacity(0.8),
                      AppColors.foreground,
                      () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _titleController,
                            builder: (context, _) => Text(
                              isNew
                                  ? 'New Story'
                                  : (_titleController.text.isNotEmpty
                                      ? _titleController.text
                                      : 'Story Detail'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.foreground,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _saveIndicator(),
                        ],
                      ),
                    ),
                    _iconBtn(
                      Icons.delete_outline_rounded,
                      Colors.white.withOpacity(0.8),
                      AppColors.destructive,
                      () {
                        if (!isNew) {
                          context
                              .read<StoriesProvider>()
                              .deleteStory(widget.storyId!);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Cover Preview Section
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                  () => _showEmojiPicker = !_showEmojiPicker),
                              child: Hero(
                                tag: 'story_cover',
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: _hexToColor(_coverColor),
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _hexToColor(_coverColor)
                                            .withOpacity(0.4),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 0,
                                        offset: const Offset(0, 0),
                                        spreadRadius: -4,
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.6),
                                        width: 2),
                                  ),
                                  child: Center(
                                    child:
                                        _buildCoverEmoji(_coverEmoji, size: 72),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _showEmojiPicker = !_showEmojiPicker),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.easeOutBack),
                      ),

                      if (_showEmojiPicker) ...[
                        const SizedBox(height: 24),
                        _card(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _label('CHOOSE COVER'),
                                  GestureDetector(
                                    onTap: _pickCoverImage,
                                    child: const Text(
                                      'Upload Photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _coverEmojis.map((e) {
                                  final selected = _coverEmoji == e;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _coverEmoji = e;
                                        _showEmojiPicker = false;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(e,
                                            style:
                                                const TextStyle(fontSize: 28)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: -0.1),
                      ],

                      const SizedBox(height: 24),
                      _label('STORY COLOR'),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _coverColors.map((c) {
                            final selected = _coverColor == c;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _coverColor = c);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 42,
                                height: 42,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: _hexToColor(c),
                                  borderRadius: BorderRadius.circular(21),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    if (selected)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                  ],
                                ),
                                child: selected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 28),
                      _label('STORY TITLE'),
                      const SizedBox(height: 12),
                      _card(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: TextField(
                          controller: _titleController,
                          onChanged: (_) =>
                              setState(() => _saveStatus = _SaveStatus.idle),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.foreground,
                            letterSpacing: -0.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter story title...',
                            hintStyle: TextStyle(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500),
                            counterText: '',
                          ),
                          maxLength: 60,
                        ),
                      ),

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Story Pages',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.foreground,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addPage,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Page'),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _pages.length,
                        itemBuilder: (context, i) {
                          final page = _pages[i];
                          final active = _activePage == i;
                          final textSnippet = page.text.isEmpty
                              ? 'No text'
                              : (page.text.length > 30
                                  ? '${page.text.substring(0, 30)}...'
                                  : page.text);

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              if (!isNew) {
                                Navigator.pushNamed(
                                    context, '/viewer/${widget.storyId}',
                                    arguments: {'pageIndex': i});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Save story first to view pages')));
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _hexToColor(page.backgroundColor),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : Colors.white.withOpacity(0.5),
                                  width: active ? 2 : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.5),
                                    child: Text('${i + 1}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.foreground)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      textSnippet,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.foreground),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      if (currentPage != null)
                        _card(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _label(
                                      'PAGE ${_activePage + 1} OF ${_pages.length}'),
                                  GestureDetector(
                                    onTap: _deletePage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE5EA),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: AppColors.destructive),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _label('STORY TEXT'),
                              const SizedBox(height: 12),
                              _label('SUGGESTIONS'),
                              const SizedBox(height: 8),
                              _suggestionsBar(),
                              const SizedBox(height: 12),
                              _multilineField(
                                'What happens on this page?',
                                (v) => _updateActivePage('text', v),
                              ),
                              const SizedBox(height: 24),
                              _label('PAGE IMAGE'),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: AppColors.input.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color:
                                            AppColors.border.withOpacity(0.5),
                                        width: 2),
                                  ),
                                  child: currentPage.imageDescription.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.file(
                                                File(currentPage
                                                    .imageDescription),
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stk) =>
                                                    const Center(
                                                        child: Icon(
                                                            Icons
                                                                .broken_image_rounded,
                                                            color: AppColors
                                                                .mutedForeground,
                                                            size: 48)),
                                              ),
                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _updateActivePage(
                                                          'image', ''),
                                                  child: ClipRRect(
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 10,
                                                          sigmaY: 10),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.4),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                            Icons.close_rounded,
                                                            color: Colors.white,
                                                            size: 18),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.05),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                  Icons
                                                      .add_photo_alternate_rounded,
                                                  color: AppColors.primary
                                                      .withOpacity(0.5),
                                                  size: 40),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Add an illustration',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.mutedForeground,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _label('PAGE BACKGROUND'),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: _coverColors.map((c) {
                                    final sel =
                                        currentPage.backgroundColor == c;
                                    return GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        _updateActivePage('color', c);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 36,
                                        height: 36,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          color: _hexToColor(c),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: sel
                                                ? Colors.white
                                                : Colors.transparent,
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            if (sel)
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: KidButton(
                              label: 'Preview',
                              icon: Icons.play_arrow_rounded,
                              variant: KidButtonVariant.secondary,
                              onPressed: _openPreview,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: KidButton(
                              label: _saveStatus == _SaveStatus.saving
                                  ? 'Saving...'
                                  : 'Save Story',
                              icon: Icons.check_rounded,
                              onPressed: _saveStatus == _SaveStatus.saving
                                  ? () {}
                                  : () => _save(),
                              isLoading: _saveStatus == _SaveStatus.saving,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverEmoji(String coverEmoji, {double size = 42}) {
    if (coverEmoji.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(coverEmoji,
            fit: BoxFit.cover, width: size * 1.8, height: size * 1.8),
      );
    } else if (coverEmoji.startsWith('/') ||
        coverEmoji.contains(':\\') ||
        coverEmoji.startsWith('file://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.file(File(coverEmoji.replaceFirst('file://', '')),
            fit: BoxFit.cover, width: size * 1.8, height: size * 1.8),
      );
    } else {
      return Text(coverEmoji, style: TextStyle(fontSize: size));
    }
  }

  Widget _iconBtn(IconData icon, Color bg, Color fg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: fg, size: 22),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.mutedForeground,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _multilineField(String hint, ValueChanged<String> onChanged) {
    return TextFormField(
      controller: _storyTextController,
      focusNode: _storyTextFocusNode,
      onChanged: onChanged,
      maxLines: 5,
      style: const TextStyle(
          fontSize: 16,
          color: AppColors.foreground,
          height: 1.5,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: AppColors.mutedForeground.withOpacity(0.5),
            fontSize: 15,
            fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.input.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _suggestionsBar() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _storySuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _storySuggestions[index];
          return ActionChip(
            onPressed: () {
              HapticFeedback.selectionClick();
              _insertSuggestion(suggestion);
            },
            label: Text(
              suggestion,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground.withOpacity(0.85),
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border.withOpacity(0.45)),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
