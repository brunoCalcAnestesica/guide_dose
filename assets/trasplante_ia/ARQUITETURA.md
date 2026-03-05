# Arquitetura da IA Médica

## Visão Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                     │
│  │ MedicalAIScreen │───▶│  MedicalAIPage  │                     │
│  │   (AppBar)      │    │   (Chat UI)     │                     │
│  └─────────────────┘    └────────┬────────┘                     │
│                                  │                               │
│                    ┌─────────────┼─────────────┐                │
│                    ▼             ▼             ▼                │
│          ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│          │OpenAIService │ │PdfDocService │ │ChatPdfService│    │
│          │ (Núcleo IA)  │ │(Anexar PDFs) │ │(Gerar PDFs)  │    │
│          └──────┬───────┘ └──────────────┘ └──────────────┘    │
│                 │                                                │
│          ┌──────┴───────┐                                       │
│          │OpenAIConfig  │                                       │
│          │  (.env)      │                                       │
│          └──────┬───────┘                                       │
└─────────────────┼───────────────────────────────────────────────┘
                  │
                  ▼ HTTP POST
┌─────────────────────────────────────────────────────────────────┐
│                      Supabase                                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────┐                │
│  │            Edge Function                      │                │
│  │           openai-proxy                        │                │
│  │  ┌─────────────────────────────────────┐    │                │
│  │  │ 1. Recebe request do app            │    │                │
│  │  │ 2. Adiciona OPENAI_API_KEY          │    │                │
│  │  │ 3. Encaminha para OpenAI            │    │                │
│  │  │ 4. Retorna resposta                 │    │                │
│  │  └─────────────────────────────────────┘    │                │
│  └─────────────────────────────────────────────┘                │
│                                                                  │
│  ┌─────────────────────┐  ┌─────────────────────┐               │
│  │sofia_knowledge_base │  │ ai_knowledge_base   │               │
│  │ (Compartilhada)     │  │ (Por usuário)       │               │
│  └─────────────────────┘  └─────────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
                  │
                  ▼ HTTP POST
┌─────────────────────────────────────────────────────────────────┐
│                        OpenAI API                                │
│                   api.openai.com/v1/chat/completions            │
└─────────────────────────────────────────────────────────────────┘
```

## Fluxo de uma Mensagem

```
1. Usuário digita mensagem
          │
          ▼
2. MedicalAIPage captura texto
          │
          ▼
3. OpenAIService monta payload:
   - System prompt (personalidade da IA)
   - Contexto do paciente (SharedData)
   - Histórico recente (últimas 12 mensagens)
   - Mensagem atual
          │
          ▼
4. HTTP POST para Edge Function
          │
          ▼
5. Edge Function:
   - Valida request
   - Injeta OPENAI_API_KEY
   - Encaminha para OpenAI
          │
          ▼
6. OpenAI processa e retorna
          │
          ▼
7. Edge Function repassa resposta
          │
          ▼
8. OpenAIService processa resposta:
   - Verifica se é PDF ([PDF:Título])
   - Retorna conteúdo
          │
          ▼
9. MedicalAIPage exibe no chat
```

## Componentes

### Frontend (Flutter)

| Arquivo | Responsabilidade |
|---------|------------------|
| `medical_ai_page.dart` | UI do chat, gerenciamento de estado, animações |
| `medical_ai_screen.dart` | Wrapper com AppBar |
| `openai_service.dart` | Comunicação com IA, montagem do prompt |
| `pdf_document_service.dart` | Processar PDFs anexados |
| `chat_pdf_service.dart` | Gerar PDFs a partir do chat |
| `openai_config.dart` | Leitura de configurações do .env |
| `shared_data.dart` | Dados do paciente atual |
| `app_colors.dart` | Cores do tema |

### Backend (Supabase)

| Componente | Responsabilidade |
|------------|------------------|
| `openai-proxy` | Edge Function que esconde a chave da OpenAI |
| `sofia_knowledge_base` | Tabela de conhecimento compartilhado |
| `ai_knowledge_base` | Tabela de conhecimento por usuário |

## Modos de Resposta

### Preciso
- Respostas curtas e diretas
- Máximo 3-4 parágrafos
- Foco no essencial
- Ideal para consultas rápidas

### Completo
- Explicações detalhadas
- Contexto e fundamentação
- Exemplos quando apropriado
- Ideal para aprendizado

## Geração de PDF

Quando a IA detecta pedido de documento (receita, laudo, etc.):

1. Responde com `[PDF:Título do Documento]`
2. Frontend detecta o marcador
3. Exibe conteúdo formatado
4. Oferece botão "Exportar PDF"
5. Gera PDF profissional com:
   - Logo do app
   - Data/hora
   - Dados do paciente
   - Conteúdo formatado
   - Paginação

## Persistência

- **Mensagens**: SharedPreferences (local)
- **Modo de resposta**: SharedPreferences (local)
- **Contexto do paciente**: SharedData (memória)

## Segurança

1. **Chave da OpenAI**: Armazenada apenas no Supabase
2. **Edge Function**: Protegida por autenticação Supabase
3. **RLS**: Tabelas com Row Level Security
4. **Dados sensíveis**: Não persistidos no servidor
