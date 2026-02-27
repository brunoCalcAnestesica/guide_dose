export interface User {
  id: string
  email: string
  nome?: string
  crm?: string
  especialidade?: string
  dataCadastro: string
  status: 'ativo' | 'bloqueado'
  tipo: 'usuario' | 'admin'
  ultimoAcesso?: string
  totalLogins?: number
  pais?: string
  cidade?: string
  deviceType?: string
}

export interface Attachment {
  id: string
  fileUrl: string
  fileName: string
  createdAt: string
}

export interface PatientNote {
  id: string
  titulo: string
  nomePaciente: string
  data: string
  texto: string
  anexos: Attachment[]
  userId: string
}

export interface GeneralNote {
  id: string
  titulo: string
  texto: string
  tags: string[]
  data: string
  userId: string
}

export interface Shift {
  id: string
  data: string
  local: string
  tipoPlantao: string
  horarioInicio: string
  horarioFim: string
  observacoes?: string
  userId: string
}

export interface UserSettings {
  nome: string
  email: string
  crm: string
  especialidade: string
  tema: 'claro' | 'escuro'
  idioma: string
  notificacoes: boolean
}

export interface Feedback {
  id: string
  userId: string
  userEmail: string
  tipo: 'sugestao' | 'bug' | 'ideia'
  mensagem: string
  status: 'pendente' | 'em_analise' | 'resolvido'
  data: string
}

export interface AppVersion {
  id: string
  currentVersion: string
  minRequiredVersion: string
  changelog: string
  dataPublicacao: string
  recomendada: boolean
  obrigatoria: boolean
}

export interface AccessLog {
  id: string
  userId: string
  email: string
  dataHora: string
  ip: string
  acao: 'login' | 'logout' | 'acessoPagina'
}

export interface MedList {
  id: string
  titulo: string
  medicamentos: string[]
  userId: string
}

export interface NewsItem {
  id: string
  titulo: string
  resumo: string
  data: string
  conteudo?: string
}

export interface BillingInfo {
  id: string
  userId: string
  plano: 'free' | 'premium'
  statusPagamento: 'ativo' | 'pendente' | 'cancelado'
  dataInicio: string
  dataRenovacao?: string
}
