import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; // Required for File
import 'package:flutter/foundation.dart' show kIsWeb; // Required for kIsWeb
import 'package:social_academic/app/core/auth/auth_notifier.dart';
import 'package:social_academic/features/authentication/presentation/provider/register_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_snackbar.dart';
import 'package:image_picker/image_picker.dart'; // Required for ImagePicker
import 'package:social_academic/features/courses/presentation/provider/course_change_notifier.dart';
import 'package:social_academic/shared/widgets/app_text_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// Classe auxiliar para gerenciar a seleção de curso do usuário.
class _UserCourseSelection {
  int? semester;
  bool isFinished;

  _UserCourseSelection({this.semester, this.isFinished = false});
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  XFile? _selectedPhoto; // Variável para armazenar a foto de perfil selecionada
  // Armazena os cursos selecionados e o semestre correspondente. Key: courseId, Value: semester
  final Map<String, _UserCourseSelection> _selectedCourses = {};
  late final AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    // Busca a lista de cursos assim que a página é construída.
    // Usamos addPostFrameCallback para garantir que o context está pronto.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<CourseChangeNotifier>(
        context,
        listen: false,
      ).fetchCourses(),
    );
    _authNotifier = Provider.of<AuthNotifier>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    // Garante que o listener seja retomado se o usuário sair da tela
    // sem completar o registro (ex: voltando para a tela de login).
    _authNotifier.resumeListener();
    super.dispose();
  }

  void _handleStateChange(
    BuildContext context,
    RegisterChangeNotifier notifier,
  ) {
    if (notifier.state == RegisterState.error) {
      showAppSnackBar(
        context,
        message: notifier.errorMessage ?? 'Erro desconhecido',
        type: SnackBarType.error,
      );
      notifier.resetState();
    } else if (notifier.state == RegisterState.success) {
      showAppSnackBar(
        context,
        message:
            'Cadastro realizado com sucesso! Bem-vindo, ${notifier.user?.name}!',
        type: SnackBarType.success,
      );
      notifier.resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<RegisterChangeNotifier>(
        create: (context) => RegisterChangeNotifier(
          context.read(), // Register
          context.read(), // AuthNotifier
          context.read(), // UserNotifier
          context.read(), // CourseChangeNotifier
        ),
        // Usamos um Consumer para obter o context que está abaixo do Provider
        // e assim ter acesso ao RegisterChangeNotifier recém-criado.
        child: Consumer2<RegisterChangeNotifier, CourseChangeNotifier>( // CourseChangeNotifier ainda é global
          builder: (context, registerNotifier, courseNotifier, child) {
            // Escuta as mudanças de estado para mostrar SnackBars ou navegar
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _handleStateChange(context, registerNotifier),
            );

            if (registerNotifier.state == RegisterState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cadastro',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 300),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Image.asset(
                                  'assets/images/image_for_register.png',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Campo de upload de foto de perfil
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                backgroundImage: _selectedPhoto != null
                                    ? (kIsWeb
                                        ? NetworkImage(_selectedPhoto!.path)
                                        : FileImage(File(_selectedPhoto!.path)) as ImageProvider)
                                    : null,
                                child: _selectedPhoto == null
                                    ? Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _pickProfileImage,
                              icon: const Icon(Icons.edit),
                              label: Text(
                                _selectedPhoto == null
                                    ? 'Adicionar Foto de Perfil'
                                    : 'Mudar Foto de Perfil',
                              ),
                            ),
                            if (_selectedPhoto != null)
                              TextButton(
                                onPressed: _removeProfileImage,
                                child: const Text('Remover Foto'),
                              ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _nameController,
                              labelText: 'Nome',
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? 'Por favor, insira seu nome'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _emailController,
                              labelText: 'E-mail',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? 'Por favor, insira seu e-mail'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _passwordController,
                              labelText: 'Senha',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) => (value?.length ?? 0) < 6
                                  ? 'A senha deve ter no mínimo 6 caracteres'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirmar Senha',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, confirme sua senha';
                                }
                                if (value != _passwordController.text) {
                                  return 'As senhas não coincidem';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _bioController,
                              labelText: 'Bio (Opcional)',
                              prefixIcon: Icons.info_outline,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                            ),
                            const SizedBox(height: 16),
                            if (courseNotifier.state == CourseState.loading)
                              const Center(child: CircularProgressIndicator())
                            else if (courseNotifier.state == CourseState.error)
                              Text(
                                'Erro ao carregar cursos: ${courseNotifier.errorMessage}',
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              // Componente customizado para seleção de curso e semestre
                              FormField<Map<String, _UserCourseSelection>>(
                                initialValue: _selectedCourses,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Adicione pelo menos um curso.';
                                  }
                                  // Verifica se algum curso selecionado está sem semestre
                                  if (value.values.any(
                                    (selection) => selection.semester == null,
                                  )) {
                                    return 'Selecione o semestre para todos os cursos.';
                                  }
                                  return null;
                                },
                                builder: (field) {
                                  final selectedCourseObjects = courseNotifier
                                      .courses
                                      .where(
                                        (c) =>
                                            _selectedCourses.containsKey(c.id),
                                      )
                                      .toList();

                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Cursos e Semestres',
                                      errorText: field.errorText,
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                    child: Column(
                                      children: [
                                        ...selectedCourseObjects.map((course) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${course.name}${course.courseLevel != null ? ' - ${course.courseLevel!.name}' : ''}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  flex: 3,
                                                  child: DropdownButtonFormField<int?>(
                                                    value:
                                                        _selectedCourses[course
                                                                    .id]
                                                                ?.isFinished ==
                                                            true
                                                        ? 0 // Valor especial para "Formado"
                                                        : _selectedCourses[course
                                                                  .id]
                                                              ?.semester,
                                                    isExpanded: true,
                                                    decoration: const InputDecoration(
                                                      hintText: 'Semestre',
                                                      border:
                                                          UnderlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                    ),
                                                    items: [
                                                      // Gera a lista de semestres
                                                      ...List.generate(
                                                        course.semester!,
                                                        (index) {
                                                          final semester =
                                                              index + 1;
                                                          return DropdownMenuItem<
                                                            int
                                                          >(
                                                            value: semester,
                                                            child: Text(
                                                              '$semesterº',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      // Adiciona a opção "Formado"
                                                      const DropdownMenuItem<
                                                        int
                                                      >(
                                                        value:
                                                            0, // Valor especial para "Formado"
                                                        child: Text('Formado'),
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value == 0) {
                                                          // Se "Formado" for selecionado
                                                          _selectedCourses[course
                                                                  .id] =
                                                              _UserCourseSelection(
                                                                semester: course
                                                                    .semester,
                                                                isFinished:
                                                                    true,
                                                              );
                                                        } else {
                                                          _selectedCourses[course
                                                                  .id] =
                                                              _UserCourseSelection(
                                                                semester: value,
                                                                isFinished:
                                                                    false,
                                                              );
                                                        }
                                                        field.didChange(
                                                          _selectedCourses,
                                                        );
                                                      });
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedCourses.remove(
                                                        course.id,
                                                      );
                                                      field.didChange(
                                                        _selectedCourses,
                                                      );
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text('Adicionar Cursos'),
                                          onPressed: () async {
                                            await _showCourseSelectionDialog(
                                              context,
                                              courseNotifier,
                                              field,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _submitForm(context),
                              child: const Text('Cadastrar'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                context.go(
                                  '/login',
                                ); // Navega para a tela de login
                              },
                              child: const Text('Já tem uma conta? Faça login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Método para selecionar uma única imagem para a foto de perfil
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedPhoto = image;
      });
    }
  }

  // Método para remover a foto de perfil selecionada
  void _removeProfileImage() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  void _submitForm(BuildContext submitContext) {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = Provider.of<RegisterChangeNotifier>(
        submitContext,
        listen: false,
      );
      notifier.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        bio: _bioController.text,
        photo: _selectedPhoto, // Passa a foto selecionada
        // Converte o mapa para o formato esperado pela API
        userCourses: _selectedCourses.entries
            .where((entry) => entry.value.semester != null)
            .map((entry) {
              final selection = entry.value;
              final coursePayload = {
                'id': entry.key,
                'current_semester': selection.semester,
              };
              if (selection.isFinished) {
                coursePayload['finished'] = true;
              }
              return coursePayload;
            })
            .toList(),
      );
    }
  }

  Future<void> _showCourseSelectionDialog(
    BuildContext context,
    CourseChangeNotifier courseNotifier,
    FormFieldState<Map<String, _UserCourseSelection>> field,
  ) async {
    final tempSelectedIds = _selectedCourses.keys.toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Selecione seus cursos'),
              content: SizedBox(
                // Define uma largura responsiva com um máximo de 500px para o diálogo.
                width: (MediaQuery.of(context).size.width * 0.8).clamp(
                  0.0,
                  600.0,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: courseNotifier.courses.length,
                  itemBuilder: (context, index) {
                    final course = courseNotifier.courses[index];
                    final isSelected = tempSelectedIds.contains(course.id);
                    return CheckboxListTile(
                      title: Text(
                        '${course.name}${course.courseLevel != null ? ' - ${course.courseLevel!.name}' : ''}',
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
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
                      _selectedCourses.clear();
                      for (var id in tempSelectedIds) {
                        _selectedCourses[id] =
                            _UserCourseSelection(); // Adiciona o curso com semestre nulo
                      }
                      field.didChange(_selectedCourses);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
