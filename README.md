# Mini Cadastro de Tarefas Profissionais

## 📋 Descrição do Projeto
Aplicativo Flutter para gerenciamento de tarefas profissionais, permitindo criar, visualizar, editar e excluir tarefas com sistema de prioridades e organização por times.

## 👨‍💻 Dados do Aluno
- **Nome:** Gabriel Pinson
- **RA:** 202310405

## 🎯 Campo Personalizado
- **Campo Extra:** `codigoTime` (String, opcional)
- **Descrição:** Código de identificação do time responsável pela tarefa
- **Exemplo:** TEAM001, DEV-SQUAD-A, BACKEND-TEAM

## 🎨 Tema Aplicado
- **Tema:** temaAqua
- **Cor Primária:** Cyan
- **Cor Secundária:** Light Blue Accent
- **Referência:** Linha 20 da tabela (RA 202310405)

## 💾 Banco de Dados
- **Nome do arquivo:** `tarefas_202310405.db`
- **Tabela:** `tarefas`
- **Campos:**
  - `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
  - `titulo` (TEXT NOT NULL)
  - `descricao` (TEXT NOT NULL)
  - `prioridade` (TEXT NOT NULL)
  - `criadoEm` (TEXT NOT NULL)
  - `codigoTime` (TEXT) - Campo personalizado

## 🚀 Funcionalidades Implementadas
✅ CRUD completo de tarefas  
✅ Listagem com ListView.builder  
✅ Validação de campos obrigatórios  
✅ Sistema de prioridades (Alta, Média, Baixa)  
✅ Campo extra personalizado (Código do Time)  
✅ Design moderno com tema Aqua  
✅ Animações e transições suaves  
✅ Confirmação antes de excluir  
✅ Feedback visual com SnackBars  

## 🛠️ Tecnologias Utilizadas
- Flutter 3.x
- Dart
- sqflite (Banco de dados local)
- path_provider (Gerenciamento de caminhos)
- intl (Formatação de datas)

## 📦 Dependências
```yaml