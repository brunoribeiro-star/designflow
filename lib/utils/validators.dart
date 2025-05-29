// Validações simples para formulários

String? notEmpty(String? value, [String message = "Campo obrigatório"]) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) return null;
  // Regex simples para email
  final regex = RegExp(r"^[\w\.\-]+@[\w\.\-]+\.\w{2,4}$");
  if (!regex.hasMatch(value)) return "E-mail inválido";
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) return null;
  // Apenas números e mínimo 8 dígitos
  final regex = RegExp(r'^\d{8,}$');
  if (!regex.hasMatch(value)) return "Telefone inválido";
  return null;
}