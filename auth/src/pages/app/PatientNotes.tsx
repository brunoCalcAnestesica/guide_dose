import { useState, useEffect, useCallback } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiInsert, apiUpdate, apiArchivePatient } from '../../lib/api'
import type { Patient } from '../../types'

const inputClass = 'mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500'

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

  const fetchPatients = useCallback(async () => {
    if (!user) return
    setLoading(true)
    const { data } = await apiQuery<Patient[]>('patients', {
      user_id: `eq.${user.id}`,
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
              <li key={p.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between sm:gap-4">
                <div className="min-w-0 flex-1 space-y-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-semibold text-gray-900">{p.initials}</span>
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
                  {p.pending && (
                    <p className="text-sm text-yellow-700"><strong>Pendências:</strong> {p.pending}</p>
                  )}
                  {p.observations && (
                    <p className="text-xs text-gray-400 line-clamp-1">{p.observations}</p>
                  )}
                </div>
                <div className="flex shrink-0 gap-2">
                  <Button size="sm" variant="secondary" onClick={() => openEdit(p)}>Editar</Button>
                  <Button size="sm" variant="danger" onClick={() => handleArchive(p)}>Arquivar</Button>
                </div>
              </li>
            ))}
          </ul>
        </Card>
      )}
    </div>
  )
}
