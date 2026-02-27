import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { Modal } from '../../components/ui/Modal'
import { Table } from '../../components/ui/Table'
import { mockShifts } from '../../mocks/data'
import type { Shift } from '../../types'

const emptyForm = { data: '', local: '', tipoPlantao: 'Diurno', horarioInicio: '', horarioFim: '', observacoes: '' }

export default function Schedule() {
  const [shifts, setShifts] = useState<Shift[]>(mockShifts)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Shift | null>(null)
  const [form, setForm] = useState(emptyForm)

  const openNew = () => {
    setEditing(null)
    setForm(emptyForm)
    setModalOpen(true)
  }

  const openEdit = (shift: Shift) => {
    setEditing(shift)
    setForm({
      data: shift.data,
      local: shift.local,
      tipoPlantao: shift.tipoPlantao,
      horarioInicio: shift.horarioInicio,
      horarioFim: shift.horarioFim,
      observacoes: shift.observacoes || '',
    })
    setModalOpen(true)
  }

  const handleSave = () => {
    if (editing) {
      setShifts(prev => prev.map(s => s.id === editing.id ? { ...s, ...form } : s))
    } else {
      const newShift: Shift = { id: `s${Date.now()}`, ...form, userId: 'u1' }
      setShifts(prev => [...prev, newShift].sort((a, b) => a.data.localeCompare(b.data)))
    }
    setModalOpen(false)
  }

  const handleDelete = (id: string) => {
    setShifts(prev => prev.filter(s => s.id !== id))
  }

  const exportCsv = () => {
    // Stub: preparado para exportação real
    alert('Exportação CSV em breve.')
  }

  const columns = [
    { key: 'data', header: 'Data', render: (s: Shift) => new Date(s.data + 'T12:00').toLocaleDateString('pt-BR') },
    { key: 'local', header: 'Local' },
    { key: 'tipoPlantao', header: 'Tipo', render: (s: Shift) => <Badge variant={s.tipoPlantao === 'Diurno' ? 'info' : 'warning'}>{s.tipoPlantao}</Badge> },
    { key: 'horarioInicio', header: 'Início' },
    { key: 'horarioFim', header: 'Fim' },
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

      <Card>
        <Table columns={columns} data={shifts as unknown as Record<string, unknown>[]} />
      </Card>

      <Card title="Calendário" className="text-center">
        <p className="py-8 text-sm text-gray-400">Visualização em calendário disponível em breve.</p>
      </Card>

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Plantão' : 'Novo Plantão'}>
        <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Data</label>
              <input type="date" required value={form.data} onChange={e => setForm(p => ({ ...p, data: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Tipo</label>
              <select value={form.tipoPlantao} onChange={e => setForm(p => ({ ...p, tipoPlantao: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500">
                <option>Diurno</option>
                <option>Noturno</option>
                <option>12h</option>
                <option>24h</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Local</label>
            <input required value={form.local} onChange={e => setForm(p => ({ ...p, local: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Início</label>
              <input type="time" required value={form.horarioInicio} onChange={e => setForm(p => ({ ...p, horarioInicio: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Fim</label>
              <input type="time" required value={form.horarioFim} onChange={e => setForm(p => ({ ...p, horarioFim: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Observações</label>
            <input value={form.observacoes} onChange={e => setForm(p => ({ ...p, observacoes: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
          </div>
          <div className="flex justify-end gap-2">
            <Button type="button" variant="secondary" onClick={() => setModalOpen(false)}>Cancelar</Button>
            <Button type="submit">{editing ? 'Salvar' : 'Criar'}</Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
