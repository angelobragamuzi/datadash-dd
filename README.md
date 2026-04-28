# DataDash

DataDash é um aplicativo de analytics local-first desenvolvido em Flutter para importar dados tabulares, preparar a base, montar dashboards e exportar resultados em PDF.

## Visão geral

O projeto foi pensado para uma experiência mobile-first, com foco em produtividade e operação offline:

- Importação de arquivos locais (`.csv`, `.xls`, `.xlsx`)
- Tratamento e preparação de dados (renomear/ignorar colunas e filtros)
- Criação de dashboards com widgets configuráveis
- Visualização de indicadores e gráficos
- Exportação para PDF e compartilhamento
- Persistência local com Hive (sem backend)

## Galeria (prints do aplicativo)

> Prints capturados da versão Web local do app (`build/web`).

| Início | Dashboards |
|---|---|
| ![Tela Inicial](docs/screenshots/01-home.png) | ![Dashboards](docs/screenshots/02-dashboards-empty.png) |

| Editor de Dashboard | Configuração de Widget |
|---|---|
| ![Editor](docs/screenshots/04-dashboard-editor.png) | ![Configuração de Widget](docs/screenshots/05-widget-config.png) |

| Arquivos Importados | Prévia de Dados |
|---|---|
| ![Arquivos](docs/screenshots/06-imported-files.png) | ![Prévia](docs/screenshots/07-data-preview.png) |

| Configurações |
|---|
| ![Configurações](docs/screenshots/08-settings.png) |

## Funcionalidades

### 1. Shell do aplicativo

- Splash screen
- Navegação principal por `NavigationBar`
- Áreas: `Início`, `Dashboards`, `Arquivos`, `Configurações`
- Tema claro/escuro com persistência

### 2. Importação de dados

- Seleção de arquivo local com `file_picker`
- Suporte a `CSV`, `XLS` e `XLSX`
- Parsing e normalização em `DataProcessingService`

### 3. Preparação da base

- Renomear colunas
- Ignorar colunas não relevantes
- Criar e remover filtros de dados
- Prévia tabular antes de criar o dashboard

### 4. Dashboard builder

- Criar/renomear/remover dashboards
- Adicionar/editar/remover widgets
- Reordenar widgets
- Associação do dashboard com dataset

### 5. Widgets e visualizações

Tipos disponíveis:

- Indicador numérico
- Gráfico de barras
- Gráfico de linhas
- Gráfico de pizza
- Tabela resumida

### 6. Visualização e exportação

- Tela de visualização com filtros globais
- Exportação para PDF
- Impressão/preview
- Compartilhamento via apps do sistema

### 7. Tutorial guiado

- Onboarding com `showcaseview`
- Tutoriais distribuídos nas principais páginas
- Registro de progresso por usuário (persistido localmente)

## Stack técnica

- **Framework:** Flutter (Material 3)
- **Linguagem:** Dart
- **Estado:** Provider (`ChangeNotifier` via `AppController`)
- **Persistência local:** Hive
- **Gráficos:** fl_chart
- **Importação:** file_picker, csv, excel
- **Exportação:** pdf, printing, share_plus
- **UI/Assets:** flutter_svg, google_fonts

## Arquitetura

Estrutura em camadas com organização por feature:

- `lib/core/`: app controller, tema, rotas, utilitários
- `lib/data/`: models, services e repositories
- `lib/features/`: páginas por domínio funcional
- `lib/shared/`: componentes reutilizáveis de UI

### Fluxo resumido

1. Usuário importa arquivo
2. Ajusta colunas e filtros na prévia
3. Cria dashboard
4. Configura widgets
5. Visualiza resultados
6. Exporta/compartilha PDF

## Estrutura de pastas

```text
lib/
  core/
  data/
  features/
  shared/
  main.dart
assets/
  images/
  icon/
docs/
  screenshots/
```

## Como executar

### Pré-requisitos

- Flutter SDK instalado
- Dart SDK compatível com o projeto
- Chrome, Android Emulator ou dispositivo físico

### Instalação

```bash
git clone <url-do-repositorio>
cd datadash
flutter pub get
```

### Rodar em desenvolvimento

```bash
flutter run
```

### Rodar no Chrome

```bash
flutter run -d chrome
```

### Análise estática

```bash
flutter analyze
```

### Build Web

```bash
flutter build web
```

### Build Android (APK)

```bash
flutter build apk --release
```

## Persistência local

Boxes Hive utilizadas:

- `imports_box`
- `dashboards_box`
- `settings_box`

## Qualidade e UX

- Interface responsiva para diferentes larguras
- Suporte a tema claro/escuro
- Estados vazios com ilustrações centralizadas
- Feedback visual para ações críticas

## Roadmap sugerido

- Templates prontos de dashboard
- Mais tipos de visualização
- Exportação para PNG/JPG
- Busca e filtros avançados na lista de dashboards
- Internacionalização (i18n)

## Licença

Defina a licença do projeto (ex.: MIT) neste repositório.
