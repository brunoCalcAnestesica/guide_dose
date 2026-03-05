import { useState, useEffect } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiUpdate, apiUpdatePassword } from '../../lib/api'
import type { Profile } from '../../types'

export default function Settings() {
  const { user } = useAuth()
  const [loading, setLoading] = useState(true)
  const [form, setForm] = useState({
    full_name: '',
    email: '',
    crm: '',
    specialty: '',
    phone: '',
    address: '',
    rqe: '',
  })
  const [senha, setSenha] = useState({ nova: '', confirmar: '' })
  const [saved, setSaved] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!user) return
    apiQuery<Profile[]>('profiles', { id: `eq.${user.id}`, select: '*' }).then(({ data }) => {
      if (data && data.length > 0) {
        const p = data[0]
        setForm({
          full_name: p.full_name || '',
          email: p.email || user.email || '',
          crm: p.crm || '',
          specialty: p.specialty || '',
          phone: p.phone || '',
          address: p.address || '',
          rqe: p.rqe || '',
        })
      } else {
        setForm(prev => ({ ...prev, email: user.email || '' }))
      }
      setLoading(false)
    })
  }, [user])

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!user) return
    setError(null)

    const { error: err } = await apiUpdate('profiles', { id: `eq.${user.id}` }, {
      full_name: form.full_name || null,
      crm: form.crm || null,
      specialty: form.specialty || null,
      phone: form.phone || null,
      address: form.address || null,
      rqe: form.rqe || null,
    })

    if (err) {
      setError(err)
    } else {
      setSaved(true)
      setTimeout(() => setSaved(false), 2000)
    }
  }

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault()
    if (senha.nova !== senha.confirmar) {
      alert('As senhas não conferem.')
      return
    }
    const result = await apiUpdatePassword(senha.nova)
    if (result.error) {
      alert(result.error)
    } else {
      alert('Senha alterada com sucesso!')
      setSenha({ nova: '', confirmar: '' })
    }
  }

  if (loading) {
    return <p className="text-sm text-gray-500">Carregando configurações...</p>
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Configurações</h1>

      <Card title="Dados Pessoais">
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-medium text-gray-700">Nome completo</label>
              <input value={form.full_name} onChange={e => setForm(p => ({ ...p, full_name: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">E-mail</label>
              <input type="email" value={form.email} disabled
                className="mt-1 block w-full rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">CRM</label>
              <input value={form.crm} onChange={e => setForm(p => ({ ...p, crm: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Especialidade</label>
              <input value={form.specialty} onChange={e => setForm(p => ({ ...p, specialty: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Telefone</label>
              <input value={form.phone} onChange={e => setForm(p => ({ ...p, phone: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">RQE</label>
              <input value={form.rqe} onChange={e => setForm(p => ({ ...p, rqe: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Endereço</label>
            <input value={form.address} onChange={e => setForm(p => ({ ...p, address: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
          </div>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <div className="flex items-center gap-4">
            <Button type="submit">Salvar Alterações</Button>
            {saved && <span className="text-sm text-green-600">Salvo!</span>}
          </div>
        </form>
      </Card>

      <Card title="Alterar Senha">
        <form onSubmit={handleChangePassword} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-medium text-gray-700">Nova senha</label>
              <input type="password" required minLength={6} value={senha.nova} onChange={e => setSenha(p => ({ ...p, nova: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Confirmar nova senha</label>
              <input type="password" required minLength={6} value={senha.confirmar} onChange={e => setSenha(p => ({ ...p, confirmar: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
          </div>
          <Button type="submit">Alterar Senha</Button>
        </form>
      </Card>
    </div>
  )
}
