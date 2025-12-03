import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'package:intl/intl.dart';

class TarefaFormScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const TarefaFormScreen({super.key, this.tarefa});

  @override
  State<TarefaFormScreen> createState() => _TarefaFormScreenState();
}

class _TarefaFormScreenState extends State<TarefaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _codigoTimeController;

  String _prioridade = 'Média';

  bool get _isEdicao => widget.tarefa != null;

  @override
  void initState() {
    super.initState();

    if (_isEdicao) {
      final t = widget.tarefa!;
      _tituloController = TextEditingController(text: t.titulo);
      _descricaoController = TextEditingController(text: t.descricao);
      _codigoTimeController = TextEditingController(text: t.codigoTime ?? '');
      _prioridade = t.prioridade;
    } else {
      _tituloController = TextEditingController();
      _descricaoController = TextEditingController();
      _codigoTimeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _codigoTimeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

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
            const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
          );
        }
      } else {
        await DatabaseHelper.instance.inserirTarefa(tarefa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa criada com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: Colors.cyan,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Prioridade
            DropdownButtonFormField<String>(
              value: _prioridade,
              decoration: const InputDecoration(
                labelText: 'Prioridade *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: ['Baixa', 'Média', 'Alta']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => _prioridade = value!),
            ),
            const SizedBox(height: 16),

            // Campo Extra Personalizado - Código Time
            TextFormField(
              controller: _codigoTimeController,
              decoration: const InputDecoration(
                labelText: 'Código do Time',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
                helperText: 'Campo opcional - Ex: TEAM001',
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: Text(_isEdicao ? 'Atualizar' : 'Salvar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}