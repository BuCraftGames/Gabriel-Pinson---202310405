import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'tarefa_form_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tarefa> _tarefas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    setState(() => _isLoading = true);

    try {
      final tarefas = await DatabaseHelper.instance.listarTarefas();
      setState(() {
        _tarefas = tarefas;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirTarefa(int id, String titulo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a tarefa "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.excluirTarefa(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa excluída com sucesso!')),
      );
      _carregarTarefas();
    }
  }

  void _abrirFormulario([Tarefa? tarefa]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TarefaFormScreen(tarefa: tarefa),
      ),
    );

    if (resultado == true) {
      _carregarTarefas();
    }
  }

  // Função auxiliar: normaliza prioridade (remove acentos e espaços)
  String _normalizePrioridade(String? prioridade) {
    if (prioridade == null) return 'outro';
    var s = prioridade.toLowerCase().trim();
    s = s.replaceAll('é', 'e').replaceAll('ê', 'e').replaceAll('á', 'a').replaceAll('ã', 'a');
    if (s.contains('alta')) return 'alta';
    if (s.contains('media') || s.contains('média')) return 'media';
    if (s.contains('baixa')) return 'baixa';
    return 'outro';
  }

  Color _getCorPrioridade(String? prioridade) {
    final p = _normalizePrioridade(prioridade);
    switch (p) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  DateTime _parseDateTime(String? value) {
    if (value == null) return DateTime.now();
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    try {
      final millis = int.parse(value);
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Profissionais - RA 202310405'),
        backgroundColor: Colors.cyan,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 100, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma tarefa cadastrada',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no + para adicionar',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Resumo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyan.shade50, Colors.lightBlue.shade50],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildContador('Total', _tarefas.length, Colors.cyan),
                          _buildContador(
                            'Alta',
                            _tarefas.where((t) => _normalizePrioridade(t.prioridade) == 'alta').length,
                            Colors.red,
                          ),
                          _buildContador(
                            'Média',
                            _tarefas.where((t) => _normalizePrioridade(t.prioridade) == 'media').length,
                            Colors.orange,
                          ),
                          _buildContador(
                            'Baixa',
                            _tarefas.where((t) => t.prioridade.toLowerCase() == 'baixa').length,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    // Lista
                    Expanded(
                      child: ListView.builder(
                        itemCount: _tarefas.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final tarefa = _tarefas[index];
                          return _buildTarefaCard(tarefa);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContador(String label, int valor, Color cor) {
    return Column(
      children: [
        Text(
          valor.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildTarefaCard(Tarefa tarefa) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dataCriacao = _parseDateTime(tarefa.criadoEmString);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCorPrioridade(tarefa.prioridade),
          child: Text(
            tarefa.prioridade[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          tarefa.titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              tarefa.descricao ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(dataCriacao),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (tarefa.codigoTime != null && tarefa.codigoTime!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.group, size: 14, color: Colors.cyan[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Time: ${tarefa.codigoTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.cyan[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.cyan,
              onPressed: () => _abrirFormulario(tarefa),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                if (tarefa.id != null) {
                  _excluirTarefa(tarefa.id!, tarefa.titulo ?? '');
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    ); // final
  }
}