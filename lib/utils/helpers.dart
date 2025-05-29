// Funções auxiliares para formatação

String formatDateBR(DateTime date) {
  // Exemplo: 25/05/2025
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}

String projectStatusText(int statusIndex) {
  switch (statusIndex) {
    case 0:
      return "Não iniciado";
    case 1:
      return "Em andamento";
    case 2:
      return "Finalizado";
    default:
      return "Desconhecido";
  }
}

String paymentMethodText(int methodIndex) {
  switch (methodIndex) {
    case 0:
      return "Cartão de Crédito";
    case 1:
      return "Pix à vista";
    case 2:
      return "Pix 2x (50%/50%)";
    default:
      return "Desconhecido";
  }
}