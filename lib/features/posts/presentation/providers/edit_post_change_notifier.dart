import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/usecases/edit_post.dart';

enum EditPostState {
  idle,
  loading,
  success,
  error,
}

class EditPostChangeNotifier extends ChangeNotifier {
  final EditPost _editPostUseCase;

  EditPostChangeNotifier(this._editPostUseCase);

  EditPostState _state = EditPostState.idle;
  EditPostState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Post? _updatedPost;
  Post? get updatedPost => _updatedPost;

  Future<void> submitPost({
    required String postId,
    required String publication,
    required List<String> tags,
    required List<String> courses,
    List<XFile>? newImages,
    List<String>? removedImageIds,
  }) async {
    _state = EditPostState.loading;
    notifyListeners();

    final result = await _editPostUseCase(
      postId: postId,
      publication: publication,
      tags: tags,
      courses: courses,
      newImages: newImages,
      removedImageIds: removedImageIds,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = EditPostState.error;
      },
      (post) {
        _updatedPost = post;
        _state = EditPostState.success;
      },
    );
    notifyListeners();
  }

  void resetState() {
    _state = EditPostState.idle;
    _errorMessage = null;
    _updatedPost = null;
  }
}