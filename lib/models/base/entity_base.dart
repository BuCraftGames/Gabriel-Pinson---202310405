abstract class EntityBase {
  int? id;
  DateTime criadoEm;
  DateTime? editadoEm;

  EntityBase({
    this.id,
    DateTime? criadoEm,
    this.editadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  // Métodos auxiliares para conversão de data
  String get criadoEmString => criadoEm.toIso8601String();
  String? get editadoEmString => editadoEm?.toIso8601String();

  // Método para atualizar a data de edição
  void atualizarDataEdicao() {
    editadoEm = DateTime.now();
  }
}