import { useState, useEffect, useCallback, useRef } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { Modal } from '../../components/ui/Modal'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiInsert, apiUpdate, apiDelete, apiArchivePatient, apiSharePatient, apiUnsharePatient, apiListPatientShares } from '../../lib/api'
import type { Patient } from '../../types'

const SWIPE_THRESHOLD = 80
const MAX_SWIPE = 120

const inputClass = 'mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500'

function PatientRow({
  patient: p,
  isOwner,
  onEdit,
  onArchive,
  onDelete,
  onShare,
}: {
  patient: Patient
  isOwner: boolean
  onEdit: () => void
  onArchive: () => void
  onDelete: () => void
  onShare?: () => void
}) {
  const [dragX, setDragX] = useState(0)
  const startXRef = useRef(0)
  const didSwipeRef = useRef(false)

  const handlePointerDown = (e: React.PointerEvent) => {
    (e.target as HTMLElement).setPointerCapture?.(e.pointerId)
    startXRef.current = e.clientX
    didSwipeRef.current = false
  }

  const handlePointerMove = (e: React.PointerEvent) => {
    const dx = e.clientX - startXRef.current
    const clamped = Math.max(-MAX_SWIPE, Math.min(MAX_SWIPE, dx))
    setDragX(clamped)
  }

  const handlePointerUp = () => {
    if (Math.abs(dragX) >= SWIPE_THRESHOLD) {
      didSwipeRef.current = true
      if (dragX > 0) onArchive()
      else onDelete()
    }
    setDragX(0)
  }

  const handleClick = (e: React.MouseEvent) => {
    e.preventDefault()
    if (didSwipeRef.current) return
    if (Math.abs(dragX) >= SWIPE_THRESHOLD) return
    onEdit()
  }

  return (
    <li className="relative overflow-hidden bg-white">
      {/* Ações por trás do card: esquerda = Arquivar, direita = Excluir */}
      <div className="absolute inset-0 flex">
        <div className="flex w-28 flex-shrink-0 items-center justify-center bg-emerald-500 text-sm font-medium text-white">
          Arquivar
        </div>
        <div className="flex-1" />
        <div className="flex w-28 flex-shrink-0 items-center justify-center bg-red-600 text-sm font-medium text-white">
          Excluir
        </div>
      </div>

      <div
        className="relative z-10 flex min-h-[1px] cursor-pointer select-none flex-col gap-2 bg-white p-4 transition-shadow active:bg-gray-50"
        style={{ transform: `translateX(${dragX}px)` }}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
        onClick={handleClick}
      >
        <div className="flex flex-wrap items-center gap-2">
          <span className="font-semibold text-gray-900">{p.initials}</span>
          {!isOwner && (
            <Badge variant="info">Compartilhado comigo</Badge>
          )}
          <span className="text-sm text-gray-500">
            {p.bed && `Leito: ${p.bed}`}
            {p.age != null && ` · ${p.age} ${p.age_unit}`}
          </span>
          {p.admission_date && (
            <Badge variant="info">
              Adm: {new Date(p.admission_date).toLocaleDateString('pt-BR')}
            </Badge>
          )}
        </div>

        {p.diagnosis && (
          <p className="text-sm text-gray-700"><strong>Dx:</strong> {p.diagnosis}</p>
        )}
        {p.history && (
          <p className="text-sm text-gray-600"><strong>História:</strong> {p.history}</p>
        )}
        {p.devices && (
          <p className="text-sm text-gray-600"><strong>Dispositivos:</strong> {p.devices}</p>
        )}
        {p.antibiotics && (
          <p className="text-sm text-gray-600"><strong>Antibióticos:</strong> {p.antibiotics}</p>
        )}
        {p.vasoactive_drugs && (
          <p className="text-sm text-gray-600"><strong>Drogas vasoativas:</strong> {p.vasoactive_drugs}</p>
        )}
        {p.exams && (
          <p className="text-sm text-gray-600"><strong>Exames:</strong> {p.exams}</p>
        )}
        {p.pending && (
          <p className="text-sm text-amber-700"><strong>Pendências:</strong> {p.pending}</p>
        )}
        {p.observations && (
          <p className="text-sm text-gray-500"><strong>Observações:</strong> {p.observations}</p>
        )}

        <div className="mt-1 flex flex-wrap items-center gap-2">
          {isOwner && onShare && (
            <button
              type="button"
              onClick={e => { e.stopPropagation(); e.preventDefault(); onShare() }}
              className="text-xs text-brand-600 hover:underline"
            >
              Compartilhar
            </button>
          )}
          <span className="text-xs text-gray-400">
            Toque para editar · Arraste → arquivar · Arraste ← excluir
          </span>
        </div>
      </div>
    </li>
  )
}

