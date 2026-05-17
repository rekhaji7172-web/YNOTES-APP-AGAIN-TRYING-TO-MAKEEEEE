import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/note.dart';
import '../models/flashcard.dart';

class StorageService {
  static const _tasksKey = 'tasks_v1';
  static const _notesKey = 'notes_v1';
  static const _flashcardsKey = 'flashcards_v1';

  // Tasks
  static Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_tasksKey);
      if (data == null) return [];
      final List<dynamic> json = jsonDecode(data);
      return json.map((e) => Task.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  // Notes
  static Future<List<Note>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_notesKey);
      if (data == null) return [];
      final List<dynamic> json = jsonDecode(data);
      return json.map((e) => Note.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
    } catch (_) {}
  }

  // Flashcards
  static Future<List<Flashcard>> loadFlashcards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_flashcardsKey);
      if (data == null) return [];
      final List<dynamic> json = jsonDecode(data);
      return json.map((e) => Flashcard.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _flashcardsKey, jsonEncode(flashcards.map((f) => f.toJson()).toList()));
    } catch (_) {}
  }
}
