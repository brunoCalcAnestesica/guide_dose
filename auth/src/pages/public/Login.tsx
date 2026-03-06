import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../../auth/AuthProvider'

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
    <div className="min-h-[calc(100vh-4rem)] flex flex-col items-center justify-center px-4 py-12 bg-gradient-to-br from-guide-50 to-white">
      <div className="w-full max-w-md">
        {/* Logo e título — alinhado à Home */}
        <div className="mb-8 text-center">
          <Link
            to="/"
            className="inline-flex items-center gap-2 rounded-lg transition hover:opacity-90"
          >
            <img src="/logo.png" alt="GuideDose" className="h-10 w-10 rounded-lg" />
            <span className="text-2xl font-bold text-guide-700">Guide Dose ®</span>
          </Link>
          <p className="mt-2 text-sm text-gray-500">Acesse sua conta para continuar</p>
        </div>

        {/* Card do formulário */}
        <div className="rounded-2xl border border-gray-200 bg-white p-8 shadow-lg">
          <div className="mb-6 flex gap-1 rounded-xl bg-gray-100 p-1">
            {tabs.map(t => (
              <button
                key={t.id}
                type="button"
                onClick={() => { setTab(t.id); setMessage(null) }}
                className={`flex-1 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                  tab === t.id
                    ? 'bg-white text-guide-700 shadow-sm'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                {t.label}
              </button>
            ))}
          </div>

          {message && (
            <div
              className={`mb-4 rounded-xl p-3 text-sm ${
                message.type === 'error'
                  ? 'bg-red-50 text-red-700'
                  : 'bg-green-50 text-green-700'
              }`}
            >
              {message.text}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="login-email" className="block text-sm font-medium text-gray-700">
                E-mail
              </label>
              <input
                id="login-email"
                type="email"
                required
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="mt-1 block w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm shadow-sm placeholder:text-gray-400 focus:border-guide-500 focus:outline-none focus:ring-2 focus:ring-guide-500/20"
                placeholder="seu@email.com"
              />
            </div>

            {tab !== 'reset' && (
              <div>
                <label htmlFor="login-password" className="block text-sm font-medium text-gray-700">
                  Senha
                </label>
                <input
                  id="login-password"
                  type="password"
                  required={tab !== 'reset'}
                  minLength={6}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  className="mt-1 block w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm shadow-sm placeholder:text-gray-400 focus:border-guide-500 focus:outline-none focus:ring-2 focus:ring-guide-500/20"
                  placeholder="Mínimo 6 caracteres"
                />
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="mt-2 w-full rounded-xl bg-guide-600 px-4 py-3 text-sm font-semibold text-white shadow-lg transition hover:bg-guide-700 focus:outline-none focus:ring-2 focus:ring-guide-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading
                ? 'Aguarde...'
                : tab === 'login'
                  ? 'Entrar'
                  : tab === 'signup'
                    ? 'Criar conta'
                    : 'Enviar link'}
            </button>
          </form>
        </div>

        <p className="mt-6 text-center text-sm text-gray-500">
          <Link to="/" className="font-medium text-guide-600 hover:text-guide-700">
            ← Voltar para a página inicial
          </Link>
        </p>
      </div>
    </div>
  )
}
