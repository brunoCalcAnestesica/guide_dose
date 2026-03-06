import { useState, useEffect, useMemo } from 'react'
import { useParams, Link } from 'react-router-dom'
import { Card } from '../../components/ui/Card'
import { Tabs } from '../../components/ui/Tabs'
import { Badge } from '../../components/ui/Badge'
import { adminQuery, adminListUsers } from '../../lib/api'
import { expandRecurrenceRules } from '../../lib/recurrence'
import type { AdminUser, Profile, Shift, Patient, PatientArchive, Note, NoteArchive, MedList, RecurrenceDefinition } from '../../types'

const tabList = [
  { id: 'agenda', label: 'Agenda' },
  { id: 'producao', label: 'Produção' },
  { id: 'anotacoes', label: 'Anotações' },
  { id: 'pacientes', label: 'Pacientes' },
  { id: 'medicamentos', label: 'Listas de Medicamentos' },
  { id: 'config', label: 'Configurações' },
]

const WEEKDAY_LABELS = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
const MONTH_LABELS = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
]

const TYPE_COLORS: Record<string, string> = {
  'Diurno': 'bg-blue-500',
  'Noturno': 'bg-indigo-600',
  '12h': 'bg-amber-500',
  '24h': 'bg-red-500',
  'Extra': 'bg-emerald-500',
}

