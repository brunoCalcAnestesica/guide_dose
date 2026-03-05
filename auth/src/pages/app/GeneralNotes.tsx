import { useState, useEffect, useCallback } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Modal } from '../../components/ui/Modal'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiInsert, apiUpdate, apiDelete } from '../../lib/api'
import type { Note } from '../../types'

export default function GeneralNotes() {
  const { user } = useAuth()
  const [notes, setNotes] = useState<Note[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Note | null>(null)
  const [form, setForm] = useState({ title: '', content: '' })
  const [saving, setSaving] = useState(false)

  const fetchNotes = useCallback(async () => {
    if (!user) return
    setLoading(true)
    const { data } = await apiQuery<Note[]>('notes', {
      user_id: `eq.${user.id}`,
      is_archived: 'eq.false',
      order: 'updated_at.desc',
      select: '*',
    })
    setNotes(data ?? [])
    setLoading(false)
  }, [user])

  useEffect(() => { fetchNotes() }, [fetchNotes])

  const openNew = () => {
    setEditing(null)
    setForm({ title: '', content: '' })
    setModalOpen(true)
  }

  const openEdit = (note: Note) => {
    setEditing(note)
    setForm({ title: note.title, content: note.content })
    setModalOpen(true)
  }

  const handleSave = async () => {
    if (!user) return
    setSaving(true)

    if (editing) {
      await apiUpdate('notes', { id: `eq.${editing.id}` }, {
        title: form.title,
        content: form.content,
        updated_at: new Date().toISOString(),
      })
    } else {
      const id = crypto.randomUUID()
      await apiInsert('notes', {
        id,
        user_id: user.id,
        title: form.title || 'Sem título',
        content: form.content,
        is_archived: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
    }

    setSaving(false)
    setModalOpen(false)
    fetchNotes()
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Excluir esta nota?')) return
    await apiDelete('notes', { id: `eq.${id}` })
    fetchNotes()
  }

  if (loading) {
    return <p className="text-sm text-gray-500">Carregando notas...</p>
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Notas Gerais</h1>
        <Button onClick={openNew}>+ Nova Nota</Button>
      </div>

      {notes.length === 0 ? (
        <Card>
          <p className="py-8 text-center text-sm text-gray-400">Nenhuma nota encontrada. Crie uma nova!</p>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {notes.map(note => (
            <Card key={note.id} className="flex flex-col">
              <h3 className="font-semibold text-gray-900">{note.title}</h3>
              <time className="text-xs text-gray-400">{new Date(note.updated_at).toLocaleDateString('pt-BR')}</time>
              <p className="mt-2 flex-1 text-sm text-gray-600 line-clamp-3">{note.content}</p>
              <div className="mt-4 flex gap-2">
                <Button size="sm" variant="secondary" onClick={() => openEdit(note)}>Editar</Button>
                <Button size="sm" variant="danger" onClick={() => handleDelete(note.id)}>Excluir</Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Nota' : 'Nova Nota'}>
        <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Título</label>
            <input
              required
              value={form.title}
              onChange={e => setForm(p => ({ ...p, title: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Conteúdo</label>
            <textarea
              required
              rows={6}
              value={form.content}
              onChange={e => setForm(p => ({ ...p, content: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
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
