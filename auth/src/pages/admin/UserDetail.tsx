import { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { Card } from '../../components/ui/Card'
import { Tabs } from '../../components/ui/Tabs'
import { Badge } from '../../components/ui/Badge'
import { adminQuery, adminListUsers } from '../../lib/api'
import type { AdminUser, Profile, Shift, Patient, Note, MedList } from '../../types'

const tabList = [
  { id: 'agenda', label: 'Agenda' },
  { id: 'producao', label: 'Produção' },
  { id: 'anotacoes', label: 'Anotações' },
  { id: 'pacientes', label: 'Pacientes' },
  { id: 'medicamentos', label: 'Listas de Medicamentos' },
  { id: 'config', label: 'Configurações' },
]

export default function UserDetail() {
  const { id } = useParams<{ id: string }>()
  const [activeTab, setActiveTab] = useState('agenda')
  const [loading, setLoading] = useState(true)
  const [authUser, setAuthUser] = useState<AdminUser | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [shifts, setShifts] = useState<Shift[]>([])
    const [patients, setPatients] = useState<Patient[]>([])
    const [notes, setNotes] = useState<Note[]>([])
    const [medLists, setMedLists] = useState<MedList[]>([])

  useEffect(() => {
    if (!id) return

    const load = async () => {
      setLoading(true)

      const [usersRes, profileRes, shiftsRes, patientsRes, notesRes, medRes] = await Promise.all([
        adminListUsers(),
        adminQuery<Profile[]>('profiles', { id: `eq.${id}`, select: '*' }),
        adminQuery<Shift[]>('shifts', { user_id: `eq.${id}`, order: 'date.desc', select: '*' }),
        adminQuery<Patient[]>('patients', { user_id: `eq.${id}`, order: 'updated_at.desc', select: '*' }),
        adminQuery<Note[]>('notes', { user_id: `eq.${id}`, order: 'updated_at.desc', select: '*' }),
        adminQuery<MedList[]>('med_lists', { user_id: `eq.${id}`, select: '*' }),
      ])

      const allUsers = (usersRes.data as AdminUser[]) ?? []
      setAuthUser(allUsers.find(u => u.id === id) ?? null)

      const profiles = profileRes.data ?? []
      setProfile(profiles.length > 0 ? profiles[0] : null)

      setShifts(shiftsRes.data ?? [])

      setPatients(patientsRes.data ?? [])
      setNotes(notesRes.data ?? [])
      setMedLists(medRes.data ?? [])
      setLoading(false)
    }

    load()
  }, [id])

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
          <Card title="Plantões / Escala">
            {shifts.length === 0 ? (
              <p className="text-sm text-gray-400">Nenhum plantão registrado.</p>
            ) : (
              <div className="space-y-2">
                {shifts.slice(0, 20).map(s => (
                  <div key={s.id} className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{s.hospital_name || '—'}</p>
                      <p className="text-xs text-gray-500">
                        {new Date(s.date + 'T12:00').toLocaleDateString('pt-BR')} &middot; {s.start_time}-{s.end_time}
                        {s.value > 0 && ` · R$ ${s.value.toFixed(2)}`}
                      </p>
                    </div>
                    <Badge variant="info">{s.type}</Badge>
                  </div>
                ))}
              </div>
            )}
          </Card>
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
          <Card title="Notas Gerais">
            {notes.length === 0 ? (
              <p className="text-sm text-gray-400">Sem notas.</p>
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
        )}

        {activeTab === 'pacientes' && (
          <Card title="Pacientes">
            {patients.length === 0 ? (
              <p className="text-sm text-gray-400">Sem pacientes registrados.</p>
            ) : (
              <div className="space-y-2">
                {patients.map(p => (
                  <div key={p.id} className="rounded-lg bg-gray-50 p-3">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-medium text-gray-900">{p.initials}</p>
                      {p.bed && <Badge variant="info">Leito: {p.bed}</Badge>}
                      {p.is_archived && <Badge variant="warning">Arquivado</Badge>}
                    </div>
                    {p.diagnosis && <p className="mt-1 text-sm text-gray-600">{p.diagnosis}</p>}
                    {p.pending && <p className="mt-1 text-sm text-yellow-700">Pendências: {p.pending}</p>}
                  </div>
                ))}
              </div>
            )}
          </Card>
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
