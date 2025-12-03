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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Tarefa> _tarefas = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _carregarTarefas();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _carregarTarefas() async {
    setState(() => _isLoading = true);

    try {
      final tarefas = await DatabaseHelper.instance.listarTarefas();
      setState(() {
        _tarefas = tarefas;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirTarefa(int id, String titulo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirmar exclusão',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text('Deseja realmente excluir a tarefa "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.excluirTarefa(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Tarefa excluída com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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
        return Colors.red.shade400;
      case 'media':
        return Colors.orange.shade400;
      case 'baixa':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getIconePrioridade(String? prioridade) {
    final p = _normalizePrioridade(prioridade);
    switch (p) {
      case 'alta':
        return Icons.arrow_upward_rounded;
      case 'media':
        return Icons.remove_rounded;
      case 'baixa':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.help_outline_rounded;
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tarefas Profissionais',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'RA 202310405 • Tema Aqua',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando tarefas...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _tarefas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.task_alt_rounded,
                          size: 80,
                          color: Colors.cyan.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhuma tarefa cadastrada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no botão + para começar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Resumo com design moderno
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.cyan, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildContadorModerno(
                            'Total',
                            _tarefas.length,
                            Icons.assignment_rounded,
                          ),
                          _buildDivisor(),
                          _buildContadorModerno(
                            'Alta',
                            _tarefas.where((t) => _normalizePrioridade(t.prioridade) == 'alta').length,
                            Icons.arrow_upward_rounded,
                          ),
                          _buildDivisor(),
                          _buildContadorModerno(
                            'Média',
                            _tarefas.where((t) => _normalizePrioridade(t.prioridade) == 'media').length,
                            Icons.remove_rounded,
                          ),
                          _buildDivisor(),
                          _buildContadorModerno(
                            'Baixa',
                            _tarefas.where((t) => _normalizePrioridade(t.prioridade) == 'baixa').length,
                            Icons.arrow_downward_rounded,
                          ),
                        ],
                      ),
                    ),
                    // Lista com animação
                    Expanded(
                      child: ListView.builder(
                        itemCount: _tarefas.length,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemBuilder: (context, index) {
                          return FadeTransition(
                            opacity: _animationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  index * 0.1,
                                  1.0,
                                  curve: Curves.easeOut,
                                ),
                              )),
                              child: _buildTarefaCard(_tarefas[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.cyan,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Tarefa'),
        elevation: 8,
      ),
    );
  }

  Widget _buildContadorModerno(String label, int valor, IconData icone) {
    return Column(
      children: [
        Icon(icone, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          valor.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildDivisor() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildTarefaCard(Tarefa tarefa) {
    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm');
    final dataCriacao = _parseDateTime(tarefa.criadoEmString);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Barra lateral colorida
              Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCorPrioridade(tarefa.prioridade),
                      _getCorPrioridade(tarefa.prioridade).withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Conteúdo
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título e prioridade
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tarefa.titulo ?? 'Sem título',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getCorPrioridade(tarefa.prioridade).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getIconePrioridade(tarefa.prioridade),
                                  size: 14,
                                  color: _getCorPrioridade(tarefa.prioridade),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tarefa.prioridade ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getCorPrioridade(tarefa.prioridade),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Descrição
                      if (tarefa.descricao != null && tarefa.descricao!.isNotEmpty)
                        Text(
                          tarefa.descricao!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Informações extras
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            Icons.calendar_today_rounded,
                            dateFormat.format(dataCriacao),
                            Colors.blue,
                          ),
                          if (tarefa.codigoTime != null && tarefa.codigoTime!.isNotEmpty)
                            _buildInfoChip(
                              Icons.group_rounded,
                              tarefa.codigoTime!,
                              Colors.cyan,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Botões de ação
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      color: Colors.cyan,
                      iconSize: 22,
                      onPressed: () => _abrirFormulario(tarefa),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      color: Colors.red.shade400,
                      iconSize: 22,
                      onPressed: () {
                        if (tarefa.id != null) {
                          _excluirTarefa(tarefa.id!, tarefa.titulo ?? '');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}