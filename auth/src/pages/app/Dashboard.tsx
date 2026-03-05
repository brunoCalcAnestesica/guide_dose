import { useState, useEffect } from 'react'
import { Card } from '../../components/ui/Card'
import { Badge } from '../../components/ui/Badge'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery } from '../../lib/api'
import type { Patient, Shift, Note } from '../../types'

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
        archived_at: 'is.null',
        order: 'updated_at.desc',
        limit: '5',
        select: 'id,initials,bed,diagnosis,updated_at',
      }),
      apiQuery<Shift[]>('shifts', {
        user_id: `eq.${user.id}`,
        date: `gte.${new Date().toISOString().slice(0, 10)}`,
        order: 'date.asc',
        limit: '5',
        select: '*',
      }),
      apiQuery<Note[]>('notes', {
        user_id: `eq.${user.id}`,
        archived_at: 'is.null',
        order: 'updated_at.desc',
        limit: '3',
        select: 'id,title,content,updated_at',
      }),
    ]).then(([pRes, sRes, nRes]) => {
      setPatients(pRes.data ?? [])
      setNotes(nRes.data ?? [])
      setShifts(sRes.data ?? [])
      setLoading(false)
    })
  }, [user])

  if (loading) {
    return <p className="text-sm text-gray-500">Carregando dashboard...</p>
  }

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
          {shifts.length === 0 ? (
            <p className="text-sm text-gray-400">Nenhum plantão agendado.</p>
          ) : (
            <div className="space-y-3">
              {shifts.map(s => (
                <div key={s.id} className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
                  <div>
                    <p className="text-sm font-medium text-gray-900">{s.hospital_name || '—'}</p>
                    <p className="text-xs text-gray-500">
                      {new Date(s.date + 'T12:00').toLocaleDateString('pt-BR')} &middot; {s.start_time}-{s.end_time}
                    </p>
                  </div>
                  <Badge variant={s.type === 'Diurno' ? 'info' : 'warning'}>
                    {s.type}
                  </Badge>
                </div>
              ))}
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
