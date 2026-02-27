import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { mockAppVersion } from '../../mocks/data'

export default function AppVersion() {
  const [form, setForm] = useState({
    currentVersion: mockAppVersion.currentVersion,
    minRequiredVersion: mockAppVersion.minRequiredVersion,
    changelog: mockAppVersion.changelog,
    recomendada: mockAppVersion.recomendada,
    obrigatoria: mockAppVersion.obrigatoria,
  })
  const [saved, setSaved] = useState(false)

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault()
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Atualizar Versão do App</h1>

      <Card title="Versão Atual">
        <div className="flex items-center gap-4">
          <span className="text-3xl font-bold text-brand-700">{form.currentVersion}</span>
          {form.recomendada && <Badge variant="success">Recomendada</Badge>}
          {form.obrigatoria && <Badge variant="danger">Obrigatória</Badge>}
          <span className="text-sm text-gray-500">Publicada em {new Date(mockAppVersion.dataPublicacao).toLocaleDateString('pt-BR')}</span>
        </div>
      </Card>

      <Card title="Editar Versão">
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-medium text-gray-700">Versão atual</label>
              <input
                required
                value={form.currentVersion}
                onChange={e => setForm(p => ({ ...p, currentVersion: e.target.value }))}
                placeholder="Ex: 2.0.1"
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Versão mínima obrigatória</label>
              <input
                required
                value={form.minRequiredVersion}
                onChange={e => setForm(p => ({ ...p, minRequiredVersion: e.target.value }))}
                placeholder="Ex: 1.8.0"
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Changelog</label>
            <textarea
              required
              rows={4}
              value={form.changelog}
              onChange={e => setForm(p => ({ ...p, changelog: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </div>
          <div className="flex gap-6">
            <label className="flex items-center gap-2">
              <input type="checkbox" checked={form.recomendada} onChange={e => setForm(p => ({ ...p, recomendada: e.target.checked }))}
                className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500" />
              <span className="text-sm text-gray-700">Atualização recomendada</span>
            </label>
            <label className="flex items-center gap-2">
              <input type="checkbox" checked={form.obrigatoria} onChange={e => setForm(p => ({ ...p, obrigatoria: e.target.checked }))}
                className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500" />
              <span className="text-sm text-gray-700">Atualização obrigatória</span>
            </label>
          </div>
          <div className="flex items-center gap-4">
            <Button type="submit">Salvar Versão</Button>
            {saved && <span className="text-sm text-green-600">Versão salva!</span>}
          </div>
        </form>
      </Card>
    </div>
  )
}
