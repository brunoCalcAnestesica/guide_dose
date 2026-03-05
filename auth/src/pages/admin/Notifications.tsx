import { useState, useEffect, useCallback } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Tabs } from '../../components/ui/Tabs'
import { Badge } from '../../components/ui/Badge'
import { Modal } from '../../components/ui/Modal'
import { EmptyState } from '../../components/ui/EmptyState'
import { apiQuery, apiInsert, apiUpdate, apiDelete, apiSendPush, adminQuery } from '../../lib/api'
import type { AppConfig, PushNotification, PushSchedule, Profile } from '../../types'

const tabs = [
  { id: 'push', label: 'Enviar Push' },
  { id: 'broadcast', label: 'Broadcast' },
  { id: 'schedules', label: 'Agendadas' },
  { id: 'history', label: 'Histórico' },
]

export default function Notifications() {
  const [activeTab, setActiveTab] = useState('push')

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Notificações</h1>
      <Tabs tabs={tabs} active={activeTab} onChange={setActiveTab} />
      <div className="mt-4">
        {activeTab === 'push' && <SendPushTab />}
        {activeTab === 'broadcast' && <BroadcastTab />}
        {activeTab === 'schedules' && <SchedulesTab />}
        {activeTab === 'history' && <HistoryTab />}
      </div>
    </div>
  )
}

// ---------------------------------------------------------------------------
// Tab 1: Enviar Push
// ---------------------------------------------------------------------------

function SendPushTab() {
  const [title, setTitle] = useState('')
  const [body, setBody] = useState('')
  const [link, setLink] = useState('')
  const [targetType, setTargetType] = useState<'all' | 'users'>('all')
  const [search, setSearch] = useState('')
  const [searchResults, setSearchResults] = useState<Profile[]>([])
  const [selectedUsers, setSelectedUsers] = useState<Profile[]>([])
  const [sending, setSending] = useState(false)
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null)

  const handleSearch = async () => {
    if (search.trim().length < 2) return
    const { data } = await adminQuery<Profile[]>('profiles', {
      select: 'id,email,full_name',
      or: `(email.ilike.%${search.trim()}%,full_name.ilike.%${search.trim()}%)`,
      limit: '10',
    })
    setSearchResults(data ?? [])
  }

  const addUser = (profile: Profile) => {
    if (!selectedUsers.find(u => u.id === profile.id)) {
      setSelectedUsers(prev => [...prev, profile])
    }
    setSearchResults([])
    setSearch('')
  }

  const removeUser = (id: string) => {
    setSelectedUsers(prev => prev.filter(u => u.id !== id))
  }

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !body.trim()) return
    if (targetType === 'users' && selectedUsers.length === 0) {
      setFeedback({ type: 'error', message: 'Selecione ao menos um destinatário.' })
      return
    }

    setSending(true)
    setFeedback(null)

    const target = targetType === 'all'
      ? 'all'
      : selectedUsers.length === 1
        ? selectedUsers[0].id
        : selectedUsers.map(u => u.id)

    const { data, error } = await apiSendPush({
      target,
      title: title.trim(),
      body: body.trim(),
      link: link.trim() || undefined,
      source: 'manual',
    })

    if (error) {
      setFeedback({ type: 'error', message: error })
    } else {
      setFeedback({ type: 'success', message: `Notificação enviada para ${data?.sent ?? 0} dispositivo(s).` })
      setTitle('')
      setBody('')
      setLink('')
      setSelectedUsers([])
    }
    setSending(false)
  }

  return (
    <Card title="Enviar notificação push">
      <form onSubmit={handleSend} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Destinatário</label>
          <div className="mt-1 flex gap-2">
            <button
              type="button"
              onClick={() => setTargetType('all')}
              className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
                targetType === 'all'
                  ? 'bg-brand-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Todos
            </button>
            <button
              type="button"
              onClick={() => setTargetType('users')}
              className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
                targetType === 'users'
                  ? 'bg-brand-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Escolher usuários
            </button>
          </div>
        </div>

        {targetType === 'users' && (
          <div className="space-y-2">
            <div className="flex gap-2">
              <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); handleSearch() } }}
                placeholder="Buscar por e-mail ou nome..."
                className="flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
              />
              <Button type="button" variant="secondary" onClick={handleSearch}>Buscar</Button>
            </div>

            {searchResults.length > 0 && (
              <div className="rounded-lg border border-gray-200 bg-white shadow-sm">
                {searchResults.map(p => (
                  <button
                    key={p.id}
                    type="button"
                    onClick={() => addUser(p)}
                    className="flex w-full items-center gap-2 px-3 py-2 text-sm hover:bg-gray-50"
                  >
                    <span className="font-medium text-gray-900">{p.full_name || p.email}</span>
                    <span className="text-xs text-gray-500">{p.email}</span>
                  </button>
                ))}
              </div>
            )}

            {selectedUsers.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {selectedUsers.map(u => (
                  <span key={u.id} className="inline-flex items-center gap-1 rounded-full bg-brand-100 px-3 py-1 text-sm text-brand-700">
                    {u.full_name || u.email}
                    <button type="button" onClick={() => removeUser(u.id)} className="ml-1 text-brand-500 hover:text-brand-700">&times;</button>
                  </span>
                ))}
              </div>
            )}
          </div>
        )}

        <div>
          <label className="block text-sm font-medium text-gray-700">Título</label>
          <input
            required
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="Ex: Novidade no GuideDose"
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Corpo da notificação</label>
          <textarea
            required
            rows={4}
            value={body}
            onChange={e => setBody(e.target.value)}
            placeholder="Digite a mensagem..."
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Link ao tocar (opcional)</label>
          <input
            value={link}
            onChange={e => setLink(e.target.value)}
            placeholder="guidedose://escala ou https://..."
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>

        {feedback && (
          <p className={`text-sm ${feedback.type === 'success' ? 'text-green-600' : 'text-red-600'}`}>
            {feedback.message}
          </p>
        )}

        <Button type="submit" disabled={sending}>
          {sending ? 'Enviando...' : 'Enviar notificação'}
        </Button>
      </form>
    </Card>
  )
}

