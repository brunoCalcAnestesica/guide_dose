import { useState, useEffect } from 'react'
import { Card } from '../../components/ui/Card'
import { Badge } from '../../components/ui/Badge'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery } from '../../lib/api'
import { expandRecurrenceRules } from '../../lib/recurrence'
import type { Patient, Shift, Note, RecurrenceDefinition } from '../../types'

function todayIso(): string {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

export default function Dashboard() {
  const { user } = useAuth()
  const [patients, setPatients] = useState<Patient[]>([])
  const [shifts, setShifts] = useState<Shift[]>([])
  const [notes, setNotes] = useState<Note[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!user) return
    setLoading(true)

    Promise.all([
      apiQuery<Patient[]>('patients', {
        user_id: `eq.${user.id}`,
        order: 'updated_at.desc',
        limit: '5',
        select: 'id,initials,bed,diagnosis,updated_at',
      }),
      apiQuery<Shift[]>('shifts', {
        user_id: `eq.${user.id}`,
        date: `gte.${todayIso()}`,
        order: 'date.asc',
        limit: '50',
        select: '*',
      }),
      apiQuery<RecurrenceDefinition[]>('recurrence_rules', {
        user_id: `eq.${user.id}`,
        select: '*',
      }),
      apiQuery<Note[]>('notes', {
        user_id: `eq.${user.id}`,
        order: 'updated_at.desc',
        limit: '3',
        select: 'id,title,content,updated_at',
      }),
    ]).then(([pRes, sRes, rRes, nRes]) => {
      setPatients(pRes.data ?? [])
      setNotes(nRes.data ?? [])

      const standalone = sRes.data ?? []
      const rules = rRes.data ?? []

      const now = new Date()
      const rangeStart = new Date(now.getFullYear(), now.getMonth(), now.getDate())
      const rangeEnd = new Date(now.getFullYear(), now.getMonth() + 3, 0)
      const virtualShifts = expandRecurrenceRules(rules, rangeStart, rangeEnd)

      const virtualIds = new Set(virtualShifts.map(s => s.id))
      const filtered = standalone.filter(s => !virtualIds.has(s.id) && !s.recurrence_group_id)
      const merged = [...filtered, ...virtualShifts]
        .filter(s => s.date >= todayIso())
        .sort((a, b) => a.date.localeCompare(b.date))

      setShifts(merged)
      setLoading(false)
    })
  }, [user])

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-brand-200 border-t-brand-600" />
      </div>
    )
  }

  const upcomingShifts = shifts.slice(0, 8)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <Card className="border-l-4 border-l-brand-500">
          <p className="text-sm font-medium text-gray-500">Pacientes Ativos</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{patients.length}</p>
        </Card>
        <Card className="border-l-4 border-l-green-500">
          <p className="text-sm font-medium text-gray-500">Próximos Plantões</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{shifts.length}</p>
        </Card>
        <Card className="border-l-4 border-l-yellow-500">
          <p className="text-sm font-medium text-gray-500">Notas Recentes</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{notes.length}</p>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card title="Pacientes Recentes">
          {patients.length === 0 ? (
            <p className="text-sm text-gray-400">Nenhum paciente ativo.</p>
          ) : (
            <div className="space-y-3">
              {patients.map(p => (
                <div key={p.id} className="flex items-start justify-between rounded-lg bg-gray-50 p-3">
                  <div>
                    <p className="text-sm font-medium text-gray-900">{p.initials}</p>
                    <p className="text-xs text-gray-500">
                      {p.bed && `Leito: ${p.bed}`}
                      {p.diagnosis && ` · ${p.diagnosis.slice(0, 50)}`}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Card>

        <Card title="Próximos Plantões">
          {upcomingShifts.length === 0 ? (
            <p className="text-sm text-gray-400">Nenhum plantão agendado.</p>
          ) : (
            <div className="space-y-4">
              {(() => {
                const grouped: { date: string; shifts: typeof upcomingShifts }[] = []
                for (const s of upcomingShifts) {
                  const last = grouped[grouped.length - 1]
                  if (last && last.date === s.date) {
                    last.shifts.push(s)
                  } else {
                    grouped.push({ date: s.date, shifts: [s] })
                  }
                }
                return grouped.map(g => {
                  const d = new Date(g.date + 'T12:00')
                  const weekday = d.toLocaleDateString('pt-BR', { weekday: 'long' })
                  const label = weekday.charAt(0).toUpperCase() + weekday.slice(1)
                  const dateStr = d.toLocaleDateString('pt-BR')
                  const isToday = g.date === todayIso()
                  return (
                    <div key={g.date}>
                      <div className="mb-1.5 flex items-center gap-2">
                        <p className="text-sm font-semibold text-gray-700">{label}, {dateStr}</p>
                        {isToday && <span className="rounded-full bg-brand-100 px-2 py-0.5 text-[10px] font-bold text-brand-700">HOJE</span>}
                      </div>
                      <div className="space-y-2">
                        {g.shifts.map(s => (
                          <div key={s.id} className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
                            <div>
                              <p className="text-xs text-gray-500">
                                {s.start_time} - {s.end_time} &middot; <span className="font-medium text-gray-900">{s.hospital_name || '—'}</span>
                                {s.value > 0 && <span className="ml-1 text-emerald-600">· R$ {s.value.toFixed(2)}</span>}
                              </p>
                            </div>
                            <Badge variant={s.type === 'Diurno' ? 'info' : 'warning'}>
                              {s.type}
                            </Badge>
                          </div>
                        ))}
                      </div>
                    </div>
                  )
                })
              })()}
            </div>
          )}
        </Card>
      </div>

      {notes.length > 0 && (
        <Card title="Notas Recentes">
          <div className="space-y-2">
            {notes.map(n => (
              <div key={n.id} className="rounded-lg bg-gray-50 p-3">
                <p className="text-sm font-medium text-gray-900">{n.title}</p>
                <p className="text-xs text-gray-500">{new Date(n.updated_at).toLocaleDateString('pt-BR')}</p>
                <p className="mt-1 text-sm text-gray-600 line-clamp-1">{n.content}</p>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  )
}