export default function PatientNotes() {
  const { user } = useAuth()
  const [patients, setPatients] = useState<Patient[]>([])
  const [loading, setLoading] = useState(true)
  const [view, setView] = useState<'list' | 'form'>('list')
  const [editing, setEditing] = useState<Patient | null>(null)
  const [saving, setSaving] = useState(false)
  const [form, setForm] = useState({
    initials: '',
    age: '',
    bed: '',
    diagnosis: '',
    history: '',
    devices: '',
    antibiotics: '',
    vasoactive_drugs: '',
    exams: '',
    pending: '',
    observations: '',
  })
  const [sharePatient, setSharePatient] = useState<Patient | null>(null)
  const [shareUserId, setShareUserId] = useState('')
  const [shareList, setShareList] = useState<string[]>([])
  const [shareError, setShareError] = useState<string | null>(null)
  const [loadingShares, setLoadingShares] = useState(false)

  const fetchPatients = useCallback(async () => {
    if (!user) return
    setLoading(true)
    const { data } = await apiQuery<Patient[]>('patients', {
      order: 'updated_at.desc',
      select: '*',
    })
    setPatients(data ?? [])
    setLoading(false)
  }, [user])

  useEffect(() => { fetchPatients() }, [fetchPatients])

  useEffect(() => {
    const handler = (e: CustomEvent<{ patients?: boolean; notes?: boolean }>) => {
      if (e.detail?.patients) fetchPatients()
    }
    window.addEventListener('gd-refresh-annotations', handler as EventListener)
    return () => window.removeEventListener('gd-refresh-annotations', handler as EventListener)
  }, [fetchPatients])

  const resetForm = () => setForm({
    initials: '', age: '', bed: '', diagnosis: '', history: '',
    devices: '', antibiotics: '', vasoactive_drugs: '', exams: '',
    pending: '', observations: '',
  })

  const openNew = () => {
    setEditing(null)
    resetForm()
    setView('form')
  }

  const openEdit = (p: Patient) => {
    setEditing(p)
    setForm({
      initials: p.initials,
      age: p.age?.toString() || '',
      bed: p.bed,
      diagnosis: p.diagnosis,
      history: p.history,
      devices: p.devices,
      antibiotics: p.antibiotics,
      vasoactive_drugs: p.vasoactive_drugs,
      exams: p.exams,
      pending: p.pending,
      observations: p.observations,
    })
    setView('form')
  }

  const handleSave = async () => {
    if (!user) return
    setSaving(true)

    const payload = {
      initials: form.initials,
      age: form.age ? parseFloat(form.age) : null,
      bed: form.bed,
      diagnosis: form.diagnosis,
      history: form.history,
      devices: form.devices,
      antibiotics: form.antibiotics,
      vasoactive_drugs: form.vasoactive_drugs,
      exams: form.exams,
      pending: form.pending,
      observations: form.observations,
      updated_at: new Date().toISOString(),
    }

    if (editing) {
      await apiUpdate('patients', { id: `eq.${editing.id}` }, payload)
    } else {
      const id = crypto.randomUUID()
      await apiInsert('patients', {
        id,
        user_id: user.id,
        ...payload,
        age_unit: 'anos',
        created_at: new Date().toISOString(),
      })
    }

    setSaving(false)
    setView('list')
    fetchPatients()
  }

  const handleArchive = async (patient: Patient) => {
    if (!confirm('Arquivar este paciente?')) return
    await apiArchivePatient(patient)
    fetchPatients()
  }

  const handleDelete = async (patient: Patient) => {
    if (!confirm('Excluir este paciente permanentemente? Esta ação não pode ser desfeita.')) return
    await apiDelete('patients', { id: `eq.${patient.id}` })
    fetchPatients()
  }

  const openShareModal = async (patient: Patient) => {
    setSharePatient(patient)
    setShareUserId('')
    setShareError(null)
    setLoadingShares(true)
    const { data } = await apiListPatientShares(patient.id)
    setShareList(data ?? [])
    setLoadingShares(false)
  }

  const closeShareModal = () => {
    setSharePatient(null)
    setShareUserId('')
    setShareList([])
    setShareError(null)
  }

  const handleShareSubmit = async () => {
    if (!user || !sharePatient) return
    const uid = shareUserId.trim()
    if (!uid) {
      setShareError('Informe o ID (UUID) do usuário.')
      return
    }
    setShareError(null)
    const { error } = await apiSharePatient(sharePatient.id, uid, user.id)
    if (error) {
      setShareError(error)
      return
    }
    setShareUserId('')
    const { data } = await apiListPatientShares(sharePatient.id)
    setShareList(data ?? [])
  }

  const handleUnshare = async (sharedWithUserId: string) => {
    if (!sharePatient) return
    await apiUnsharePatient(sharePatient.id, sharedWithUserId)
    setShareList(prev => prev.filter(id => id !== sharedWithUserId))
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-brand-200 border-t-brand-600" />
      </div>
    )
  }

  if (view === 'form') {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <button onClick={() => setView('list')} className="text-sm text-brand-600 hover:underline">&larr; Voltar</button>
          <h1 className="text-2xl font-bold text-gray-900">{editing ? 'Editar Paciente' : 'Novo Paciente'}</h1>
        </div>

        <Card>
          <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-5">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div>
                <label className="block text-sm font-medium text-gray-700">Iniciais</label>
                <input required value={form.initials} onChange={e => setForm(p => ({ ...p, initials: e.target.value }))} className={inputClass} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Idade</label>
                <input type="number" value={form.age} onChange={e => setForm(p => ({ ...p, age: e.target.value }))} className={inputClass} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Leito</label>
                <input value={form.bed} onChange={e => setForm(p => ({ ...p, bed: e.target.value }))} className={inputClass} />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Diagnóstico</label>
              <textarea rows={3} value={form.diagnosis} onChange={e => setForm(p => ({ ...p, diagnosis: e.target.value }))} className={inputClass} />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">História</label>
              <textarea rows={3} value={form.history} onChange={e => setForm(p => ({ ...p, history: e.target.value }))} className={inputClass} />
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">Dispositivos</label>
                <textarea rows={3} value={form.devices} onChange={e => setForm(p => ({ ...p, devices: e.target.value }))} className={inputClass} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Antibióticos</label>
                <textarea rows={3} value={form.antibiotics} onChange={e => setForm(p => ({ ...p, antibiotics: e.target.value }))} className={inputClass} />
              </div>
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">Drogas Vasoativas</label>
                <textarea rows={3} value={form.vasoactive_drugs} onChange={e => setForm(p => ({ ...p, vasoactive_drugs: e.target.value }))} className={inputClass} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Exames</label>
                <textarea rows={3} value={form.exams} onChange={e => setForm(p => ({ ...p, exams: e.target.value }))} className={inputClass} />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Pendências</label>
              <textarea rows={3} value={form.pending} onChange={e => setForm(p => ({ ...p, pending: e.target.value }))} className={inputClass} />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Observações</label>
              <textarea rows={3} value={form.observations} onChange={e => setForm(p => ({ ...p, observations: e.target.value }))} className={inputClass} />
            </div>

            <div className="flex justify-end gap-3 border-t border-gray-200 pt-4">
              <Button type="button" variant="secondary" onClick={() => setView('list')}>Cancelar</Button>
              <Button type="submit" disabled={saving}>{saving ? 'Salvando...' : editing ? 'Salvar' : 'Criar'}</Button>
            </div>
          </form>
        </Card>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Pacientes</h1>
        <Button onClick={openNew}>+ Novo Paciente</Button>
      </div>

      {patients.length === 0 ? (
        <Card>
          <p className="py-8 text-center text-sm text-gray-400">Nenhum paciente ativo. Adicione um novo!</p>
        </Card>
      ) : (
        <Card className="overflow-hidden p-0">
          <ul className="divide-y divide-gray-200">
            {patients.map(p => (
              <PatientRow
                key={p.id}
                patient={p}
                isOwner={!!user && p.user_id === user.id}
                onEdit={() => openEdit(p)}
                onArchive={() => handleArchive(p)}
                onDelete={() => handleDelete(p)}
                onShare={() => openShareModal(p)}
              />
            ))}
          </ul>
        </Card>
      )}

      <Modal open={!!sharePatient} onClose={closeShareModal} title="Compartilhar paciente">
        {sharePatient && (
          <div className="space-y-4">
            <p className="text-sm text-gray-600">
              Compartilhe &quot;{sharePatient.initials}&quot; com outro usuário. Ele poderá ver, editar e excluir este paciente.
            </p>
            <div>
              <label className="block text-sm font-medium text-gray-700">ID (UUID) do usuário</label>
              <div className="mt-1 flex gap-2">
                <input
                  value={shareUserId}
                  onChange={e => setShareUserId(e.target.value)}
                  placeholder="ex: 550e8400-e29b-41d4-a716-446655440000"
                  className="block flex-1 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
                />
                <Button size="sm" onClick={handleShareSubmit} disabled={loadingShares}>Compartilhar</Button>
              </div>
              {shareError && <p className="mt-1 text-sm text-red-600">{shareError}</p>}
            </div>
            {shareList.length > 0 && (
              <div>
                <span className="text-sm font-medium text-gray-700">Compartilhado com:</span>
                <ul className="mt-1 space-y-1">
                  {shareList.map(uid => (
                    <li key={uid} className="flex items-center justify-between rounded bg-gray-50 px-2 py-1 text-sm">
                      <code className="truncate text-gray-600">{uid}</code>
                      <Button size="sm" variant="danger" className="!py-0.5 !text-xs" onClick={() => handleUnshare(uid)}>Remover</Button>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  )
}