// ---------------------------------------------------------------------------
// Tab 2: Broadcast
// ---------------------------------------------------------------------------

function BroadcastTab() {
  const [loading, setLoading] = useState(true)
  const [configs, setConfigs] = useState<Record<string, string>>({})
  const [title, setTitle] = useState('')
  const [message, setMessage] = useState('')
  const [alsoPush, setAlsoPush] = useState(true)
  const [saving, setSaving] = useState(false)
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null)

  useEffect(() => {
    apiQuery<AppConfig[]>('app_config', { select: '*' }).then(({ data }) => {
      const map: Record<string, string> = {}
      ;(data ?? []).forEach(c => { map[c.key] = c.value })
      setConfigs(map)
      setTitle(map['broadcast_title'] ?? '')
      setMessage(map['broadcast_message'] ?? '')
      setLoading(false)
    })
  }, [])

  const upsertConfig = async (key: string, value: string) => {
    if (configs[key] !== undefined) {
      return apiUpdate('app_config', { key: `eq.${key}` }, { value, updated_at: new Date().toISOString() })
    } else {
      return apiInsert('app_config', { key, value, updated_at: new Date().toISOString() })
    }
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!message.trim()) return
    setSaving(true)
    setFeedback(null)

    const updatedAt = new Date().toISOString()
    const results = await Promise.all([
      upsertConfig('broadcast_title', title.trim()),
      upsertConfig('broadcast_message', message.trim()),
      upsertConfig('broadcast_updated_at', updatedAt),
    ])

    const err = results.find(r => r.error)
    if (err) {
      setFeedback({ type: 'error', message: err.error || 'Erro ao salvar broadcast.' })
      setSaving(false)
      return
    }

    setConfigs(prev => ({
      ...prev,
      broadcast_title: title.trim(),
      broadcast_message: message.trim(),
      broadcast_updated_at: updatedAt,
    }))

    if (alsoPush) {
      const { error } = await apiSendPush({
        target: 'all',
        title: title.trim() || 'Mensagem do GuideDose',
        body: message.trim(),
        source: 'broadcast',
      })
      if (error) {
        setFeedback({ type: 'error', message: `Broadcast salvo, mas push falhou: ${error}` })
        setSaving(false)
        return
      }
    }

    setFeedback({ type: 'success', message: alsoPush ? 'Broadcast salvo e push enviado!' : 'Broadcast salvo!' })
    setSaving(false)
    setTimeout(() => setFeedback(null), 4000)
  }

  if (loading) return <p className="text-sm text-gray-500">Carregando...</p>

  return (
    <div className="space-y-6">
      <Card title="Mensagem broadcast">
        <p className="mb-4 text-sm text-gray-500">
          Aparece como dialog ao abrir o app. Opcionalmente, envia também um push notification.
        </p>
        <form onSubmit={handleSave} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Título (opcional)</label>
            <input
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="Ex: Novidade no GuideDose"
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Mensagem</label>
            <textarea
              required
              rows={5}
              value={message}
              onChange={e => setMessage(e.target.value)}
              placeholder="Digite a mensagem que aparecerá para todos os usuários..."
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>

          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={alsoPush}
              onChange={e => setAlsoPush(e.target.checked)}
              className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
            />
            <span className="text-sm text-gray-700">Também enviar notificação push para todos os dispositivos</span>
          </label>

          {feedback && (
            <p className={`text-sm ${feedback.type === 'success' ? 'text-green-600' : 'text-red-600'}`}>
              {feedback.message}
            </p>
          )}

          <Button type="submit" disabled={saving}>
            {saving ? 'Salvando...' : 'Salvar broadcast'}
          </Button>
        </form>
      </Card>

      {configs['broadcast_updated_at'] && (
        <Card title="Última mensagem enviada">
          <p className="text-xs text-gray-500">
            Em: {new Date(configs['broadcast_updated_at']).toLocaleString('pt-BR')}
          </p>
          {configs['broadcast_title'] && (
            <p className="mt-1 font-medium text-gray-900">{configs['broadcast_title']}</p>
          )}
          <p className="mt-1 text-sm text-gray-700 whitespace-pre-wrap">{configs['broadcast_message'] || '—'}</p>
        </Card>
      )}
    </div>
  )
}

