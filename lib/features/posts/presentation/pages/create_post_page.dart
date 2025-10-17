import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_academic/features/authentication/presentation/provider/user_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_academic/features/posts/domain/usecases/create_post.dart';
import 'package:social_academic/features/posts/presentation/providers/post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/create_post_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/providers/tag_change_notifier.dart';
import 'package:social_academic/features/posts/presentation/widgets/image_picker_field.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:social_academic/shared/widgets/responsive_layout.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';
import 'package:social_academic/shared/widgets/multi_select_chip_field.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _publicationController = TextEditingController();
  List<String> _selectedTagIds = [];
  List<String> _selectedCourseIds = [];
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
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
    CreatePostChangeNotifier notifier,
  ) {
    if (notifier.state == CreatePostState.error) {
      showAppSnackBar(
        context,
        message:
            notifier.errorMessage ?? 'Ocorreu um erro ao criar a publicação.',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == CreatePostState.success) {
      showAppSnackBar(
        context,
        message: 'Publicação criada com sucesso!',
        type: SnackBarType.success,
      );
      // Adiciona o novo post à lista da home page para atualização instantânea.
      if (notifier.createdPost != null) {
        Provider.of<PostChangeNotifier>(context, listen: false)
            .addNewPost(notifier.createdPost!);
      }
      notifier.resetState();
      // Volta para a tela anterior (home) após o sucesso.
      context.go('/home');
    }
  }

  void _submitForm(submitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = Provider.of<CreatePostChangeNotifier>(
        submitContext,
        listen: false,
      );
      notifier.submitPost(
        publication: _publicationController.text,
        tags: _selectedTagIds,
        courses: _selectedCourseIds,
        images: _selectedImages,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);
    final userCourses = userNotifier.appUser?.courses ?? [];

    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => CreatePostChangeNotifier(context.read<CreatePost>()),
        child: Consumer<CreatePostChangeNotifier>(builder: (context, notifier, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(context, notifier);
          });

          final bool isLoading = notifier.state == CreatePostState.loading;

          return AbsorbPointer(
            absorbing: isLoading,
            child: Builder(builder: (innerContext) { // Usamos um Builder para obter o context correto
              return Scaffold(
              appBar: AppBar(
                title: const Text('Nova Publicação'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              _submitForm(innerContext); // Passamos o innerContext
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Publicar'),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  _buildForm(innerContext, userCourses),
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
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
                  // 1. Campo de Publicação
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

                  // 2. Campo de Imagens
                  ImagePickerField(
                    onImagesSelected: (images) {
                      _selectedImages = images;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. Seletor de Cursos
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
                                  label:
                                      '${course.name} - ${course.courseLevel?.name ?? ''}',
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
                    const Text('Você não está associado a nenhum curso.'),
                  const SizedBox(height: 24),

                  // 4. Seletor de Tags
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
                        return const SizedBox.shrink(); // Não mostra nada se não houver tags
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
                            items: tagNotifier.tags
                                .map(
                                  (tag) => MultiSelectItem(
                                    value: tag.id,
                                    label: tag.name,
                                  ),
                                )
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
/*
              // 3. Seletor de Cursos
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
                              label:
                                  '${course.name} - ${course.courseLevel?.name ?? ''}',
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
                const Text('Você não está associado a nenhum curso.'),
              const SizedBox(height: 24),

              // 4. Seletor de Tags
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
                    return const SizedBox.shrink(); // Não mostra nada se não houver tags
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
                        items: tagNotifier.tags
                            .map(
                              (tag) => MultiSelectItem(
                                value: tag.id,
                                label: tag.name,
                              ),
                            )
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
*/
