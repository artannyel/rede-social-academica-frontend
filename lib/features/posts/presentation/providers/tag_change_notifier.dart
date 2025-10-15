import 'package:flutter/material.dart';
import 'package:social_academic/features/posts/domain/entities/tag.dart';
import 'package:social_academic/features/posts/domain/usecases/get_tags.dart';

enum TagState { initial, loading, success, error }

class TagChangeNotifier extends ChangeNotifier {
  final GetTags _getTagsUseCase;

  TagChangeNotifier(this._getTagsUseCase);

  TagState _state = TagState.initial;
  TagState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  Future<void> fetchTags() async {
    _state = TagState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getTagsUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = TagState.error;
      },
      (tags) {
        _tags = tags;
        _state = TagState.success;
      },
    );

    notifyListeners();
  }
}