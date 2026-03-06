import { useState, useEffect, useCallback } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { Modal } from '../../components/ui/Modal'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiInsert, apiUpdate, apiDelete, apiArchiveNote, apiShareNote, apiUnshareNote, apiListNoteShares } from '../../lib/api'
import type { Note } from '../../types'

const inputClass = 'mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500'

export default function GeneralNotes() {
  const { user } = useAuth()
  const [notes, setNotes] = useState<Note[]>([])
  const [loading, setLoading] = useState(true)
  const [view, setView] = useState<'list' | 'form'>('list')
  const [editing, setEditing] = useState<Note | null>(null)
  const [form, setForm] = useState({ title: '', content: '' })
  const [saving, setSaving] = useState(false)
  const [shareNote, setShareNote] = useState<Note | null>(null)
  const [shareUserId, setShareUserId] = useState('')
  const [shareList, setShareList] = useState<string[]>([])
  const [shareError, setShareError] = useState<string | null>(null)
  const [loadingShares, setLoadingShares] = useState(false)

  const fetchNotes = useCallback(async () => {
    if (!user) return
    setLoading(true)
    const { data } = await apiQuery<Note[]>('notes', {
      order: 'updated_at.desc',
      select: '*',
    })
    setNotes(data ?? [])
    setLoading(false)
  }, [user])

  useEffect(() => { fetchNotes() }, [fetchNotes])

  useEffect(() => {
    const handler = (e: CustomEvent<{ patients?: boolean; notes?: boolean }>) => {
      if (e.detail?.notes) fetchNotes()
    }
    window.addEventListener('gd-refresh-annotations', handler as EventListener)
    return () => window.removeEventListener('gd-refresh-annotations', handler as EventListener)
  }, [fetchNotes])

  const openNew = () => {
    setEditing(null)
    setForm({ title: '', content: '' })
    setView('form')
  }

  const openEdit = (note: Note) => {
    setEditing(note)
    setForm({ title: note.title, content: note.content })
    setView('form')
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
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
    }

    setSaving(false)
    setView('list')
    fetchNotes()
  }

  const handleArchive = async (note: Note) => {
    if (!confirm('Arquivar esta nota?')) return
    await apiArchiveNote(note)
    fetchNotes()
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Excluir esta nota permanentemente?')) return
    await apiDelete('notes', { id: `eq.${id}` })
    fetchNotes()
  }

  const openShareModal = async (note: Note) => {
    setShareNote(note)
    setShareUserId('')
    setShareError(null)
    setLoadingShares(true)
    const { data } = await apiListNoteShares(note.id)
    setShareList(data ?? [])
    setLoadingShares(false)
  }

  const closeShareModal = () => {
    setShareNote(null)
    setShareUserId('')
    setShareList([])
    setShareError(null)
  }

  const handleShareSubmit = async () => {
    if (!user || !shareNote) return
    const uid = shareUserId.trim()
    if (!uid) {
      setShareError('Informe o ID (UUID) do usuário.')
      return
    }
    setShareError(null)
    const { error } = await apiShareNote(shareNote.id, uid, user.id)
    if (error) {
      setShareError(error)
      return
    }
    setShareUserId('')
    const { data } = await apiListNoteShares(shareNote.id)
    setShareList(data ?? [])
  }

  const handleUnshare = async (sharedWithUserId: string) => {
    if (!shareNote) return
    await apiUnshareNote(shareNote.id, sharedWithUserId)
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
          <h1 className="text-2xl font-bold text-gray-900">{editing ? 'Editar Nota' : 'Nova Nota'}</h1>
        </div>

        <Card>
          <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-gray-700">Título</label>
              <input
                required
                value={form.title}
                onChange={e => setForm(p => ({ ...p, title: e.target.value }))}
                className={inputClass}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Conteúdo</label>
              <textarea
                required
                rows={12}
                value={form.content}
                onChange={e => setForm(p => ({ ...p, content: e.target.value }))}
                className={inputClass}
              />
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
        <h1 className="text-2xl font-bold text-gray-900">Notas Gerais</h1>
        <Button onClick={openNew}>+ Nova Nota</Button>
      </div>

      {notes.length === 0 ? (
        <Card>
          <p className="py-8 text-center text-sm text-gray-400">Nenhuma nota encontrada. Crie uma nova!</p>
        </Card>
      ) : (
        <Card className="overflow-hidden p-0">
          <ul className="divide-y divide-gray-200">
            {notes.map(note => (
              <li key={note.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between sm:gap-4">
                <div className="min-w-0 flex-1 space-y-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-semibold text-gray-900">{note.title}</span>
                    {user && note.user_id !== user.id && (
                      <Badge variant="info">Compartilhado comigo</Badge>
                    )}
                    <time className="text-sm text-gray-500">
                      {new Date(note.updated_at).toLocaleDateString('pt-BR')}
                    </time>
                  </div>
                  {note.content && (
                    <p className="text-sm text-gray-600 line-clamp-2">{note.content}</p>
                  )}
                </div>
                <div className="flex shrink-0 flex-wrap gap-2">
                  {user && note.user_id === user.id && (
                    <Button size="sm" variant="secondary" onClick={() => openShareModal(note)}>Compartilhar</Button>
                  )}
                  <Button size="sm" variant="secondary" onClick={() => openEdit(note)}>Editar</Button>
                  <Button size="sm" variant="danger" onClick={() => handleArchive(note)}>Arquivar</Button>
                  <Button size="sm" variant="danger" onClick={() => handleDelete(note.id)} className="!bg-red-700 hover:!bg-red-800">Excluir</Button>
                </div>
              </li>
            ))}
          </ul>
        </Card>
      )}

      <Modal open={!!shareNote} onClose={closeShareModal} title="Compartilhar nota">
        {shareNote && (
          <div className="space-y-4">
            <p className="text-sm text-gray-600">
              Compartilhe &quot;{shareNote.title}&quot; com outro usuário. Ele poderá ver, editar e excluir esta nota.
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
