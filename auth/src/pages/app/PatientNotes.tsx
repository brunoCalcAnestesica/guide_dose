import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Modal } from '../../components/ui/Modal'
import { Badge } from '../../components/ui/Badge'
import { mockPatientNotes } from '../../mocks/data'
import type { PatientNote } from '../../types'

export default function PatientNotes() {
  const [notes, setNotes] = useState<PatientNote[]>(mockPatientNotes)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<PatientNote | null>(null)
  const [form, setForm] = useState({ titulo: '', nomePaciente: '', texto: '' })

  const openNew = () => {
    setEditing(null)
    setForm({ titulo: '', nomePaciente: '', texto: '' })
    setModalOpen(true)
  }

  const openEdit = (note: PatientNote) => {
    setEditing(note)
    setForm({ titulo: note.titulo, nomePaciente: note.nomePaciente, texto: note.texto })
    setModalOpen(true)
  }

  const handleSave = () => {
    if (editing) {
      setNotes(prev => prev.map(n => n.id === editing.id ? { ...n, ...form } : n))
    } else {
      const newNote: PatientNote = {
        id: `pn${Date.now()}`,
        ...form,
        data: new Date().toISOString().slice(0, 10),
        anexos: [],
        userId: 'u1',
      }
      setNotes(prev => [newNote, ...prev])
    }
    setModalOpen(false)
  }

  const handleDelete = (id: string) => {
    setNotes(prev => prev.filter(n => n.id !== id))
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Anotações de Pacientes</h1>
        <Button onClick={openNew}>+ Nova Anotação</Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {notes.map(note => (
          <Card key={note.id} className="flex flex-col">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="font-semibold text-gray-900">{note.titulo}</h3>
                <p className="text-xs text-gray-500">{note.nomePaciente} &middot; {new Date(note.data).toLocaleDateString('pt-BR')}</p>
              </div>
              {note.anexos.length > 0 && <Badge variant="info">{note.anexos.length} anexo(s)</Badge>}
            </div>
            <p className="mt-3 flex-1 text-sm text-gray-600 line-clamp-3">{note.texto}</p>
            <div className="mt-4 flex gap-2">
              <Button size="sm" variant="secondary" onClick={() => openEdit(note)}>Editar</Button>
              <Button size="sm" variant="danger" onClick={() => handleDelete(note.id)}>Excluir</Button>
            </div>
          </Card>
        ))}
      </div>

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Anotação' : 'Nova Anotação'}>
        <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Título</label>
            <input
              required
              value={form.titulo}
              onChange={e => setForm(p => ({ ...p, titulo: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Paciente</label>
            <input
              required
              value={form.nomePaciente}
              onChange={e => setForm(p => ({ ...p, nomePaciente: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Texto</label>
            <textarea
              required
              rows={4}
              value={form.texto}
              onChange={e => setForm(p => ({ ...p, texto: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Anexos</label>
            <div className="mt-1 rounded-lg border-2 border-dashed border-gray-300 p-4 text-center text-sm text-gray-400">
              Arraste arquivos aqui ou clique para selecionar (em breve)
            </div>
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
