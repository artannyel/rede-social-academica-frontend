import 'package:intl/intl.dart';

/// Formata um [DateTime] para uma string de tempo relativo (ex: "Há 5 minutos").
/// Se a data for mais antiga que 7 dias, retorna a data formatada (dd/MM/yyyy).
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 5) {
    return 'Agora mesmo';
  } else if (difference.inSeconds < 60) {
    return 'Há ${difference.inSeconds} segundos';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return 'Há $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return 'Há $hours ${hours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return 'Há $days ${days == 1 ? 'dia' : 'dias'}';
  } else {
    // Para datas mais antigas, mostra a data completa.
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}