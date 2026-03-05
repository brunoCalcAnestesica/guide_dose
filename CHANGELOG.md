# Changelog

Todas as mudanças notáveis do **Guide Dose ®** são documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [3.7.0] - 2025-02-27

### Adicionado

- **Widgets na tela inicial (Android)**  
  - Widget de calendário com grade do mês e destaque do dia atual  
  - Widget de agenda com lista de eventos do dia  
  - Atualização automática dos widgets ao abrir o app e ao retornar do segundo plano  

- **Módulo Escala**  
  - Gestão de plantões com hospitais, procedimentos e recorrência  
  - Divisor de plantão para repartir horas entre colegas  
  - Dias bloqueados e anotações por dia  
  - Lista de pacientes vinculada ao módulo  
  - Sincronização com Supabase (quando configurado)  
  - Lembrete de repasse de plantão via notificações locais  
  - Filtros por hospital e produção  

- **Sistema de feedback (Supabase)**  
  - Tabela `feedback` para sugestões, bugs e ideias  
  - Políticas RLS para usuários enviarem e visualizarem apenas o próprio feedback  
  - Integração preparada para envio a partir do app  

- **Verificação de atualização**  
  - Diálogo “Nova versão disponível” com link para App Store / Play Store  
  - Controle para não exibir o aviso em excesso  

- **Suporte a múltiplos idiomas**  
  - Português, inglês, espanhol e chinês  

- **Ícones e splash**  
  - Novos ícones adaptativos (Android 12+) e splash em múltiplas densidades  
  - Assets de ícone e splash para iOS (xcassets)  

- **Catálogo de medicamentos**  
  - Novos medicamentos e ajustes em diversos JSONs da pasta `assets/medicamentos/`  

### Melhorado

- Inicialização do Supabase opcional (app funciona sem configuração)  
- Serviço de backup e estado de sincronização persistido localmente  
- Atualização ao retornar do segundo plano: sincronização de plantões, hospitais e dias bloqueados  
- Deep links para widgets abrindo o app na data selecionada  

### Técnico

- Dependências: `home_widget`, `flutter_local_notifications`, `timezone`, `device_calendar`, `fl_chart`, `provider`, `uuid`  
- Módulo Escala com providers (Shift, Hospital, BlockedDay, Note, Patient, Procedure, ProcedureType) e repositórios locais  
- Widgets Android: `CalendarWidgetProvider`, `AgendaWidgetProvider` e layouts em `res/layout/`  

---

## [3.6.x] e anteriores

As versões anteriores não possuem changelog estruturado neste arquivo.

[3.7.0]: https://github.com/.../releases/tag/v3.7.0
