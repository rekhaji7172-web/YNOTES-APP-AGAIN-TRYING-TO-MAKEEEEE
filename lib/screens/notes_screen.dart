import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'indigo', 'color': const Color(0xFF6366F1)},
    {'name': 'blue', 'color': const Color(0xFF0EA5E9)},
    {'name': 'green', 'color': const Color(0xFF10B981)},
    {'name': 'amber', 'color': const Color(0xFFF59E0B)},
    {'name': 'red', 'color': const Color(0xFFEF4444)},
    {'name': 'pink', 'color': const Color(0xFFEC4899)},
  ];

  Color _getNoteColor(String colorName) {
    return _colorOptions
        .firstWhere((c) => c['name'] == colorName,
            orElse: () => _colorOptions[0])['color'] as Color;
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageService.loadNotes();
    if (mounted) setState(() => _notes = notes);
  }

  Future<void> _saveNotes() => StorageService.saveNotes(_notes);

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((n) =>
        n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _addOrEditNote([Note? existing]) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController = TextEditingController(text: existing?.content ?? '');
    String selectedColor = existing?.color ?? 'indigo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existing == null ? 'New Note' : 'Edit Note',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final now = DateTime.now();
                        if (existing == null) {
                          final note = Note(
                            id: now.millisecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            content: contentController.text.trim(),
                            createdAt: now,
                            updatedAt: now,
                            color: selectedColor,
                          );
                          setState(() => _notes.insert(0, note));
                        } else {
                          setState(() {
                            existing.title = titleController.text.trim();
                            existing.content = contentController.text.trim();
                            existing.color = selectedColor;
                            existing.updatedAt = now;
                          });
                        }
                        _saveNotes();
                        Navigator.pop(ctx);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              // Color picker
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: _colorOptions.map((c) {
                    final isSelected = selectedColor == c['name'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = c['name'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        width: isSelected ? 28 : 22,
                        height: isSelected ? 28 : 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c['color'] as Color,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.1)),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    expands: true,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Write your note...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.25)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotes;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note_rounded,
                        size: 64, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('No notes yet',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final note = filtered[i];
                    final color = _getNoteColor(note.color);
                    return GestureDetector(
                      onTap: () => _addOrEditNote(note),
                      onLongPress: () {
                        setState(() => _notes.removeWhere((n) => n.id == note.id));
                        _saveNotes();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: color),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              note.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                note.content,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
