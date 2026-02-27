import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'

export default function AppFeedback() {
  const [form, setForm] = useState({ tipo: 'sugestao' as const, mensagem: '' })
  const [sent, setSent] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setSent(true)
    setForm({ tipo: 'sugestao', mensagem: '' })
    setTimeout(() => setSent(false), 3000)
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
          <div className="flex items-center gap-4">
            <Button type="submit">Enviar Feedback</Button>
            {sent && <span className="text-sm text-green-600">Feedback enviado com sucesso!</span>}
          </div>
        </form>
      </Card>
    </div>
  )
}
