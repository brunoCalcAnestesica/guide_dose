import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { useAuth } from '../../auth/AuthProvider'
import { apiInsert } from '../../lib/api'

export default function AppFeedback() {
  const { user } = useAuth()
  const [form, setForm] = useState({ tipo: 'sugestao' as 'sugestao' | 'bug' | 'ideia', mensagem: '' })
  const [sent, setSent] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [sending, setSending] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!user) return
    setSending(true)
    setError(null)

    const { error: err } = await apiInsert('feedback', {
      id: crypto.randomUUID(),
      user_id: user.id,
      user_email: user.email || '',
      tipo: form.tipo,
      mensagem: form.mensagem,
      status: 'pendente',
      created_at: new Date().toISOString(),
    })

    setSending(false)
    if (err) {
      setError(err)
    } else {
      setSent(true)
      setForm({ tipo: 'sugestao', mensagem: '' })
      setTimeout(() => setSent(false), 3000)
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Feedback</h1>

      <Card title="Envie seu feedback">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Tipo</label>
            <select
              value={form.tipo}
              onChange={e => setForm(p => ({ ...p, tipo: e.target.value as 'sugestao' | 'bug' | 'ideia' }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            >
              <option value="sugestao">Sugestão</option>
              <option value="bug">Bug / Problema</option>
              <option value="ideia">Ideia</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Mensagem</label>
            <textarea
              required
              rows={5}
              value={form.mensagem}
              onChange={e => setForm(p => ({ ...p, mensagem: e.target.value }))}
              placeholder="Descreva sua sugestão, problema ou ideia..."
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <div className="flex items-center gap-4">
            <Button type="submit" disabled={sending}>{sending ? 'Enviando...' : 'Enviar Feedback'}</Button>
            {sent && <span className="text-sm text-green-600">Feedback enviado com sucesso!</span>}
          </div>
        </form>
      </Card>
    </div>
  )
}
