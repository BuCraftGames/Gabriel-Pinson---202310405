import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tarefa.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String _databaseName = '202310405.db';
  static const int _databaseVersion = 1;

  static const String tableTarefas = 'tarefas';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    print('📂 Caminho do banco: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
      CREATE TABLE $tableTarefas (
        id $idType,
        titulo $textType,
        descricao $textType,
        prioridade $textType,
        codigoTime $textTypeNull,
        criadoEm $textType,
        editadoEm $textTypeNull
      )
    ''');

    print('✅ Banco de dados criado com sucesso!');
    print('📋 Tabela "$tableTarefas" criada com 10 campos');
    print('📄 Nome do arquivo: $_databaseName');
  }

  // Método COMPLETO para testar o banco
  Future<void> testDatabase() async {
    final db = await database;
    print('✅ Banco de dados está funcionando!');
    print('📊 Verificando estrutura da tabela...\n');

    // Verificar estrutura da tabela
    final columns = await db.rawQuery('PRAGMA table_info($tableTarefas)');
    print('📋 Campos da tabela "$tableTarefas":');
    for (var column in columns) {
      final nome = column['name'];
      final tipo = column['type'];
      final notNull = column['notnull'] == 1 ? 'NOT NULL' : 'NULLABLE';
      final pk = column['pk'] == 1 ? '(PRIMARY KEY)' : '';
      print('   • $nome: $tipo $notNull $pk');
    }
    print('\n✨ Total de campos: ${columns.length}');
    print('✨ Caminho completo: ${db.path}');
  }
// CREATE - Inserir nova tarefa
  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await database;
    final id = await db.insert(tableTarefas, tarefa.toMap());
    print('✅ Tarefa inserida com ID: $id');
    return id;
  }

  // READ - Listar todas as tarefas
  Future<List<Tarefa>> listarTarefas() async {
    final db = await database;
    final result = await db.query(
      tableTarefas,
      orderBy: 'criadoEm DESC', // Mais recentes primeiro
    );

    print('📋 ${result.length} tarefas encontradas');
    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  // READ - Buscar tarefa por ID
  Future<Tarefa?> buscarTarefaPorId(int id) async {
    final db = await database;
    final result = await db.query(
      tableTarefas,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Tarefa.fromMap(result.first);
    }
    return null;
  }

  // UPDATE - Atualizar tarefa existente
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await database;
    tarefa.atualizarDataEdicao(); // Atualiza editadoEm

    final count = await db.update(
      tableTarefas,
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );

    print('✅ Tarefa atualizada: ${tarefa.titulo}');
    return count;
  }

  // DELETE - Excluir tarefa
  Future<int> excluirTarefa(int id) async {
    final db = await database;
    final count = await db.delete(
      tableTarefas,
      where: 'id = ?',
      whereArgs: [id],
    );

    print('🗑️ Tarefa excluída (ID: $id)');
    return count;
  }

  // FILTROS - Buscar tarefas por prioridade
  Future<List<Tarefa>> buscarPorPrioridade(String prioridade) async {
    final db = await database;
    final result = await db.query(
      tableTarefas,
      where: 'prioridade = ?',
      whereArgs: [prioridade],
      orderBy: 'criadoEm DESC',
    );

    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  // FILTROS - Buscar tarefas finalizadas
  Future<List<Tarefa>> buscarFinalizadas() async {
    final db = await database;
    final result = await db.query(
      tableTarefas,
      where: 'dataFinalizacao IS NOT NULL',
      orderBy: 'dataFinalizacao DESC',
    );

    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  // FILTROS - Buscar tarefas pendentes
  Future<List<Tarefa>> buscarPendentes() async {
    final db = await database;
    final result = await db.query(
      tableTarefas,
      where: 'dataFinalizacao IS NULL',
      orderBy: 'dataInicio ASC',
    );

    return result.map((map) => Tarefa.fromMap(map)).toList();
  }
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}