function toIso(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

export default function UserDetail() {
  const { id } = useParams<{ id: string }>()
  const [activeTab, setActiveTab] = useState('agenda')
  const [loading, setLoading] = useState(true)
  const [authUser, setAuthUser] = useState<AdminUser | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [shifts, setShifts] = useState<Shift[]>([])
  const [patients, setPatients] = useState<Patient[]>([])
  const [patientsArchive, setPatientsArchive] = useState<PatientArchive[]>([])
  const [notes, setNotes] = useState<Note[]>([])
  const [notesArchive, setNotesArchive] = useState<NoteArchive[]>([])
  const [medLists, setMedLists] = useState<MedList[]>([])

  const today = useMemo(() => new Date(), [])
  const [viewYear, setViewYear] = useState(today.getFullYear())
  const [viewMonth, setViewMonth] = useState(today.getMonth())
  const [selectedDate, setSelectedDate] = useState<string>(toIso(today))

  useEffect(() => {
    if (!id) return

    const load = async () => {
      setLoading(true)

      const [usersRes, profileRes, shiftsRes, rulesRes, patientsRes, patientsArchiveRes, notesRes, notesArchiveRes, medRes] = await Promise.all([
        adminListUsers(),
        adminQuery<Profile[]>('profiles', { id: `eq.${id}`, select: '*' }),
        adminQuery<Shift[]>('shifts', { user_id: `eq.${id}`, order: 'date.desc', select: '*' }),
        adminQuery<RecurrenceDefinition[]>('recurrence_rules', { user_id: `eq.${id}`, select: '*' }),
        adminQuery<Patient[]>('patients', { user_id: `eq.${id}`, order: 'updated_at.desc', select: '*' }),
        adminQuery<PatientArchive[]>('patients_archive', { user_id: `eq.${id}`, order: 'archived_at.desc', select: '*' }),
        adminQuery<Note[]>('notes', { user_id: `eq.${id}`, order: 'updated_at.desc', select: '*' }),
        adminQuery<NoteArchive[]>('notes_archive', { user_id: `eq.${id}`, order: 'archived_at.desc', select: '*' }),
        adminQuery<MedList[]>('med_lists', { user_id: `eq.${id}`, select: '*' }),
      ])

      const allUsers = (usersRes.data as AdminUser[]) ?? []
      setAuthUser(allUsers.find(u => u.id === id) ?? null)

      const profiles = profileRes.data ?? []
      setProfile(profiles.length > 0 ? profiles[0] : null)

      const standalone = shiftsRes.data ?? []
      const rules = rulesRes.data ?? []

      const now = new Date()
      const rangeStart = new Date(now.getFullYear(), now.getMonth() - 2, 1)
      const rangeEnd = new Date(now.getFullYear(), now.getMonth() + 4, 0)
      const virtualShifts = expandRecurrenceRules(rules, rangeStart, rangeEnd)

      const virtualIds = new Set(virtualShifts.map(s => s.id))
      const filtered = standalone.filter(s => !virtualIds.has(s.id) && !s.recurrence_group_id)
      const merged = [...filtered, ...virtualShifts].sort((a, b) => a.date.localeCompare(b.date))

      setShifts(merged)
      setPatients(patientsRes.data ?? [])
      setPatientsArchive(patientsArchiveRes.data ?? [])
      setNotes(notesRes.data ?? [])
      setNotesArchive(notesArchiveRes.data ?? [])
      setMedLists(medRes.data ?? [])
      setLoading(false)
    }

    load()
  }, [id])

  const shiftsByDate = useMemo(() => {
    const map = new Map<string, Shift[]>()
    for (const s of shifts) {
      const list = map.get(s.date) || []
      list.push(s)
      map.set(s.date, list)
    }
    return map
  }, [shifts])

  const calendarDays = useMemo(() => {
    const firstDay = new Date(viewYear, viewMonth, 1)
    const lastDay = new Date(viewYear, viewMonth + 1, 0)
    const startOffset = firstDay.getDay()
    const days: { date: Date; iso: string; isCurrentMonth: boolean }[] = []

    for (let i = startOffset - 1; i >= 0; i--) {
      const d = new Date(viewYear, viewMonth, -i)
      days.push({ date: d, iso: toIso(d), isCurrentMonth: false })
    }
    for (let d = 1; d <= lastDay.getDate(); d++) {
      const date = new Date(viewYear, viewMonth, d)
      days.push({ date, iso: toIso(date), isCurrentMonth: true })
    }
    const remaining = 7 - (days.length % 7)
    if (remaining < 7) {
      for (let i = 1; i <= remaining; i++) {
        const d = new Date(viewYear, viewMonth + 1, i)
        days.push({ date: d, iso: toIso(d), isCurrentMonth: false })
      }
    }
    return days
  }, [viewYear, viewMonth])

  const selectedShifts = useMemo(() => shiftsByDate.get(selectedDate) || [], [shiftsByDate, selectedDate])

  const prevMonth = () => {
    if (viewMonth === 0) { setViewYear(y => y - 1); setViewMonth(11) }
    else setViewMonth(m => m - 1)
  }
  const nextMonth = () => {
    if (viewMonth === 11) { setViewYear(y => y + 1); setViewMonth(0) }
    else setViewMonth(m => m + 1)
  }

  const todayIso = toIso(today)

  const monthTotal = useMemo(() => {
    let total = 0
    let count = 0
    for (const [date, dayShifts] of shiftsByDate) {
      const [y, m] = date.split('-').map(Number)
      if (y === viewYear && m === viewMonth + 1) {
        count += dayShifts.length
        total += dayShifts.reduce((sum, s) => sum + (s.value || 0), 0)
      }
    }
    return { count, total }
  }, [shiftsByDate, viewYear, viewMonth])

  if (loading) return <p className="text-sm text-gray-500">Carregando dados do usuário...</p>

  if (!authUser) {
    return (
      <div className="space-y-4">
        <p className="text-gray-500">Usuário não encontrado.</p>
        <Link to="/admin" className="text-brand-600 hover:underline">Voltar</Link>
      </div>
    )
  }

  const displayName = profile?.full_name || authUser.email

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link to="/admin" className="text-sm text-brand-600 hover:underline">&larr; Voltar</Link>
        <h1 className="text-2xl font-bold text-gray-900">{displayName}</h1>
        <Badge variant={authUser.email_confirmed_at ? 'success' : 'warning'}>
          {authUser.email_confirmed_at ? 'Confirmado' : 'Pendente'}
        </Badge>
      </div>

      <div className="grid gap-4 sm:grid-cols-4">
        <Card><p className="text-xs text-gray-500">E-mail</p><p className="mt-1 text-sm font-medium">{authUser.email}</p></Card>
        <Card><p className="text-xs text-gray-500">CRM</p><p className="mt-1 text-sm font-medium">{profile?.crm || '—'}</p></Card>
        <Card><p className="text-xs text-gray-500">Último login</p><p className="mt-1 text-sm font-medium">{authUser.last_sign_in_at ? new Date(authUser.last_sign_in_at).toLocaleDateString('pt-BR') : '—'}</p></Card>
        <Card><p className="text-xs text-gray-500">Total de acessos</p><p className="mt-1 text-sm font-medium">{authUser.access_count ?? 0}</p></Card>
      </div>

      <Tabs tabs={tabList} active={activeTab} onChange={setActiveTab} />

      <div className="mt-4">
        {activeTab === 'agenda' && (
          <div className="space-y-4">
            {/* Resumo */}
            <div className="grid grid-cols-2 gap-4">
              <Card className="!p-4">
                <p className="text-sm text-gray-500">Plantões no mês</p>
                <p className="text-2xl font-bold text-gray-900">{monthTotal.count}</p>
              </Card>
              <Card className="!p-4">
                <p className="text-sm text-gray-500">Total no mês</p>
                <p className="text-2xl font-bold text-emerald-600">R$ {monthTotal.total.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</p>
              </Card>
            </div>

            {/* Calendário */}
            <Card className="!p-4">
              <div className="mb-4 flex items-center justify-between">
                <button onClick={prevMonth} className="rounded-lg p-2 text-gray-600 hover:bg-gray-100 transition-colors">
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" /></svg>
                </button>
                <h2 className="text-lg font-semibold text-gray-900">{MONTH_LABELS[viewMonth]} {viewYear}</h2>
                <button onClick={nextMonth} className="rounded-lg p-2 text-gray-600 hover:bg-gray-100 transition-colors">
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" /></svg>
                </button>
              </div>

              <div className="grid grid-cols-7 gap-px mb-1">
                {WEEKDAY_LABELS.map(d => (
                  <div key={d} className="py-2 text-center text-xs font-semibold text-gray-500 uppercase">{d}</div>
                ))}
              </div>

              <div className="grid grid-cols-7 gap-px rounded-lg overflow-hidden bg-gray-200">
                {calendarDays.map(({ iso, date, isCurrentMonth }) => {
                  const dayShifts = shiftsByDate.get(iso) || []
                  const isToday = iso === todayIso
                  const isSelected = iso === selectedDate
                  const hasShifts = dayShifts.length > 0

                  return (
                    <button
                      key={iso}
                      onClick={() => setSelectedDate(iso)}
                      className={`relative min-h-[68px] p-1.5 text-left transition-colors flex flex-col
                        ${isCurrentMonth ? 'bg-white' : 'bg-gray-50'}
                        ${isSelected ? 'ring-2 ring-brand-500 ring-inset z-10' : ''}
                        hover:bg-brand-50
                      `}
                    >
                      <span className={`inline-flex h-6 w-6 items-center justify-center rounded-full text-xs
                        ${isToday ? 'bg-brand-600 font-bold text-white' : ''}
                        ${!isToday && isCurrentMonth ? 'text-gray-900' : ''}
                        ${!isToday && !isCurrentMonth ? 'text-gray-400' : ''}
                      `}>
                        {date.getDate()}
                      </span>
                      {hasShifts && (
                        <div className="mt-auto flex flex-wrap gap-0.5">
                          {dayShifts.slice(0, 3).map((s, i) => (
                            <span
                              key={i}
                              className={`block h-1.5 flex-1 rounded-full ${TYPE_COLORS[s.type] || 'bg-gray-400'}`}
                              title={`${s.hospital_name} - ${s.type}`}
                            />
                          ))}
                          {dayShifts.length > 3 && (
                            <span className="text-[10px] text-gray-500 leading-none">+{dayShifts.length - 3}</span>
                          )}
                        </div>
                      )}
                    </button>
                  )
                })}
              </div>

              <div className="mt-3 flex flex-wrap gap-3">
                {Object.entries(TYPE_COLORS).map(([type, color]) => (
                  <div key={type} className="flex items-center gap-1.5">
                    <span className={`block h-2.5 w-2.5 rounded-full ${color}`} />
                    <span className="text-xs text-gray-600">{type}</span>
                  </div>
                ))}
              </div>
            </Card>

            {/* Plantões do dia selecionado */}
            <Card className="!p-4">
              <h3 className="mb-3 font-semibold text-gray-900">
                {new Date(selectedDate + 'T12:00').toLocaleDateString('pt-BR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
              </h3>
              {selectedShifts.length === 0 ? (
                <p className="py-4 text-center text-sm text-gray-400">Nenhum plantão neste dia</p>
              ) : (
                <div className="space-y-2">
                  {selectedShifts.map(s => (
                    <div key={s.id} className="flex items-center gap-3 rounded-lg bg-gray-50 p-3">
                      <div className={`h-10 w-1.5 rounded-full ${TYPE_COLORS[s.type] || 'bg-gray-400'}`} />
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="font-medium text-gray-900 truncate">{s.hospital_name || 'Sem local'}</span>
                          <Badge variant={s.type === 'Diurno' ? 'info' : 'warning'}>{s.type}</Badge>
                          {s.recurrence_group_id && <Badge variant="default">Recorrente</Badge>}
                        </div>
                        <div className="mt-0.5 flex items-center gap-3 text-sm text-gray-500">
                          <span>{s.start_time} — {s.end_time}</span>
                          {s.value ? <span className="font-medium text-emerald-600">R$ {s.value.toFixed(2)}</span> : null}
                          {s.informacoes && <span className="truncate text-gray-400">{s.informacoes}</span>}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </Card>
          </div>
        )}

        {activeTab === 'producao' && (
          <Card title="Produção">
            <div className="grid gap-4 sm:grid-cols-4">
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{shifts.length}</p>
                <p className="text-xs text-gray-500">Plantões registrados</p>
              </div>
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{patients.length}</p>
                <p className="text-xs text-gray-500">Pacientes</p>
              </div>
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{notes.length}</p>
                <p className="text-xs text-gray-500">Notas gerais</p>
              </div>
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{medLists.length}</p>
                <p className="text-xs text-gray-500">Listas de medicamentos</p>
              </div>
            </div>
          </Card>
        )}

        {activeTab === 'anotacoes' && (
          <div className="space-y-6">
            <Card title="Notas Gerais">
              {notes.length === 0 ? (
                <p className="text-sm text-gray-400">Sem notas ativas.</p>
              ) : (
                <div className="space-y-2">
                  {notes.map(n => (
                    <div key={n.id} className="rounded-lg bg-gray-50 p-3">
                      <p className="text-sm font-medium text-gray-900">{n.title}</p>
                      <p className="text-xs text-gray-500">{new Date(n.updated_at).toLocaleDateString('pt-BR')}</p>
                      <p className="mt-1 text-sm text-gray-600 line-clamp-2">{n.content}</p>
                    </div>
                  ))}
                </div>
              )}
            </Card>
            {notesArchive.length > 0 && (
              <Card title="Notas Arquivadas">
                <div className="space-y-2">
                  {notesArchive.map(n => (
                    <div key={n.id} className="rounded-lg bg-yellow-50 p-3">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-gray-900">{n.title}</p>
                        <Badge variant="warning">Arquivada</Badge>
                      </div>
                      <p className="text-xs text-gray-500">
                        Arquivada em {new Date(n.archived_at).toLocaleDateString('pt-BR')}
                      </p>
                      <p className="mt-1 text-sm text-gray-600 line-clamp-2">{n.content}</p>
                    </div>
                  ))}
                </div>
              </Card>
            )}
          </div>
        )}

        {activeTab === 'pacientes' && (
          <div className="space-y-6">
            <Card title="Pacientes Ativos">
              {patients.length === 0 ? (
                <p className="text-sm text-gray-400">Sem pacientes ativos.</p>
              ) : (
                <div className="space-y-2">
                  {patients.map(p => (
                    <div key={p.id} className="rounded-lg bg-gray-50 p-3">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-gray-900">{p.initials}</p>
                        {p.bed && <Badge variant="info">Leito: {p.bed}</Badge>}
                      </div>
                      {p.diagnosis && <p className="mt-1 text-sm text-gray-600">{p.diagnosis}</p>}
                      {p.pending && <p className="mt-1 text-sm text-yellow-700">Pendências: {p.pending}</p>}
                    </div>
                  ))}
                </div>
              )}
            </Card>
            {patientsArchive.length > 0 && (
              <Card title="Pacientes Arquivados">
                <div className="space-y-2">
                  {patientsArchive.map(p => (
                    <div key={p.id} className="rounded-lg bg-yellow-50 p-3">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-gray-900">{p.initials}</p>
                        {p.bed && <Badge variant="info">Leito: {p.bed}</Badge>}
                        <Badge variant="warning">Arquivado</Badge>
                      </div>
                      <p className="text-xs text-gray-500">
                        Arquivado em {new Date(p.archived_at).toLocaleDateString('pt-BR')}
                      </p>
                      {p.diagnosis && <p className="mt-1 text-sm text-gray-600">{p.diagnosis}</p>}
                    </div>
                  ))}
                </div>
              </Card>
            )}
          </div>
        )}

        {activeTab === 'medicamentos' && (
          <Card title="Listas de Medicamentos">
            {medLists.length === 0 ? (
              <p className="text-sm text-gray-400">Nenhuma lista criada.</p>
            ) : (
              <div className="space-y-4">
                {medLists.map(list => (
                  <div key={list.id} className="rounded-lg border border-gray-200 p-4">
                    <h4 className="font-semibold text-gray-900">{list.nome}</h4>
                    <p className="mt-1 text-xs text-gray-500">{list.medicamento_ids.length} medicamento(s)</p>
                    <div className="mt-2 flex flex-wrap gap-1">
                      {list.medicamento_ids.map(med => <Badge key={med}>{med}</Badge>)}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Card>
        )}

        {activeTab === 'config' && (
          <Card title="Configurações do Usuário">
            <dl className="grid gap-4 sm:grid-cols-2">
              {[
                ['Nome', profile?.full_name || '—'],
                ['E-mail', authUser.email],
                ['CRM', profile?.crm || '—'],
                ['Especialidade', profile?.specialty || '—'],
                ['Telefone', profile?.phone || '—'],
                ['Endereço', profile?.address || '—'],
                ['RQE', profile?.rqe || '—'],
                ['Cadastro', new Date(authUser.created_at).toLocaleDateString('pt-BR')],
              ].map(([label, value]) => (
                <div key={label}>
                  <dt className="text-xs text-gray-500">{label}</dt>
                  <dd className="mt-1 text-sm font-medium text-gray-900">{value}</dd>
                </div>
              ))}
            </dl>
          </Card>
        )}
      </div>
    </div>
  )
}
