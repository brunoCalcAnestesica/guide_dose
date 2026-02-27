import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../../auth/AuthProvider'
import { Button } from '../../components/ui/Button'

type Tab = 'login' | 'signup' | 'reset'

export default function Login() {
  const [tab, setTab] = useState<Tab>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null)
  const [loading, setLoading] = useState(false)
  const { signIn, signUp, resetPassword } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setMessage(null)
    setLoading(true)

    try {
      if (tab === 'login') {
        const { error } = await signIn(email, password)
        if (error) { setMessage({ text: error, type: 'error' }); return }
        navigate('/app')
      } else if (tab === 'signup') {
        const { error } = await signUp(email, password)
        if (error) { setMessage({ text: error, type: 'error' }); return }
        setMessage({ text: 'Cadastro realizado! Verifique seu e-mail.', type: 'success' })
      } else {
        const { error } = await resetPassword(email)
        if (error) { setMessage({ text: error, type: 'error' }); return }
        setMessage({ text: 'Link de recuperação enviado ao e-mail.', type: 'success' })
      }
    } finally {
      setLoading(false)
    }
  }

  const tabs: { id: Tab; label: string }[] = [
    { id: 'login', label: 'Entrar' },
    { id: 'signup', label: 'Criar conta' },
    { id: 'reset', label: 'Recuperar senha' },
  ]

  return (
    <div className="flex min-h-[calc(100vh-4rem)] items-center justify-center px-4 py-12">
      <div className="w-full max-w-md">
        <div className="mb-8 text-center">
          <Link to="/" className="inline-flex items-center gap-2">
            <img src="/logo.png" alt="GuideDose" className="h-10 w-10 rounded-lg" />
            <span className="text-2xl font-bold text-brand-700">GuideDose</span>
          </Link>
          <p className="mt-2 text-sm text-gray-500">Acesse sua conta para continuar</p>
        </div>

        <div className="rounded-xl border border-gray-200 bg-white p-8 shadow-sm">
          <div className="mb-6 flex gap-1 rounded-lg bg-gray-100 p-1">
            {tabs.map(t => (
              <button
                key={t.id}
                onClick={() => { setTab(t.id); setMessage(null) }}
                className={`flex-1 rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                  tab === t.id ? 'bg-white text-brand-700 shadow-sm' : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                {t.label}
              </button>
            ))}
          </div>

          {message && (
            <div className={`mb-4 rounded-lg p-3 text-sm ${
              message.type === 'error' ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'
            }`}>
              {message.text}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">E-mail</label>
              <input
                type="email"
                required
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
                placeholder="seu@email.com"
              />
            </div>

            {tab !== 'reset' && (
              <div>
                <label className="block text-sm font-medium text-gray-700">Senha</label>
                <input
                  type="password"
                  required
                  minLength={6}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
                  placeholder="Mínimo 6 caracteres"
                />
              </div>
            )}

            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? 'Aguarde...' : tab === 'login' ? 'Entrar' : tab === 'signup' ? 'Criar conta' : 'Enviar link'}
            </Button>
          </form>
        </div>
      </div>
    </div>
  )
}