// ---------------------------------------------------------------------------
// Tab 3: Agendadas
// ---------------------------------------------------------------------------

function SchedulesTab() {
  const [schedules, setSchedules] = useState<PushSchedule[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)

  const load = useCallback(async () => {
    const { data } = await apiQuery<PushSchedule[]>('push_schedules', {
      select: '*',
      order: 'scheduled_at.asc',
    })
    setSchedules(data ?? [])
    setLoading(false)
  }, [])

  useEffect(() => { load() }, [load])

  const toggleActive = async (id: number, active: boolean) => {
    await apiUpdate('push_schedules', { id: `eq.${id}` }, { is_active: active })
    load()
  }

  const handleDelete = async (id: number) => {
    await apiDelete('push_schedules', { id: `eq.${id}` })
    load()
  }

  const handleCreate = async (schedule: Omit<PushSchedule, 'id' | 'created_by' | 'last_run_at' | 'created_at'>) => {
    const { error } = await apiInsert('push_schedules', schedule)
    if (!error) {
      setShowModal(false)
      load()
    }
  }

  if (loading) return <p className="text-sm text-gray-500">Carregando agendamentos...</p>

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <p className="text-sm text-gray-600">{schedules.length} agendamento(s)</p>
        <Button onClick={() => setShowModal(true)}>Nova agendada</Button>
      </div>

      {schedules.length === 0 ? (
        <EmptyState
          title="Nenhuma notificação agendada"
          description="Crie uma para enviar automaticamente no horário programado."
          action={<Button onClick={() => setShowModal(true)}>Criar agendamento</Button>}
        />
      ) : (
        <div className="space-y-3">
          {schedules.map(s => (
            <Card key={s.id}>
              <div className="flex items-start justify-between gap-4">
                <div className="min-w-0 flex-1">
                  <p className="font-medium text-gray-900">{s.title}</p>
                  <p className="mt-0.5 text-sm text-gray-600 line-clamp-2">{s.body}</p>
                  <div className="mt-2 flex flex-wrap items-center gap-2 text-xs text-gray-500">
                    <Badge variant={s.is_active ? 'success' : 'default'}>
                      {s.is_active ? 'Ativa' : 'Inativa'}
                    </Badge>
                    <span>{s.target_type === 'all' ? 'Todos' : s.target_type}</span>
                    <span>&middot;</span>
                    <span>{new Date(s.scheduled_at).toLocaleString('pt-BR')}</span>
                    {s.recurrence && (
                      <>
                        <span>&middot;</span>
                        <Badge variant="info">{s.recurrence}</Badge>
                      </>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <label className="relative inline-flex cursor-pointer items-center">
                    <input
                      type="checkbox"
                      checked={s.is_active}
                      onChange={e => toggleActive(s.id, e.target.checked)}
                      className="peer sr-only"
                    />
                    <div className="h-6 w-11 rounded-full bg-gray-200 after:absolute after:left-[2px] after:top-[2px] after:h-5 after:w-5 after:rounded-full after:bg-white after:transition-all peer-checked:bg-brand-600 peer-checked:after:translate-x-full" />
                  </label>
                  <Button size="sm" variant="danger" onClick={() => handleDelete(s.id)}>
                    Excluir
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      <ScheduleModal
        open={showModal}
        onClose={() => setShowModal(false)}
        onCreate={handleCreate}
      />
    </div>
  )
}

function ScheduleModal({ open, onClose, onCreate }: {
  open: boolean
  onClose: () => void
  onCreate: (s: Omit<PushSchedule, 'id' | 'created_by' | 'last_run_at' | 'created_at'>) => void
}) {
  const [title, setTitle] = useState('')
  const [body, setBody] = useState('')
  const [link, setLink] = useState('')
  const [targetType, setTargetType] = useState<'all'>('all')
  const [scheduledAt, setScheduledAt] = useState('')
  const [recurrence, setRecurrence] = useState<string>('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !body.trim() || !scheduledAt) return
    onCreate({
      target_type: targetType,
      target_value: null,
      title: title.trim(),
      body: body.trim(),
      link: link.trim() || null,
      scheduled_at: new Date(scheduledAt).toISOString(),
      recurrence: recurrence || null,
      is_active: true,
    })
    setTitle('')
    setBody('')
    setLink('')
    setScheduledAt('')
    setRecurrence('')
  }

  return (
    <Modal open={open} onClose={onClose} title="Nova notificação agendada">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Título</label>
          <input
            required
            value={title}
            onChange={e => setTitle(e.target.value)}
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Corpo</label>
          <textarea
            required
            rows={3}
            value={body}
            onChange={e => setBody(e.target.value)}
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Link ao tocar (opcional)</label>
          <input
            value={link}
            onChange={e => setLink(e.target.value)}
            placeholder="guidedose://escala ou https://..."
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Destinatário</label>
          <select
            value={targetType}
            onChange={e => setTargetType(e.target.value as 'all')}
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          >
            <option value="all">Todos</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Data e hora</label>
          <input
            required
            type="datetime-local"
            value={scheduledAt}
            onChange={e => setScheduledAt(e.target.value)}
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Recorrência</label>
          <select
            value={recurrence}
            onChange={e => setRecurrence(e.target.value)}
            className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          >
            <option value="">Uma vez</option>
            <option value="daily">Diária</option>
            <option value="weekly">Semanal</option>
            <option value="monthly">Mensal</option>
          </select>
        </div>
        <div className="flex justify-end gap-3 pt-2">
          <Button type="button" variant="secondary" onClick={onClose}>Cancelar</Button>
          <Button type="submit">Agendar</Button>
        </div>
      </form>
    </Modal>
  )
}

// ---------------------------------------------------------------------------
// Tab 4: Histórico
// ---------------------------------------------------------------------------

const SOURCE_LABELS: Record<string, string> = {
  manual: 'Manual',
  broadcast: 'Broadcast',
  schedule: 'Agendada',
  auto_eve: 'Auto (véspera)',
  auto_blocked: 'Auto (bloqueado)',
}

function HistoryTab() {
  const [items, setItems] = useState<PushNotification[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    apiQuery<PushNotification[]>('push_notifications', {
      select: '*',
      order: 'sent_at.desc',
      limit: '50',
    }).then(({ data }) => {
      setItems(data ?? [])
      setLoading(false)
    })
  }, [])

  if (loading) return <p className="text-sm text-gray-500">Carregando histórico...</p>

  if (items.length === 0) {
    return (
      <EmptyState
        title="Nenhuma notificação enviada"
        description="O histórico aparecerá aqui após o primeiro envio."
      />
    )
  }

  return (
    <div className="space-y-3">
      {items.map(n => (
        <Card key={n.id}>
          <div className="flex items-start justify-between gap-4">
            <div className="min-w-0 flex-1">
              <p className="font-medium text-gray-900">{n.title}</p>
              <p className="mt-0.5 text-sm text-gray-600 line-clamp-2">{n.body}</p>
              <div className="mt-2 flex flex-wrap items-center gap-2 text-xs text-gray-500">
                <Badge variant="info">{SOURCE_LABELS[n.source] ?? n.source}</Badge>
                <span>{n.target_type === 'all' ? 'Todos' : n.target_type}</span>
                <span>&middot;</span>
                <span>{n.tokens_count} dispositivo(s)</span>
                {n.link && (
                  <>
                    <span>&middot;</span>
                    <span className="truncate max-w-[200px]" title={n.link}>{n.link}</span>
                  </>
                )}
              </div>
            </div>
            <p className="shrink-0 text-xs text-gray-400">
              {new Date(n.sent_at).toLocaleString('pt-BR')}
            </p>
          </div>
        </Card>
      ))}
    </div>
  )
}
