import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/create_mini_course.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/create_mini_course_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';
import 'package:social_academic/shared/widgets/multi_select_chip_field.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class CreateMiniCoursePage extends StatefulWidget {
  const CreateMiniCoursePage({super.key});

  @override
  State<CreateMiniCoursePage> createState() => _CreateMiniCoursePageState();
}

class _CreateMiniCoursePageState extends State<CreateMiniCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _selectedPhoto;
  List<String> _selectedCourseIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, CreateMiniCourseChangeNotifier notifier) {
    if (notifier.state == CreateMiniCourseState.error) {
      showAppSnackBar(
        context,
        message: notifier.errorMessage ?? 'Ocorreu um erro ao criar o mini curso.',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == CreateMiniCourseState.success) {
      showAppSnackBar(
        context,
        message: 'Mini curso criado com sucesso!',
        type: SnackBarType.success,
      );
      final createdCourse = notifier.createdMiniCourse;
      notifier.resetState();
      context.pop(createdCourse);
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPhoto = image;
      });
    }
  }

  void _submitForm(BuildContext submitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = Provider.of<CreateMiniCourseChangeNotifier>(submitContext, listen: false);
      notifier.submitMiniCourse(
        title: _titleController.text,
        description: _descriptionController.text,
        photo: _selectedPhoto,
        courses: _selectedCourseIds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateMiniCourseChangeNotifier(context.read<CreateMiniCourse>()),
      child: Consumer<CreateMiniCourseChangeNotifier>(
        builder: (context, notifier, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          final isLoading = notifier.state == CreateMiniCourseState.loading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Novo Mini Curso'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submitForm(context),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Criar'),
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
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    final userNotifier = Provider.of<UserNotifier>(context);
    final userCourses = userNotifier.appUser?.courses ?? [];
    return ResponsiveLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextFormField(
                controller: _titleController,
                labelText: 'Título',
                validator: (v) => (v?.isEmpty ?? true) ? 'O título é obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                controller: _descriptionController,
                labelText: 'Descrição',
                maxLines: 5,
                validator: (v) => (v?.isEmpty ?? true) ? 'A descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 24),
              // Seletor de Cursos
              if (userCourses.isNotEmpty)
                FormField<List<String>>(
                  initialValue: _selectedCourseIds,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione pelo menos um curso.';
                    }
                    return null;
                  },
                  builder: (field) {
                    return MultiSelectChipField<String>(
                      title: 'Associar a Cursos',
                      items: userCourses
                          .map(
                            (course) => MultiSelectItem<String>(
                              value: course.id,
                              label: '${course.name} - ${course.courseLevel?.name ?? ''}',
                            ),
                          )
                          .toList(),
                      onSelectionChanged: (selectedIds) {
                        _selectedCourseIds = selectedIds;
                        field.didChange(selectedIds);
                      },
                      errorText: field.errorText,
                    );
                  },
                )
              else
                const Text('Você não está associado a nenhum curso para poder criar um minicurso.'),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Selecionar Foto de Capa'),
              ),
              if (_selectedPhoto != null) ...[
                const SizedBox(height: 16),
                kIsWeb ? Image.network(_selectedPhoto!.path, height: 150) : Image.file(File(_selectedPhoto!.path), height: 150),
              ]
            ],
          ),
        ),
      ),
    );
  }
}