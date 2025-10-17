import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/authentication/domain/usecases/update_user.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';

enum EditProfileState { idle, loading, success, error }

class EditProfileChangeNotifier extends ChangeNotifier {
  final UpdateUser _updateUserUseCase;
  final UserNotifier _userNotifier;

  EditProfileChangeNotifier(this._updateUserUseCase, this._userNotifier);

  EditProfileState _state = EditProfileState.idle;
  EditProfileState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> submitUpdate({
    required String name,
    String? bio,
    List<Map<String, dynamic>>? userCourses,
    XFile? photo,
    bool removePhoto = false,
  }) async {
    _state = EditProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateUserUseCase(
      name: name,
      bio: bio,
      userCourses: userCourses,
      photo: photo,
      removePhoto: removePhoto,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = EditProfileState.error;
      },
      (updatedUser) {
        _userNotifier.setAppUser(updatedUser); // Atualiza o usuário globalmente
        _state = EditProfileState.success;
      },
    );

    notifyListeners();
  }

  /// Reseta o estado para o valor inicial.
  void resetState() {
    if (_state != EditProfileState.idle) {
      _state = EditProfileState.idle;
      _errorMessage = null;
    }
  }
}