export interface Profile {
  id: string
  email: string
  full_name?: string | null
  crm?: string | null
  crm_nao_formado?: boolean
  address?: string | null
  phone?: string | null
  specialty?: string | null
  rqe?: string | null
}

export interface Shift {
  id: string
  user_id: string
  hospital_name: string
  date: string
  start_time: string
  end_time: string
  duration_hours: number
  value: number
  type: string
  informacoes?: string | null
  is_all_day: boolean
  is_completed: boolean
  recurrence_group_id?: string | null
  recurrence_rule?: unknown | null
  created_at: string
  updated_at: string
}

export interface Procedure {
  id: string
  user_id: string
  hospital_name: string
  date: string
  procedure_type: string
  procedure_type_id?: string | null
  value: number
  is_completed: boolean
  created_at: string
  updated_at: string
}

export interface ProcedureType {
  id: string
  user_id: string
  name: string
  default_value: number
  created_at: string
  updated_at: string
}

export interface RecurrenceRuleData {
  type: string // none, daily, weekly, monthly, monthlyWeekday, yearly, weekdays, custom
  interval: number
  daysOfWeek: number[] // 1=seg .. 7=dom
  endType: string // never, date, count
  endDate?: string | null
  endCount?: number | null
  weekOfMonth?: number | null
}

export interface RecurrenceDefinition {
  id: string
  user_id: string
  hospital_name: string
  start_date: string
  start_time: string
  end_time: string
  duration_hours: number
  value: number
  type: string
  informations?: string | null
  is_all_day: boolean
  recurrence_rule: RecurrenceRuleData
  end_date?: string | null
  excluded_dates: string[]
  paid_dates: string[]
  created_at: string
  updated_at: string
}

export interface BlockedDay {
  id: string
  user_id: string
  date: string
  label: string
  created_at: string
  updated_at: string
}

export interface Note {
  id: string
  user_id: string
  title: string
  content: string
  created_at: string
  updated_at: string
}

export interface NoteArchive extends Note {
  archived_at: string
}

export interface Patient {
  id: string
  user_id: string
  initials: string
  age?: number | null
  age_unit: string
  admission_date?: string | null
  bed: string
  history: string
  devices: string
  diagnosis: string
  antibiotics: string
  vasoactive_drugs: string
  exams: string
  pending: string
  observations: string
  created_at: string
  updated_at: string
}

export interface PatientArchive extends Patient {
  archived_at: string
}

export interface MedList {
  id: string
  user_id: string
  nome: string
  medicamento_ids: string[]
  created_at: string
}

export interface AppConfig {
  key: string
  value: string
  updated_at: string
}

export interface Feedback {
  id: string
  user_id: string
  user_email: string
  tipo: 'sugestao' | 'bug' | 'ideia'
  mensagem: string
  status: 'pendente' | 'em_analise' | 'resolvido'
  created_at: string
}

export interface AdminUser {
  id: string
  email: string
  created_at: string
  last_sign_in_at?: string | null
  email_confirmed_at?: string | null
  banned_until?: string | null
  user_metadata?: Record<string, unknown>
  access_count?: number
  country?: string | null
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

export interface PushNotification {
  id: number
  created_by?: string | null
  target_type: 'all' | 'user' | 'users' | 'segment'
  target_value?: string | null
  title: string
  body: string
  link?: string | null
  sent_at: string
  tokens_count: number
  source: string
}

export interface PushSchedule {
  id: number
  created_by?: string | null
  target_type: 'all' | 'user' | 'users' | 'segment'
  target_value?: string | null
  title: string
  body: string
  link?: string | null
  scheduled_at: string
  recurrence?: string | null
  is_active: boolean
  last_run_at?: string | null
  created_at: string
}
