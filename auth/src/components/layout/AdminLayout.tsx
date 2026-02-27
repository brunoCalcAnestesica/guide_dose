import { useState } from 'react'
import { Outlet, useNavigate } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { useAuth } from '../../auth/AuthProvider'

const adminNavItems = [
  { to: '/admin', label: 'Usuários', icon: '👥' },
  { to: '/admin/telemetria', label: 'Telemetria', icon: '📈' },
  { to: '/admin/versao', label: 'Versão do App', icon: '🔄' },
  { to: '/admin/analytics', label: 'Analytics', icon: '📊' },
  { to: '/admin/feedback', label: 'Feedback', icon: '💬' },
  { to: '/admin/billing', label: 'Billing', icon: '💳' },
  { to: '/admin/logs', label: 'Logs de Acesso', icon: '📋' },
  { to: '/admin/export', label: 'Exportar', icon: '📤' },
]

export default function AdminLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const { user, signOut } = useAuth()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    navigate('/')
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar items={adminNavItems} open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="flex flex-1 flex-col overflow-hidden">
        <header className="flex h-16 items-center justify-between border-b border-gray-200 bg-white px-4 lg:px-8">
          <div className="flex items-center gap-4">
            <button onClick={() => setSidebarOpen(true)} className="text-gray-600 lg:hidden">
              <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
            <span className="rounded-md bg-red-100 px-2 py-1 text-xs font-semibold text-red-700">ADMIN</span>
          </div>
          <div className="flex items-center gap-4">
            <button onClick={() => navigate('/app')} className="text-xs font-medium text-brand-600 hover:underline">
              Painel Usuário
            </button>
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
    </div>
  )
}
