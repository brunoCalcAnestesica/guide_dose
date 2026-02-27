import type {
  User, PatientNote, GeneralNote, Shift, Feedback,
  AppVersion, AccessLog, MedList, NewsItem, BillingInfo,
} from '../types'

export const mockNews: NewsItem[] = [
  {
    id: '1',
    titulo: 'Nova atualização do GuideDose 2.0',
    resumo: 'Confira as novidades da versão 2.0 com novos cálculos e interface repaginada.',
    data: '2026-02-20',
  },
  {
    id: '2',
    titulo: 'Protocolo de Sepse atualizado',
    resumo: 'Os algoritmos de tratamento de sepse foram revisados conforme novas diretrizes do Surviving Sepsis 2025.',
    data: '2026-02-15',
  },
  {
    id: '3',
    titulo: 'Farmacoteca ampliada',
    resumo: 'Mais de 200 medicamentos com doses, diluições e orientações clínicas prontas para uso.',
    data: '2026-02-01',
  },
]

export const mockPatientNotes: PatientNote[] = [
  {
    id: 'pn1',
    titulo: 'Evolução UTI - Leito 12',
    nomePaciente: 'João S.',
    data: '2026-02-27',
    texto: 'Paciente estável, reduzindo noradrenalina. Mantém antibioticoterapia.',
    anexos: [],
    userId: 'u1',
  },
  {
    id: 'pn2',
    titulo: 'Admissão PS',
    nomePaciente: 'Maria L.',
    data: '2026-02-26',
    texto: 'Admitida com dor torácica. ECG sem supra. Troponina pendente.',
    anexos: [{ id: 'a1', fileUrl: '#', fileName: 'ecg_maria.pdf', createdAt: '2026-02-26' }],
    userId: 'u1',
  },
]

export const mockGeneralNotes: GeneralNote[] = [
  {
    id: 'gn1',
    titulo: 'Checklist intubação',
    texto: 'Pré-oxigenação, monitorização, aspiração, drogas, plano B (bougie/máscara laríngea).',
    tags: ['Plantão', 'UTI'],
    data: '2026-02-25',
    userId: 'u1',
  },
  {
    id: 'gn2',
    titulo: 'Ideia de estudo',
    texto: 'Revisão sobre vasopressores na sepse - comparar noradrenalina x vasopressina.',
    tags: ['Ideia', 'Estudo'],
    data: '2026-02-20',
    userId: 'u1',
  },
]

export const mockShifts: Shift[] = [
  {
    id: 's1',
    data: '2026-03-01',
    local: 'Hospital São Lucas - UTI',
    tipoPlantao: 'Diurno',
    horarioInicio: '07:00',
    horarioFim: '19:00',
    observacoes: 'Troca com Dr. Pedro',
    userId: 'u1',
  },
  {
    id: 's2',
    data: '2026-03-03',
    local: 'UPA Central',
    tipoPlantao: 'Noturno',
    horarioInicio: '19:00',
    horarioFim: '07:00',
    userId: 'u1',
  },
  {
    id: 's3',
    data: '2026-03-07',
    local: 'Hospital São Lucas - PS',
    tipoPlantao: 'Diurno',
    horarioInicio: '07:00',
    horarioFim: '19:00',
    userId: 'u1',
  },
]

export const mockFeedbacks: Feedback[] = [
  {
    id: 'f1',
    userId: 'u2',
    userEmail: 'dra.ana@email.com',
    tipo: 'sugestao',
    mensagem: 'Seria ótimo ter um modo offline completo para usar em áreas sem sinal.',
    status: 'pendente',
    data: '2026-02-24',
  },
  {
    id: 'f2',
    userId: 'u3',
    userEmail: 'dr.carlos@email.com',
    tipo: 'bug',
    mensagem: 'O cálculo de clearance de creatinina não aceita peso acima de 150kg.',
    status: 'em_analise',
    data: '2026-02-22',
  },
]

