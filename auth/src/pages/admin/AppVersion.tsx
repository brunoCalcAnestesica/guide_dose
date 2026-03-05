import { useState, useEffect } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Badge } from '../../components/ui/Badge'
import { apiQuery, apiUpdate, apiInsert } from '../../lib/api'
import type { AppConfig } from '../../types'

export default function AppVersion() {
  const [loading, setLoading] = useState(true)
  const [configs, setConfigs] = useState<Record<string, string>>({})
  const [form, setForm] = useState({
    currentVersion: '',
    minRequiredVersion: '',
    changelog: '',
  })
  const [saved, setSaved] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [loadError, setLoadError] = useState<string | null>(null)

  useEffect(() => {
    apiQuery<AppConfig[]>('app_config', { select: '*' }).then(({ data, error: err }) => {
      if (err) {
        setLoadError(
          'Não foi possível carregar a configuração de versão. ' +
          'Verifique se a tabela app_config existe no Supabase e se as permissões RLS estão corretas.'
        )
        setLoading(false)
        return
      }
      const map: Record<string, string> = {}
      ;(data ?? []).forEach(c => { map[c.key] = c.value })
      setConfigs(map)
      setForm({
        currentVersion:
          map['current_version'] ||
          map['latest_ios_version'] ||
          map['latest_android_version'] ||
          '',
        minRequiredVersion: map['min_required_version'] || '',
        changelog: map['changelog'] || '',
      })
      setLoading(false)
    })
  }, [])

  const upsertConfig = async (key: string, value: string) => {
    if (configs[key] !== undefined) {
      return apiUpdate('app_config', { key: `eq.${key}` }, { value, updated_at: new Date().toISOString() })
    } else {
      return apiInsert('app_config', { key, value, updated_at: new Date().toISOString() })
    }
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)

    const results = await Promise.all([
      upsertConfig('current_version', form.currentVersion),
      upsertConfig('min_required_version', form.minRequiredVersion),
      upsertConfig('changelog', form.changelog),
      upsertConfig('latest_ios_version', form.currentVersion),
      upsertConfig('latest_android_version', form.currentVersion),
    ])

    const err = results.find(r => r.error)
    if (err) {
      setError(
        (err.error || 'Erro ao salvar.') +
        ' Verifique se a tabela app_config existe no Supabase e se as policies de INSERT/UPDATE estão configuradas.'
      )
    } else {
      setSaved(true)
      setLoadError(null)
      setConfigs(prev => ({
        ...prev,
        current_version: form.currentVersion,
        min_required_version: form.minRequiredVersion,
        changelog: form.changelog,
        latest_ios_version: form.currentVersion,
        latest_android_version: form.currentVersion,
      }))
      setTimeout(() => setSaved(false), 2000)
    }
  }

  if (loading) return <p className="text-sm text-gray-500">Carregando configuração de versão...</p>

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Atualizar Versão do App</h1>

      {loadError && (
        <div className="rounded-lg border border-yellow-300 bg-yellow-50 p-4 text-sm text-yellow-800">
          {loadError}
        </div>
      )}

      <Card title="Versão Atual">
        <div className="flex items-center gap-4">
          <span className="text-3xl font-bold text-brand-700">{form.currentVersion || '—'}</span>
          {form.minRequiredVersion && (
            <Badge variant="warning">Mín: {form.minRequiredVersion}</Badge>
          )}
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
              <p className="mt-1 text-xs text-gray-400">
                Será gravada como versão iOS e Android nas lojas.
              </p>
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
          {error && <p className="text-sm text-red-600">{error}</p>}
          <div className="flex items-center gap-4">
            <Button type="submit">Salvar Versão</Button>
            {saved && <span className="text-sm text-green-600">Versão salva!</span>}
          </div>
        </form>
      </Card>
    </div>
  )
}
