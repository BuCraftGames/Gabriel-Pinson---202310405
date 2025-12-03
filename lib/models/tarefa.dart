import 'base/entity_base.dart';

class Tarefa extends EntityBase {
  String titulo;
  String descricao;
  String prioridade; 
  String? codigoTime; 

  Tarefa({
    super.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    super.criadoEm,
    super.editadoEm,
    this.codigoTime,
  });


  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      prioridade: map['prioridade'] as String,                      
      criadoEm: DateTime.parse(map['criadoEm'] as String),
      editadoEm: map['editadoEm'] != null 
          ? DateTime.parse(map['editadoEm'] as String)
          : null,
      codigoTime: map['codigoTime'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade,                
      'criadoEm': criadoEmString,
      'editadoEm': editadoEmString,
      'codigoTime': codigoTime,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'Tarefa{id: $id, titulo: $titulo'
           'prioridade: $prioridade}';
  }

}