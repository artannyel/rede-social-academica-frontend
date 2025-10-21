import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/mini_courses/domain/usecases/add_lesson_to_mini_course.dart';
import 'package:social_academic/features/mini_courses/presentation/providers/add_lesson_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';

class AddLessonPage extends StatefulWidget {
  final String miniCourseId;
  const AddLessonPage({super.key, required this.miniCourseId});

  @override
  State<AddLessonPage> createState() => _AddLessonPageState();
}

class _AddLessonPageState extends State<AddLessonPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, AddLessonChangeNotifier notifier) {
    if (notifier.state == AddLessonState.error) {
      showAppSnackBar(
        context,
        message: notifier.errorMessage ?? 'Ocorreu um erro ao adicionar a aula.',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == AddLessonState.success) {
      showAppSnackBar(
        context,
        message: 'Aula adicionada com sucesso!',
        type: SnackBarType.success,
      );
      final createdLesson = notifier.createdLesson;
      notifier.resetState();
      context.pop(createdLesson);
    }
  }

  void _submitForm(BuildContext submitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = Provider.of<AddLessonChangeNotifier>(submitContext, listen: false);
      notifier.submitLesson(
        miniCourseId: widget.miniCourseId,
        title: _titleController.text,
        description: _descriptionController.text,
        youtubeUrl: _youtubeUrlController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddLessonChangeNotifier(context.read<AddLessonToMiniCourse>()),
      child: Consumer<AddLessonChangeNotifier>(
        builder: (context, notifier, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          final isLoading = notifier.state == AddLessonState.loading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Adicionar Aula'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submitForm(context),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
            body: AbsorbPointer(
              absorbing: isLoading,
              child: Stack(
                children: [
                  ResponsiveLayout(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextFormField(
                              controller: _titleController,
                              labelText: 'Título da Aula',
                              validator: (v) => (v?.isEmpty ?? true) ? 'O título é obrigatório.' : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _descriptionController,
                              labelText: 'Descrição',
                              maxLines: 5,
                              validator: (v) => (v?.isEmpty ?? true) ? 'A descrição é obrigatória.' : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _youtubeUrlController,
                              labelText: 'URL do Vídeo (YouTube)',
                              keyboardType: TextInputType.url,
                              validator: (v) => (v?.isEmpty ?? true) ? 'A URL do vídeo é obrigatória.' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
}