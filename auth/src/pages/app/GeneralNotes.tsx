import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { Modal } from '../../components/ui/Modal'
import { mockGeneralNotes } from '../../mocks/data'
import type { GeneralNote } from '../../types'

export default function GeneralNotes() {
  const [notes, setNotes] = useState<GeneralNote[]>(mockGeneralNotes)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<GeneralNote | null>(null)
  const [form, setForm] = useState({ titulo: '', texto: '', tags: '' })

  const openNew = () => {
    setEditing(null)
    setForm({ titulo: '', texto: '', tags: '' })
    setModalOpen(true)
  }

  const openEdit = (note: GeneralNote) => {
    setEditing(note)
    setForm({ titulo: note.titulo, texto: note.texto, tags: note.tags.join(', ') })
    setModalOpen(true)
  }

  const handleSave = () => {
    const tags = form.tags.split(',').map(t => t.trim()).filter(Boolean)
    if (editing) {
      setNotes(prev => prev.map(n => n.id === editing.id ? { ...n, titulo: form.titulo, texto: form.texto, tags } : n))
    } else {
      const newNote: GeneralNote = {
        id: `gn${Date.now()}`,
        titulo: form.titulo,
        texto: form.texto,
        tags,
        data: new Date().toISOString().slice(0, 10),
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
        <h1 className="text-2xl font-bold text-gray-900">Notas Gerais</h1>
        <Button onClick={openNew}>+ Nova Nota</Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {notes.map(note => (
          <Card key={note.id} className="flex flex-col">
            <h3 className="font-semibold text-gray-900">{note.titulo}</h3>
            <time className="text-xs text-gray-400">{new Date(note.data).toLocaleDateString('pt-BR')}</time>
            <p className="mt-2 flex-1 text-sm text-gray-600 line-clamp-3">{note.texto}</p>
            <div className="mt-3 flex flex-wrap gap-1">
              {note.tags.map(tag => (
                <Badge key={tag} variant="info">{tag}</Badge>
              ))}
            </div>
            <div className="mt-4 flex gap-2">
              <Button size="sm" variant="secondary" onClick={() => openEdit(note)}>Editar</Button>
              <Button size="sm" variant="danger" onClick={() => handleDelete(note.id)}>Excluir</Button>
            </div>
          </Card>
        ))}
      </div>

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Nota' : 'Nova Nota'}>
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
            <label className="block text-sm font-medium text-gray-700">Tags (separadas por vírgula)</label>
            <input
              value={form.tags}
              onChange={e => setForm(p => ({ ...p, tags: e.target.value }))}
              placeholder="Plantão, Ideia, Aula"
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
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
