import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from './AuthProvider'

export default function RequireAdmin() {
  const { user, isAdmin, loading } = useAuth()

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-brand-600 border-t-transparent" />
      </div>
    )
  }

  if (!user) return <Navigate to="/login" replace />
  if (!isAdmin) return <Navigate to="/app" replace />

  return <Outlet />
}
