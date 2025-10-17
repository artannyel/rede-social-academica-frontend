import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/posts/domain/entities/post.dart';
import 'package:social_academic/features/posts/domain/entities/post_image.dart';
import 'package:social_academic/features/posts/domain/usecases/edit_post.dart';
import 'package:social_academic/features/posts/presentation/providers/edit_post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/tag_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/image_picker_field.dart';
import 'package:social_academic/features/profile/presentation/providers/my_posts_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';
import 'package:social_academic/shared/widgets/multi_select_chip_field.dart';

class EditPostPage extends StatefulWidget {
  final Post post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _publicationController;
  late List<String> _selectedTagIds;
  late List<String> _selectedCourseIds;
  List<XFile> _newImages = [];
  late List<PostImage> _existingImages;
  List<String> _removedImageIds = [];

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores e listas com os dados do post existente
    _publicationController = TextEditingController(text: widget.post.publication);
    _selectedTagIds = widget.post.tags.map((t) => t.id).toList();
    _selectedCourseIds = widget.post.courses.map((c) => c.id).toList();
    _existingImages = List<PostImage>.from(widget.post.images);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TagChangeNotifier>(context, listen: false).fetchTags();
    });
  }

  @override
  void dispose() {
    _publicationController.dispose();
    super.dispose();
  }

  void _handleStateChange(
    BuildContext context,
    EditPostChangeNotifier notifier,
  ) {
    if (notifier.state == EditPostState.error) {
      showAppSnackBar(
        context,
        message:
            notifier.errorMessage ?? 'Ocorreu um erro ao editar a publicação.',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == EditPostState.success) {
      showAppSnackBar(
        context,
        message: 'Publicação editada com sucesso!',
        type: SnackBarType.success,
      );
      // Atualiza o post na lista da home e do perfil
      if (notifier.updatedPost != null) {
        context.read<PostChangeNotifier>().updatePost(notifier.updatedPost!);
        context.read<MyPostsChangeNotifier>().updatePost(notifier.updatedPost!);
      }
      notifier.resetState();
      // Volta para a tela anterior
      context.pop();
    }
  }

  void _submitForm(BuildContext submitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = Provider.of<EditPostChangeNotifier>(
        submitContext,
        listen: false,
      );
      notifier.submitPost(
        postId: widget.post.id,
        publication: _publicationController.text,
        tags: _selectedTagIds,
        courses: _selectedCourseIds,
        newImages: _newImages,
        removedImageIds: _removedImageIds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);
    final userCourses = userNotifier.appUser?.courses ?? [];

    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => EditPostChangeNotifier(context.read<EditPost>()),
        child: Consumer<EditPostChangeNotifier>(
            builder: (context, notifier, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          final bool isLoading = notifier.state == EditPostState.loading;

          return AbsorbPointer(
            absorbing: isLoading,
            child: Builder(builder: (innerContext) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Editar Publicação'),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submitForm(innerContext),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    _buildForm(innerContext, userCourses),
                    if (isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<dynamic> userCourses) {
    return ResponsiveLayout(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextFormField(
                    controller: _publicationController,
                    labelText: 'O que você está pensando?',
                    keyboardType: TextInputType.multiline,
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A publicação não pode estar vazia.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ImagePickerField(
                    onImagesSelected: (images) => _newImages = images,
                    existingImages: _existingImages,
                    onRemoveExistingImage: (image) {
                      setState(() {
                        _existingImages.remove(image);
                        _removedImageIds.add(image.id);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
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
                          initialValue: _selectedCourseIds,
                          items: userCourses
                              .map((course) => MultiSelectItem<String>(
                                    value: course.id,
                                    label:
                                        '${course.name} - ${course.courseLevel?.name ?? ''}',
                                  ))
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
                    const Text('Você não está associado a nenhum curso.'),
                  const SizedBox(height: 24),
                  Consumer<TagChangeNotifier>(
                    builder: (context, tagNotifier, child) {
                      if (tagNotifier.state == TagState.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (tagNotifier.state == TagState.error) {
                        return Text(
                          'Erro ao carregar tags: ${tagNotifier.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      if (tagNotifier.tags.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return FormField<List<String>>(
                        initialValue: _selectedTagIds,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione pelo menos uma tag.';
                          }
                          return null;
                        },
                        builder: (field) {
                          return MultiSelectChipField<String>(
                            title: 'Adicionar Tags',
                            initialValue: _selectedTagIds,
                            items: tagNotifier.tags
                                .map((tag) => MultiSelectItem(
                                      value: tag.id,
                                      label: tag.name,
                                    ))
                                .toList(),
                            onSelectionChanged: (selectedIds) {
                              _selectedTagIds = selectedIds;
                              field.didChange(selectedIds);
                            },
                            errorText: field.errorText,
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
      ),
    );
  }
}