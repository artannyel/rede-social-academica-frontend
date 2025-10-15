import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/posts/domain/usecases/create_post.dart';

enum CreatePostState { idle, loading, success, error }

class CreatePostChangeNotifier extends ChangeNotifier {
  final CreatePost _createPostUseCase;

  CreatePostChangeNotifier(this._createPostUseCase);

  CreatePostState _state = CreatePostState.idle;
  CreatePostState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> submitPost({
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? images,
  }) async {
    _state = CreatePostState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _createPostUseCase(
      publication: publication,
      tags: tags,
      courses: courses,
      images: images,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = CreatePostState.error;
      },
      (_) => _state = CreatePostState.success,
    );
    notifyListeners();
  }

  void resetState() {
    _state = CreatePostState.idle;
    _errorMessage = null;
  }
}
