import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  static const _keyNomeTecnico = 'nome_tecnico';

  static Future<String?> getNomeTecnico() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNomeTecnico);
  }

  static Future<void> setNomeTecnico(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNomeTecnico, nome);
  }
}