export const mockUsers: User[] = [
  {
    id: 'u1',
    email: 'bhdaroz@gmail.com',
    nome: 'Bruno Daroz',
    crm: '123456-SP',
    especialidade: 'Medicina Intensiva',
    dataCadastro: '2025-01-10',
    status: 'ativo',
    tipo: 'admin',
    ultimoAcesso: '2026-02-27',
    totalLogins: 342,
    pais: 'Brasil',
    cidade: 'São Paulo',
    deviceType: 'iOS',
  },
  {
    id: 'u2',
    email: 'dra.ana@email.com',
    nome: 'Ana Beatriz Costa',
    crm: '654321-RJ',
    especialidade: 'Clínica Médica',
    dataCadastro: '2025-03-15',
    status: 'ativo',
    tipo: 'usuario',
    ultimoAcesso: '2026-02-26',
    totalLogins: 87,
    pais: 'Brasil',
    cidade: 'Rio de Janeiro',
    deviceType: 'Android',
  },
  {
    id: 'u3',
    email: 'dr.carlos@email.com',
    nome: 'Carlos Eduardo Lima',
    crm: '789012-MG',
    especialidade: 'Emergência',
    dataCadastro: '2025-06-20',
    status: 'ativo',
    tipo: 'usuario',
    ultimoAcesso: '2026-02-25',
    totalLogins: 45,
    pais: 'Brasil',
    cidade: 'Belo Horizonte',
    deviceType: 'iOS',
  },
]

export const mockAppVersion: AppVersion = {
  id: 'v1',
  currentVersion: '2.0.1',
  minRequiredVersion: '1.8.0',
  changelog: 'Correções de bugs na farmacoteca e melhorias de performance nos cálculos.',
  dataPublicacao: '2026-02-15',
  recomendada: true,
  obrigatoria: false,
}

export const mockAccessLogs: AccessLog[] = [
  { id: 'l1', userId: 'u1', email: 'bhdaroz@gmail.com', dataHora: '2026-02-27T08:30:00', ip: '189.40.xx.xx', acao: 'login' },
  { id: 'l2', userId: 'u2', email: 'dra.ana@email.com', dataHora: '2026-02-27T09:15:00', ip: '200.155.xx.xx', acao: 'login' },
  { id: 'l3', userId: 'u2', email: 'dra.ana@email.com', dataHora: '2026-02-27T12:00:00', ip: '200.155.xx.xx', acao: 'logout' },
  { id: 'l4', userId: 'u3', email: 'dr.carlos@email.com', dataHora: '2026-02-26T22:10:00', ip: '177.80.xx.xx', acao: 'login' },
]

export const mockMedLists: MedList[] = [
  { id: 'ml1', titulo: 'Drogas Vasoativas', medicamentos: ['Noradrenalina', 'Dobutamina', 'Vasopressina', 'Adrenalina'], userId: 'u1' },
  { id: 'ml2', titulo: 'Sedação UTI', medicamentos: ['Midazolam', 'Fentanil', 'Propofol', 'Dexmedetomidina', 'Cetamina'], userId: 'u1' },
]

export const mockBilling: BillingInfo[] = [
  { id: 'b1', userId: 'u1', plano: 'premium', statusPagamento: 'ativo', dataInicio: '2025-01-10', dataRenovacao: '2026-01-10' },
  { id: 'b2', userId: 'u2', plano: 'free', statusPagamento: 'ativo', dataInicio: '2025-03-15' },
  { id: 'b3', userId: 'u3', plano: 'premium', statusPagamento: 'pendente', dataInicio: '2025-06-20', dataRenovacao: '2026-06-20' },
]

export const mockNotifications = [
  { id: 'n1', mensagem: 'Nova versão 2.0.1 do GuideDose disponível!', data: '2026-02-15', lida: false },
  { id: 'n2', mensagem: 'Seu plantão começa amanhã às 07:00 no Hospital São Lucas.', data: '2026-02-28', lida: false },
  { id: 'n3', mensagem: 'Protocolo de Sepse atualizado – confira na farmacoteca.', data: '2026-02-10', lida: true },
]
