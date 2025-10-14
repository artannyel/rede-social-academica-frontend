import 'package:flutter/material.dart';

/// Enum para definir os tipos de SnackBar.
enum SnackBarType { success, error, info, warning }

/// Exibe um SnackBar customizado na tela.
///
/// [context] O BuildContext atual.
/// [message] A mensagem a ser exibida.
/// [type] O tipo de SnackBar (success, error, info, warning), que define a cor de fundo.
/// [duration] A duração opcional do SnackBar. O padrão é 4 segundos.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
  Duration? duration,
}) {
  // Garante que qualquer SnackBar anterior seja removido antes de mostrar um novo.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  IconData iconData;
  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      iconData = Icons.check_circle_outline;
      backgroundColor = Colors.green;
      break;
    case SnackBarType.error:
      iconData = Icons.error_outline;
      backgroundColor = Colors.red;
      break;
    case SnackBarType.info:
      iconData = Icons.info_outline;
      backgroundColor = Colors.blue;
      break;
    case SnackBarType.warning:
      iconData = Icons.warning_amber_outlined;
      backgroundColor = Colors.orange;
      break;
  }

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(iconData, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    duration: duration ?? const Duration(seconds: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 4,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(16),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
