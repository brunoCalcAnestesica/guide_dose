import { useState, lazy, Suspense } from 'react'
import { Outlet, useNavigate } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { useAuth } from '../../auth/AuthProvider'

const AiChatSidebar = lazy(() => import('../AiChat/AiChatSidebar'))

const appNavItems = [
  { to: '/app', label: 'Dashboard', icon: 'dashboard' as const },
  { to: '/app/anotacoes/pacientes', label: 'Anotações Pacientes', icon: 'patients' as const },
  { to: '/app/anotacoes/notas', label: 'Notas Gerais', icon: 'notes' as const },
  { to: '/app/escala', label: 'Escala', icon: 'schedule' as const },
  { to: '/app/configuracoes', label: 'Configurações', icon: 'settings' as const },
  { to: '/app/feedback', label: 'Feedback', icon: 'feedback' as const },
  { to: '/app/exportar', label: 'Exportar', icon: 'export' as const },
]

export default function AppLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const { user, signOut, isAdmin } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    navigate('/')
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar items={appNavItems} open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="flex min-w-0 flex-1 flex-col overflow-y-auto overflow-x-hidden lg:flex-row lg:overflow-hidden">
        <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        <header className="flex h-16 shrink-0 items-center justify-between border-b border-gray-200 bg-white px-4 lg:px-8">
          <button onClick={() => setSidebarOpen(true)} className="text-gray-600 lg:hidden">
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <div className="hidden lg:block" />
          <div className="flex items-center gap-4">
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

        {/* IA Médica sempre visível, integrada ao layout: coluna à direita no desktop, abaixo do conteúdo no mobile */}
        <Suspense fallback={null}>
          <AiChatSidebar open inline={true} showCloseButton={false} />
        </Suspense>
      </div>

    </div>
  )
}
