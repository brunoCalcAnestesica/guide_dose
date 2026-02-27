import { useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { Card } from '../../components/ui/Card'
import { Tabs } from '../../components/ui/Tabs'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { mockUsers, mockShifts, mockPatientNotes, mockGeneralNotes, mockMedLists } from '../../mocks/data'

const tabList = [
  { id: 'agenda', label: 'Agenda' },
  { id: 'producao', label: 'Produção' },
  { id: 'anotacoes', label: 'Anotações' },
  { id: 'medicamentos', label: 'Listas de Medicamentos' },
  { id: 'config', label: 'Configurações' },
]

export default function UserDetail() {
  const { id } = useParams<{ id: string }>()
  const [activeTab, setActiveTab] = useState('agenda')
  const user = mockUsers.find(u => u.id === id)

  if (!user) {
    return (
      <div className="space-y-4">
        <p className="text-gray-500">Usuário não encontrado.</p>
        <Link to="/admin" className="text-brand-600 hover:underline">Voltar</Link>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link to="/admin" className="text-sm text-brand-600 hover:underline">&larr; Voltar</Link>
        <h1 className="text-2xl font-bold text-gray-900">{user.nome || user.email}</h1>
        <Badge variant={user.status === 'ativo' ? 'success' : 'danger'}>{user.status}</Badge>
        <Badge variant={user.tipo === 'admin' ? 'warning' : 'default'}>{user.tipo}</Badge>
      </div>

      <div className="grid gap-4 sm:grid-cols-4">
        <Card><p className="text-xs text-gray-500">E-mail</p><p className="mt-1 text-sm font-medium">{user.email}</p></Card>
        <Card><p className="text-xs text-gray-500">CRM</p><p className="mt-1 text-sm font-medium">{user.crm || '—'}</p></Card>
        <Card><p className="text-xs text-gray-500">Último acesso</p><p className="mt-1 text-sm font-medium">{user.ultimoAcesso ? new Date(user.ultimoAcesso).toLocaleDateString('pt-BR') : '—'}</p></Card>
        <Card><p className="text-xs text-gray-500">Total de logins</p><p className="mt-1 text-sm font-medium">{user.totalLogins ?? 0}</p></Card>
      </div>

      <div className="flex gap-2">
        <Button size="sm" variant="secondary" onClick={() => alert('Alterar nível de acesso (stub)')}>
          {user.tipo === 'admin' ? 'Rebaixar para Usuário' : 'Promover a Admin'}
        </Button>
        <Button size="sm" variant="secondary" onClick={() => alert('Reset de senha forçado (stub)')}>
          Forçar Reset de Senha
        </Button>
        <Button size="sm" variant={user.status === 'ativo' ? 'danger' : 'primary'} onClick={() => alert('Bloquear/Desbloquear (stub)')}>
          {user.status === 'ativo' ? 'Bloquear Conta' : 'Desbloquear Conta'}
        </Button>
      </div>

      <Tabs tabs={tabList} active={activeTab} onChange={setActiveTab} />

      <div className="mt-4">
        {activeTab === 'agenda' && (
          <Card title="Plantões / Escala">
            {mockShifts.filter(s => s.userId === user.id).length === 0 ? (
              <p className="text-sm text-gray-400">Nenhum plantão registrado.</p>
            ) : (
              <div className="space-y-2">
                {mockShifts.filter(s => s.userId === user.id).map(s => (
                  <div key={s.id} className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{s.local}</p>
                      <p className="text-xs text-gray-500">{new Date(s.data + 'T12:00').toLocaleDateString('pt-BR')} &middot; {s.horarioInicio}-{s.horarioFim}</p>
                    </div>
                    <Badge variant="info">{s.tipoPlantao}</Badge>
                  </div>
                ))}
              </div>
            )}
          </Card>
        )}

        {activeTab === 'producao' && (
          <Card title="Produção">
            <div className="grid gap-4 sm:grid-cols-3">
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{mockShifts.filter(s => s.userId === user.id).length}</p>
                <p className="text-xs text-gray-500">Plantões registrados</p>
              </div>
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{mockPatientNotes.filter(n => n.userId === user.id).length}</p>
                <p className="text-xs text-gray-500">Anotações de pacientes</p>
              </div>
              <div className="rounded-lg bg-gray-50 p-4 text-center">
                <p className="text-2xl font-bold text-gray-900">{mockGeneralNotes.filter(n => n.userId === user.id).length}</p>
                <p className="text-xs text-gray-500">Notas gerais</p>
              </div>
            </div>
            <p className="mt-4 text-xs text-gray-400">Dados detalhados de produção estarão disponíveis em breve.</p>
          </Card>
        )}

        {activeTab === 'anotacoes' && (
          <div className="space-y-6">
            <Card title="Anotações de Pacientes">
              {mockPatientNotes.filter(n => n.userId === user.id).length === 0 ? (
                <p className="text-sm text-gray-400">Sem anotações.</p>
              ) : (
                <div className="space-y-2">
                  {mockPatientNotes.filter(n => n.userId === user.id).map(n => (
                    <div key={n.id} className="rounded-lg bg-gray-50 p-3">
                      <p className="text-sm font-medium text-gray-900">{n.titulo}</p>
                      <p className="text-xs text-gray-500">{n.nomePaciente} &middot; {new Date(n.data).toLocaleDateString('pt-BR')}</p>
                      <p className="mt-1 text-sm text-gray-600 line-clamp-2">{n.texto}</p>
                      {n.anexos.length > 0 && <Badge variant="info">{n.anexos.length} anexo(s)</Badge>}
                    </div>
                  ))}
                </div>
              )}
            </Card>
            <Card title="Notas Gerais">
              {mockGeneralNotes.filter(n => n.userId === user.id).length === 0 ? (
                <p className="text-sm text-gray-400">Sem notas.</p>
              ) : (
                <div className="space-y-2">
                  {mockGeneralNotes.filter(n => n.userId === user.id).map(n => (
                    <div key={n.id} className="rounded-lg bg-gray-50 p-3">
                      <p className="text-sm font-medium text-gray-900">{n.titulo}</p>
                      <p className="mt-1 text-sm text-gray-600 line-clamp-2">{n.texto}</p>
                      <div className="mt-2 flex gap-1">{n.tags.map(t => <Badge key={t} variant="info">{t}</Badge>)}</div>
                    </div>
                  ))}
                </div>
              )}
            </Card>
          </div>
        )}

        {activeTab === 'medicamentos' && (
          <Card title="Listas de Medicamentos Personalizadas">
            {mockMedLists.filter(m => m.userId === user.id).length === 0 ? (
              <p className="text-sm text-gray-400">Nenhuma lista criada.</p>
            ) : (
              <div className="space-y-4">
                {mockMedLists.filter(m => m.userId === user.id).map(list => (
                  <div key={list.id} className="rounded-lg border border-gray-200 p-4">
                    <h4 className="font-semibold text-gray-900">{list.titulo}</h4>
                    <div className="mt-2 flex flex-wrap gap-1">
                      {list.medicamentos.map(med => <Badge key={med}>{med}</Badge>)}
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
                ['Nome', user.nome || '—'],
                ['E-mail', user.email],
                ['CRM', user.crm || '—'],
                ['Especialidade', user.especialidade || '—'],
                ['País', user.pais || '—'],
                ['Cidade', user.cidade || '—'],
                ['Dispositivo', user.deviceType || '—'],
                ['Cadastro', new Date(user.dataCadastro).toLocaleDateString('pt-BR')],
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
