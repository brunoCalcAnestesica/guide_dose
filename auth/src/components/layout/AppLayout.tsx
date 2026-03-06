import { useState, useEffect, lazy, Suspense } from 'react'
import { Outlet, useNavigate } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { useAuth } from '../../auth/AuthProvider'

const AiChatSidebar = lazy(() => import('../AiChat/AiChatSidebar'))

function useIsDesktop() {
  const [isDesktop, setIsDesktop] = useState(false)
  useEffect(() => {
    const mq = window.matchMedia('(min-width: 1024px)')
    setIsDesktop(mq.matches)
    const fn = () => setIsDesktop(mq.matches)
    mq.addEventListener('change', fn)
    return () => mq.removeEventListener('change', fn)
  }, [])
  return isDesktop
}

const appNavItems = [
  { to: '/app', label: 'Dashboard', icon: '📊' },
  { to: '/app/anotacoes/pacientes', label: 'Anotações Pacientes', icon: '🏥' },
  { to: '/app/anotacoes/notas', label: 'Notas Gerais', icon: '📝' },
  { to: '/app/escala', label: 'Escala', icon: '📅' },
  { to: '/app/configuracoes', label: 'Configurações', icon: '⚙️' },
  { to: '/app/feedback', label: 'Feedback', icon: '💬' },
  { to: '/app/exportar', label: 'Exportar', icon: '📤' },
]

export default function AppLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [aiChatOpen, setAiChatOpen] = useState(false)
  const isDesktop = useIsDesktop()
  const { user, signOut, isAdmin } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    navigate('/')
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar items={appNavItems} open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="flex min-w-0 flex-1 overflow-hidden">
        <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        <header className="flex h-16 items-center justify-between border-b border-gray-200 bg-white px-4 lg:px-8">
          <button onClick={() => setSidebarOpen(true)} className="text-gray-600 lg:hidden">
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <div className="hidden lg:block" />
          <div className="flex items-center gap-4">
            <button
              onClick={() => setAiChatOpen(prev => !prev)}
              className="flex items-center gap-2 rounded-lg bg-brand-50 px-3 py-1.5 text-sm font-medium text-brand-700 transition-colors hover:bg-brand-100"
            >
              <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09z" />
              </svg>
              IA Médica
            </button>
            {isAdmin && (
              <button onClick={() => navigate('/admin')} className="text-xs font-medium text-brand-600 hover:underline">
                Painel Admin
              </button>
            )}
            <span className="text-sm text-gray-500">{user?.email}</span>
            <button onClick={handleSignOut} className="rounded-lg px-3 py-1.5 text-sm text-gray-600 hover:bg-gray-100">
              Sair
            </button>
          </div>
        </header>
        <main className="flex-1 overflow-y-auto p-4 lg:p-8">
          <Outlet />
        </main>
        </div>

        {/* Painel IA: no desktop empurra o conteúdo; no mobile sobrepõe */}
        <Suspense fallback={null}>
          <AiChatSidebar open={aiChatOpen} onClose={() => setAiChatOpen(false)} inline={isDesktop} />
        </Suspense>
      </div>

      {/* Botão flutuante da IA (mobile) */}
      {!aiChatOpen && (
        <button
          onClick={() => setAiChatOpen(true)}
          className="fixed bottom-6 right-6 z-30 flex h-14 w-14 items-center justify-center rounded-full bg-brand-600 text-white shadow-lg transition-transform hover:scale-105 hover:bg-brand-700 lg:hidden"
        >
          <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.455 2.456L21.75 6l-1.036.259a3.375 3.375 0 00-2.455 2.456z" />
          </svg>
        </button>
      )}

    </div>
  )
}
