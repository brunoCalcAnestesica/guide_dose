import { useState, useEffect, useCallback } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { Modal } from '../../components/ui/Modal'
import { Table } from '../../components/ui/Table'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiInsert, apiUpdate, apiDelete } from '../../lib/api'
import type { Shift } from '../../types'

const emptyForm = {
  date: '',
  hospital_name: '',
  type: 'Diurno',
  start_time: '',
  end_time: '',
  value: '',
  informacoes: '',
  is_all_day: false,
}

export default function Schedule() {
  const { user } = useAuth()
  const [shifts, setShifts] = useState<Shift[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Shift | null>(null)
  const [form, setForm] = useState(emptyForm)
  const [saving, setSaving] = useState(false)

  const fetchData = useCallback(async () => {
    if (!user) return
    setLoading(true)

    const shiftsRes = await apiQuery<Shift[]>('shifts', {
      user_id: `eq.${user.id}`,
      order: 'date.asc',
      select: '*',
    })

    setShifts(shiftsRes.data ?? [])
    setLoading(false)
  }, [user])

  useEffect(() => { fetchData() }, [fetchData])

  const openNew = () => {
    setEditing(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  const openEdit = (shift: Shift) => {
    setEditing(shift)
    setForm({
      date: shift.date,
      hospital_name: shift.hospital_name || '',
      type: shift.type,
      start_time: shift.start_time,
      end_time: shift.end_time,
      value: shift.value?.toString() || '',
      informacoes: shift.informacoes || '',
      is_all_day: shift.is_all_day,
    })
    setModalOpen(true)
  }

  const handleSave = async () => {
    if (!user) return
    setSaving(true)

    const start = form.start_time || '00:00'
    const end = form.end_time || '00:00'
    const [sh, sm] = start.split(':').map(Number)
    const [eh, em] = end.split(':').map(Number)
    let dur = (eh * 60 + em) - (sh * 60 + sm)
    if (dur <= 0) dur += 1440

    const payload = {
      hospital_name: form.hospital_name || '',
      date: form.date,
      start_time: start,
      end_time: end,
      duration_hours: dur / 60,
      value: form.value ? parseFloat(form.value) : 0,
      type: form.type,
      informacoes: form.informacoes || null,
      is_all_day: form.is_all_day,
      updated_at: new Date().toISOString(),
    }

    if (editing) {
      await apiUpdate('shifts', { id: `eq.${editing.id}` }, payload)
    } else {
      const id = crypto.randomUUID()
      await apiInsert('shifts', {
        id,
        user_id: user.id,
        ...payload,
        is_completed: false,
        created_at: new Date().toISOString(),
      })
    }

    setSaving(false)
    setModalOpen(false)
    fetchData()
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Excluir este plantão?')) return
    await apiDelete('shifts', { id: `eq.${id}` })
    fetchData()
  }

  const exportCsv = () => {
    const header = 'Data,Local,Tipo,Inicio,Fim,Valor,Observacoes\n'
    const rows = shifts.map(s =>
      `${s.date},"${s.hospital_name || ''}",${s.type},${s.start_time},${s.end_time},${s.value},"${s.informacoes || ''}"`
    ).join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'escala.csv'
    a.click()
    URL.revokeObjectURL(url)
  }

  if (loading) {
    return <p className="text-sm text-gray-500">Carregando escala...</p>
  }

  const columns = [
    { key: 'date', header: 'Data', render: (s: Shift) => new Date(s.date + 'T12:00').toLocaleDateString('pt-BR') },
    { key: 'hospital_name', header: 'Local', render: (s: Shift) => s.hospital_name || '—' },
    { key: 'type', header: 'Tipo', render: (s: Shift) => <Badge variant={s.type === 'Diurno' ? 'info' : 'warning'}>{s.type}</Badge> },
    { key: 'start_time', header: 'Início' },
    { key: 'end_time', header: 'Fim' },
    { key: 'value', header: 'Valor', render: (s: Shift) => s.value ? `R$ ${s.value.toFixed(2)}` : '—' },
    {
      key: 'acoes', header: 'Ações', render: (s: Shift) => (
        <div className="flex gap-1">
          <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); openEdit(s) }}>Editar</Button>
          <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); handleDelete(s.id) }}>Excluir</Button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Escala de Plantões</h1>
        <div className="flex gap-2">
          <Button variant="secondary" onClick={exportCsv}>Exportar CSV</Button>
          <Button onClick={openNew}>+ Novo Plantão</Button>
        </div>
      </div>

      {shifts.length === 0 ? (
        <Card>
          <p className="py-8 text-center text-sm text-gray-400">Nenhum plantão registrado. Crie um novo!</p>
        </Card>
      ) : (
        <Card>
          <Table columns={columns} data={shifts as unknown as Record<string, unknown>[]} />
        </Card>
      )}

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Plantão' : 'Novo Plantão'}>
        <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Data</label>
              <input type="date" required value={form.date} onChange={e => setForm(p => ({ ...p, date: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Tipo</label>
              <select value={form.type} onChange={e => setForm(p => ({ ...p, type: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500">
                <option>Diurno</option>
                <option>Noturno</option>
                <option>12h</option>
                <option>24h</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Hospital</label>
            <input type="text" value={form.hospital_name} onChange={e => setForm(p => ({ ...p, hospital_name: e.target.value }))}
              placeholder="Nome do hospital"
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Início</label>
              <input type="time" required value={form.start_time} onChange={e => setForm(p => ({ ...p, start_time: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Fim</label>
              <input type="time" required value={form.end_time} onChange={e => setForm(p => ({ ...p, end_time: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Valor (R$)</label>
              <input type="number" step="0.01" value={form.value} onChange={e => setForm(p => ({ ...p, value: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div className="flex items-end">
              <label className="flex items-center gap-2 pb-2">
                <input type="checkbox" checked={form.is_all_day} onChange={e => setForm(p => ({ ...p, is_all_day: e.target.checked }))}
                  className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500" />
                <span className="text-sm text-gray-700">Dia inteiro</span>
              </label>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Informações</label>
            <input value={form.informacoes} onChange={e => setForm(p => ({ ...p, informacoes: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
          </div>
          <div className="flex justify-end gap-2">
            <Button type="button" variant="secondary" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button type="submit" disabled={saving}>{saving ? 'Salvando...' : editing ? 'Salvar' : 'Criar'}</Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
