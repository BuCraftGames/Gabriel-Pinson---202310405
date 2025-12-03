import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class TarefaFormScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const TarefaFormScreen({super.key, this.tarefa});

  @override
  State<TarefaFormScreen> createState() => _TarefaFormScreenState();
}

class _TarefaFormScreenState extends State<TarefaFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _codigoTimeController;

  String _prioridade = 'Média';
  bool _isSalvando = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isEdicao => widget.tarefa != null;

  @override
  void initState() {
    super.initState();

    // Animações
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Controllers
    if (_isEdicao) {
      final t = widget.tarefa!;
      _tituloController = TextEditingController(text: t.titulo);
      _descricaoController = TextEditingController(text: t.descricao);
      _codigoTimeController = TextEditingController(text: t.codigoTime ?? '');
      _prioridade = t.prioridade ?? 'Média';
    } else {
      _tituloController = TextEditingController();
      _descricaoController = TextEditingController();
      _codigoTimeController = TextEditingController();
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    _codigoTimeController.dispose();
    super.dispose();
  }

  Color _getCorPrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Colors.red.shade400;
      case 'Média':
        return Colors.orange.shade400;
      case 'Baixa':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getIconePrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Icons.arrow_upward_rounded;
      case 'Média':
        return Icons.remove_rounded;
      case 'Baixa':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Preencha todos os campos obrigatórios'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSalvando = true);

    try {
      final tarefa = Tarefa(
        id: _isEdicao ? widget.tarefa!.id : null,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        prioridade: _prioridade,
        codigoTime: _codigoTimeController.text.trim().isEmpty
            ? null
            : _codigoTimeController.text.trim(),
        criadoEm: _isEdicao ? widget.tarefa!.criadoEm : DateTime.now(),
      );

      if (_isEdicao) {
        await DatabaseHelper.instance.atualizarTarefa(tarefa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Tarefa atualizada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        await DatabaseHelper.instance.inserirTarefa(tarefa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Tarefa criada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao salvar: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSalvando = false);
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isEdicao ? Icons.edit_rounded : Icons.add_task_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isEdicao ? 'Editar Tarefa' : 'Nova Tarefa',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Card de Informação
                if (!_isEdicao)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.withOpacity(0.1),
                          Colors.lightBlueAccent.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.info_rounded, color: Colors.cyan),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campos Obrigatórios',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Preencha título, descrição e prioridade',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Título
                _buildSectionLabel('Título', Icons.title_rounded, true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tituloController,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Ex: Implementar novo recurso',
                    prefixIcon: Icon(Icons.edit_rounded, color: Colors.cyan),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.cyan, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '⚠️ O título é obrigatório';
                    }
                    if (value.trim().length < 3) {
                      return '⚠️ O título deve ter pelo menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Descrição
                _buildSectionLabel('Descrição', Icons.description_rounded, true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descricaoController,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Descreva os detalhes da tarefa...',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.notes_rounded, color: Colors.cyan),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.cyan, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '⚠️ A descrição é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Prioridade
                _buildSectionLabel('Prioridade', Icons.flag_rounded, true),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: ['Baixa', 'Média', 'Alta'].map((prioridade) {
                      final isSelected = _prioridade == prioridade;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _prioridade = prioridade),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        _getCorPrioridade(prioridade),
                                        _getCorPrioridade(prioridade).withOpacity(0.7),
                                      ],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _getCorPrioridade(prioridade).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _getIconePrioridade(prioridade),
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  prioridade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Código do Time (Campo Extra)
                _buildSectionLabel('Código do Time', Icons.group_rounded, false),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codigoTimeController,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Ex: TEAM001, DEV-SQUAD-A',
                    prefixIcon: Icon(Icons.badge_rounded, color: Colors.cyan.shade300),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.cyan.shade300, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Botão Salvar
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSalvando ? null : _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSalvando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEdicao ? Icons.check_circle_rounded : Icons.save_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isEdicao ? 'Atualizar Tarefa' : 'Salvar Tarefa',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, bool obrigatorio) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.cyan),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        if (obrigatorio)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'OBRIGATÓRIO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
      ],
    );
  }
}