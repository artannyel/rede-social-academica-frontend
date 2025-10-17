import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/courses/domain/entities/course.dart';
import 'package:social_academic/features/courses/presentation/provider/course_change_notifier.dart';
import 'package:social_academic/features/profile/presentation/providers/edit_profile_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';

class _UserCourseSelection {
  int? semester;
  bool isFinished;

  _UserCourseSelection({this.semester, this.isFinished = false});
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  XFile? _selectedPhoto;
  String? _existingPhotoUrl;
  bool _removePhoto = false;
  final Map<String, _UserCourseSelection> _selectedCourses = {};
  final Set<String> _initialCourseIds = {};

  @override
  void initState() {
    super.initState();
    final user = context.read<UserNotifier>().appUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _existingPhotoUrl = user?.photoUrl;

    user?.courses?.forEach((userCourse) {
      _selectedCourses[userCourse.id] = _UserCourseSelection(
        semester: userCourse.currentSemester,
        isFinished: userCourse.finished ?? false,
      );
      _initialCourseIds.add(userCourse.id);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseChangeNotifier>(context, listen: false).fetchCourses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleStateChange(
    BuildContext context,
    EditProfileChangeNotifier notifier,
  ) {
    if (notifier.state == EditProfileState.error) {
      showAppSnackBar(
        context,
        message: notifier.errorMessage ?? 'Erro ao atualizar.',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == EditProfileState.success) {
      showAppSnackBar(
        context,
        message: 'Perfil atualizado com sucesso!',
        type: SnackBarType.success,
      );
      notifier.resetState();
      context.pop(); // Volta para a tela de perfil
    }
  }

  Future<void> _pickProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPhoto = image;
        _removePhoto =
            false; // Se selecionar uma nova, não remove a antiga (será substituída)
      });
    }
  }

  void _submitForm(BuildContext submitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      final user = Provider.of<UserNotifier>(
        submitContext,
        listen: false,
      ).appUser;
      if (user == null) return;

      final notifier = Provider.of<EditProfileChangeNotifier>(
        submitContext,
        listen: false,
      );
      notifier.submitUpdate(
        name: _nameController.text,
        bio: _bioController.text,
        photo: _selectedPhoto,
        removePhoto: _removePhoto,
        userCourses: _selectedCourses.entries.map((entry) {
          final selection = entry.value;
          return {
            'id': entry.key,
            'current_semester': selection.semester,
            'finished': selection.isFinished,
          };
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileChangeNotifier>(
      builder: (context, notifier, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleStateChange(context, notifier);
        });

        final isLoading = notifier.state == EditProfileState.loading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar Perfil'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _submitForm(context),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
          body: AbsorbPointer(
            absorbing: isLoading,
            child: Stack(
              children: [
                _buildForm(),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    ImageProvider? backgroundImage;
    if (_selectedPhoto != null) {
      backgroundImage = kIsWeb
          ? NetworkImage(_selectedPhoto!.path)
          : FileImage(File(_selectedPhoto!.path)) as ImageProvider;
    } else if (_existingPhotoUrl != null && !_removePhoto) {
      backgroundImage = NetworkImage(_existingPhotoUrl!);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --- FOTO DE PERFIL ---
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: backgroundImage,
                    child: backgroundImage == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickProfileImage,
                  icon: const Icon(Icons.edit),
                  label: Text(
                    _selectedPhoto == null ? 'Alterar Foto' : 'Alterar Foto',
                  ),
                ),
                if (_existingPhotoUrl != null && !_removePhoto)
                  TextButton(
                    onPressed: () => setState(() {
                      _removePhoto = true;
                      _selectedPhoto = null;
                    }),
                    child: const Text(
                      'Remover Foto',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),

                // --- CAMPOS DE TEXTO ---
                AppTextFormField(
                  controller: _nameController,
                  labelText: 'Nome',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'O nome é obrigatório.' : null,
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  controller: _bioController,
                  labelText: 'Bio (Opcional)',
                  prefixIcon: Icons.info_outline,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                // --- SELEÇÃO DE CURSOS ---
                Consumer<CourseChangeNotifier>(
                  builder: (context, courseNotifier, _) {
                    if (courseNotifier.state == CourseState.loading)
                      return const CircularProgressIndicator();
                    return FormField<Map<String, _UserCourseSelection>>(
                      initialValue: _selectedCourses,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Adicione pelo menos um curso.';
                        if (value.values.any((s) => s.semester == null))
                          return 'Selecione o semestre para todos os cursos.';
                        return null;
                      },
                      builder: (field) {
                        final selectedCourseObjects = courseNotifier.courses
                            .where((c) => _selectedCourses.containsKey(c.id))
                            .toList();
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Cursos e Semestres',
                            errorText: field.errorText,
                          ),
                          child: Column(
                            children: [
                              ...selectedCourseObjects.map(
                                (course) => _buildCourseItem(course, field),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar/Remover Cursos'),
                                onPressed: () async =>
                                    await _showCourseSelectionDialog(
                                      context,
                                      courseNotifier,
                                      field,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(
    Course course,
    FormFieldState<Map<String, _UserCourseSelection>> field,
  ) {
    final bool isInitialCourse = _initialCourseIds.contains(course.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${course.name} - ${course.courseLevel!.name}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int?>(
              value: _selectedCourses[course.id]?.isFinished == true
                  ? 0
                  : _selectedCourses[course.id]?.semester,
              decoration: const InputDecoration(
                hintText: 'Semestre',
                border: UnderlineInputBorder(),
              ),
              items: [
                ...List.generate(
                  course.semester!,
                  (i) => DropdownMenuItem<int>(
                    value: i + 1,
                    child: Text('${i + 1}º'),
                  ),
                ),
                const DropdownMenuItem<int>(value: 0, child: Text('Formado')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourses[course.id] = _UserCourseSelection(
                    semester: value == 0 ? course.semester : value,
                    isFinished: value == 0,
                  );
                  field.didChange(_selectedCourses);
                });
              },
            ),
          ),
          if (!isInitialCourse)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  _selectedCourses.remove(course.id);
                  field.didChange(_selectedCourses);
                });
              },
              tooltip: 'Remover curso',
            ),
        ],
      ),
    );
  }

  Future<void> _showCourseSelectionDialog(
    BuildContext context,
    CourseChangeNotifier courseNotifier,
    FormFieldState<Map<String, _UserCourseSelection>> field,
  ) async {
    final tempSelectedIds = _selectedCourses.keys.toList();
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Selecione seus cursos'),
          content: SizedBox(
            width: (MediaQuery.of(context).size.width * 0.8).clamp(0.0, 600.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: courseNotifier.courses.length,
              itemBuilder: (context, index) {
                final course = courseNotifier.courses[index];
                final bool isInitialCourse =
                    _initialCourseIds.contains(course.id);
                return CheckboxListTile(
                  title: Text('${course.name} - ${course.courseLevel!.name}'),
                  value: tempSelectedIds.contains(course.id),
                  // Desabilita o checkbox se for um curso inicial
                  onChanged: isInitialCourse
                      ? null
                      : (selected) {
                          setStateDialog(() {
                            if (selected == true) {
                              tempSelectedIds.add(course.id);
                            } else {
                              tempSelectedIds.remove(course.id);
                            }
                          });
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final currentSelection = Map.of(_selectedCourses);
                  _selectedCourses.clear();
                  for (var id in tempSelectedIds) {
                    _selectedCourses[id] =
                        currentSelection[id] ?? _UserCourseSelection();
                  }
                  field.didChange(_selectedCourses);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
