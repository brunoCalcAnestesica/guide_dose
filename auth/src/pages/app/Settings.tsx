import { useState } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'

export default function Settings() {
  const [form, setForm] = useState({
    nome: 'Bruno Daroz',
    email: 'bhdaroz@gmail.com',
    crm: '123456-SP',
    especialidade: 'Medicina Intensiva',
    tema: 'claro',
    idioma: 'pt-BR',
    notificacoes: true,
  })
  const [senha, setSenha] = useState({ atual: '', nova: '', confirmar: '' })
  const [saved, setSaved] = useState(false)

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault()
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  const handleChangePassword = (e: React.FormEvent) => {
    e.preventDefault()
    if (senha.nova !== senha.confirmar) {
      alert('As senhas não conferem.')
      return
    }
    alert('Senha alterada com sucesso (mock).')
    setSenha({ atual: '', nova: '', confirmar: '' })
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Configurações</h1>

      <Card title="Dados Pessoais">
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-medium text-gray-700">Nome completo</label>
              <input value={form.nome} onChange={e => setForm(p => ({ ...p, nome: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">E-mail</label>
              <input type="email" value={form.email} onChange={e => setForm(p => ({ ...p, email: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">CRM</label>
              <input value={form.crm} onChange={e => setForm(p => ({ ...p, crm: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Especialidade</label>
              <input value={form.especialidade} onChange={e => setForm(p => ({ ...p, especialidade: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
            </div>
          </div>
          <div className="flex items-center gap-4">
            <Button type="submit">Salvar Alterações</Button>
            {saved && <span className="text-sm text-green-600">Salvo!</span>}
          </div>
        </form>
      </Card>

      <Card title="Preferências">
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-700">Tema</p>
              <p className="text-xs text-gray-500">Claro ou escuro</p>
            </div>
            <select value={form.tema} onChange={e => setForm(p => ({ ...p, tema: e.target.value }))}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500">
              <option value="claro">Claro</option>
              <option value="escuro">Escuro</option>
            </select>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-700">Idioma</p>
              <p className="text-xs text-gray-500">Preparado para internacionalização</p>
            </div>
            <select value={form.idioma} onChange={e => setForm(p => ({ ...p, idioma: e.target.value }))}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500">
              <option value="pt-BR">Português (BR)</option>
              <option value="en">English</option>
              <option value="es">Español</option>
            </select>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-700">Notificações</p>
              <p className="text-xs text-gray-500">Receber alertas de novas versões e plantões</p>
            </div>
            <button
              onClick={() => setForm(p => ({ ...p, notificacoes: !p.notificacoes }))}
              className={`relative h-6 w-11 rounded-full transition-colors ${form.notificacoes ? 'bg-brand-600' : 'bg-gray-300'}`}
            >
              <span className={`absolute top-0.5 left-0.5 h-5 w-5 rounded-full bg-white transition-transform shadow ${form.notificacoes ? 'translate-x-5' : ''}`} />
            </button>
          </div>
        </div>
      </Card>

      <Card title="Alterar Senha">
        <form onSubmit={handleChangePassword} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Senha atual</label>
            <input type="password" required value={senha.atual} onChange={e => setSenha(p => ({ ...p, atual: e.target.value }))}
              className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500" />
          </div>
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
