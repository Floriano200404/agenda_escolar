# 📚 Agenda Escolar

Aplicativo Flutter para organização de **provas, trabalhos e tarefas** escolares.
Cada usuário tem sua própria conta e gerencia suas atividades, com um painel que
mostra de forma rápida o que está pendente, atrasado e prestes a vencer.

> Tema **21 — Agenda Escolar**

---

## 👥 Integrantes da dupla

- _Integrante 1: (preencher)_
- _Integrante 2: (preencher)_

---

## 📝 Descrição do app

A **Agenda Escolar** ajuda estudantes a não perderem prazos. Depois de criar uma
conta e fazer login, o aluno cadastra suas atividades informando título,
disciplina, tipo (prova, trabalho ou tarefa), data de entrega e uma descrição
opcional. As atividades ficam salvas localmente no aparelho e podem ser
listadas, editadas, marcadas como concluídas e excluídas a qualquer momento.

O app foi pensado para o dia a dia escolar: serve para qualquer aluno que queira
um lugar simples para organizar o que precisa estudar e entregar. Os dados
gerenciados são os **usuários** (nome, e-mail e senha) e as **atividades
escolares** vinculadas a cada usuário.

## ✨ Funcionalidade aplicada ao tema

No topo da lista há um **painel de resumo** que calcula, a partir das atividades
cadastradas, três indicadores úteis:

- **Pendentes** — atividades ainda não concluídas;
- **Atrasadas** — cujo prazo já passou e não foram concluídas;
- **A vencer (7 dias)** — que vencem dentro da próxima semana.

Além disso, é possível **filtrar a lista por disciplina**, e o painel reflete o
filtro escolhido. Assim o aluno responde rápido a perguntas como _"quantas
pendências eu tenho em Matemática?"_ — esse uso inteligente dos dados é a
funcionalidade aplicada ao tema.

---

## 🛠️ Tecnologias

| Recurso | Detalhe |
|---|---|
| Framework | **Flutter 3.44.0** (Dart 3.12.0) |
| Banco de dados | **SQLite** (via pacote `sqflite`) |
| Estado | `provider` (usuário logado) |
| Senhas | guardadas como **hash SHA-256** (`crypto`), nunca em texto puro |
| Datas | `intl` (formatação em pt-BR) |

### Duas tabelas no banco
- **`usuarios`** — `id`, `nome`, `email`, `senha_hash`, `criado_em`
- **`atividades`** — `id`, `usuario_id` (FK), `titulo`, `descricao`, `disciplina`, `tipo`, `data_entrega`, `concluida`, `criado_em`

---

## 🚀 Como clonar e rodar

> Pré-requisito: **Flutter 3.44.0** instalado (`flutter --version` para conferir).
> Para rodar no celular/emulador **Android**, tenha o Android Studio + um
> emulador (ou um aparelho com depuração USB ligada).

```bash
# 1. Clonar o repositório
git clone <LINK_DO_REPOSITORIO>
cd agenda_escolar

# 2. Baixar as dependências
flutter pub get

# 3. Conferir os dispositivos disponíveis
flutter devices

# 4. Rodar o app (escolha o dispositivo)
flutter run                 # usa o dispositivo padrão
# ou, para escolher explicitamente:
flutter run -d emulator-5554   # exemplo de emulador Android
```

O banco de dados SQLite é criado **automaticamente** na primeira execução — não
precisa configurar nada.

### Rodar os testes (opcional)

```bash
flutter test
```

Inclui testes do hash de senha, da tela de login e um teste de integração que
executa o **CRUD completo no SQLite** real.

---

## 📁 Estrutura do projeto

```
lib/
├── main.dart                      # ponto de entrada: configura banco, locale e provider
├── models/
│   ├── usuario.dart               # modelo do usuário
│   └── atividade.dart             # modelo da atividade (+ enum TipoAtividade)
├── database/
│   └── database_helper.dart       # conexão SQLite e criação das tabelas
├── repositories/
│   ├── usuario_repository.dart    # cadastro e autenticação
│   └── atividade_repository.dart  # CRUD das atividades
├── providers/
│   └── auth_provider.dart         # quem está logado (estado global)
├── screens/
│   ├── login_screen.dart
│   ├── cadastro_screen.dart
│   ├── home_screen.dart           # painel + filtro + lista
│   └── form_atividade_screen.dart # criar e editar
├── widgets/
│   ├── painel_resumo.dart         # funcionalidade aplicada (contadores)
│   └── atividade_card.dart        # item da lista
└── utils/
    ├── app_theme.dart             # cores e tema
    ├── data_util.dart             # formatação de datas
    └── senha_util.dart            # hash de senha
```

---

## 🎥 Vídeo de apresentação

_Link do YouTube (não listado): (preencher)_

---

## ✅ Checklist de requisitos

- [x] Tela de login com usuário e senha
- [x] Tela de cadastro de novo usuário
- [x] Duas tabelas no banco (usuários + atividades)
- [x] CRUD completo (cadastrar, listar, editar, excluir)
- [x] Exclusão com confirmação
- [x] Navegação entre telas
- [x] Funcionalidade aplicada ao tema (painel + filtro por disciplina)
