import { Link, Outlet } from 'react-router-dom'
import { useAuth } from '../../auth/AuthProvider'

export default function PublicLayout() {
  const { user, isAdmin } = useAuth()

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="sticky top-0 z-20 border-b border-gray-200 bg-white/90 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link to="/" className="flex items-center gap-2">
            <img src="/logo.png" alt="GuideDose" className="h-8 w-8 rounded-lg" />
            <span className="text-xl font-bold text-guide-700">GuideDose</span>
          </Link>
          <nav className="flex items-center gap-3">
            {user ? (
              <>
                <Link to="/app" className="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">
                  Painel
                </Link>
                {isAdmin && (
                  <Link to="/admin" className="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">
                    Admin
                  </Link>
                )}
              </>
            ) : (
              <Link
                to="/login"
                className="rounded-xl bg-guide-600 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-guide-700"
              >
                Entrar
              </Link>
            )}
          </nav>
        </div>
      </header>
      <main>
        <Outlet />
      </main>
      <footer className="border-t border-gray-200 bg-white">
        <div className="mx-auto max-w-7xl px-4 py-8 text-center text-sm text-gray-500 sm:px-6 lg:px-8">
          &copy; {new Date().getFullYear()} GuideDose. Todos os direitos reservados.
        </div>
      </footer>
    </div>
  )
}
