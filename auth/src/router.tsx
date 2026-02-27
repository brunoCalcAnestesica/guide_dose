import { Routes, Route } from 'react-router-dom'
import RequireAuth from './auth/RequireAuth'
import RequireAdmin from './auth/RequireAdmin'

import PublicLayout from './components/layout/PublicLayout'
import AppLayout from './components/layout/AppLayout'
import AdminLayout from './components/layout/AdminLayout'

import Home from './pages/public/Home'
import Login from './pages/public/Login'

import Dashboard from './pages/app/Dashboard'
import PatientNotes from './pages/app/PatientNotes'
import GeneralNotes from './pages/app/GeneralNotes'
import Schedule from './pages/app/Schedule'
import Settings from './pages/app/Settings'
import AppFeedback from './pages/app/AppFeedback'
import Export from './pages/app/Export'

import Users from './pages/admin/Users'
import UserDetail from './pages/admin/UserDetail'
import Telemetry from './pages/admin/Telemetry'
import AppVersion from './pages/admin/AppVersion'
import Analytics from './pages/admin/Analytics'
import AdminFeedback from './pages/admin/AdminFeedback'
import Billing from './pages/admin/Billing'
import Logs from './pages/admin/Logs'
import AdminExport from './pages/admin/AdminExport'

export default function AppRouter() {
  return (
    <Routes>
      {/* Rotas públicas */}
      <Route element={<PublicLayout />}>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
      </Route>

      {/* Área do usuário (autenticado) */}
      <Route element={<RequireAuth />}>
        <Route element={<AppLayout />}>
          <Route path="/app" element={<Dashboard />} />
          <Route path="/app/anotacoes/pacientes" element={<PatientNotes />} />
          <Route path="/app/anotacoes/notas" element={<GeneralNotes />} />
          <Route path="/app/escala" element={<Schedule />} />
          <Route path="/app/configuracoes" element={<Settings />} />
          <Route path="/app/feedback" element={<AppFeedback />} />
          <Route path="/app/exportar" element={<Export />} />
        </Route>
      </Route>

      {/* Área admin (autenticado + admin) */}
      <Route element={<RequireAdmin />}>
        <Route element={<AdminLayout />}>
          <Route path="/admin" element={<Users />} />
          <Route path="/admin/usuarios/:id" element={<UserDetail />} />
          <Route path="/admin/telemetria" element={<Telemetry />} />
          <Route path="/admin/versao" element={<AppVersion />} />
          <Route path="/admin/analytics" element={<Analytics />} />
          <Route path="/admin/feedback" element={<AdminFeedback />} />
          <Route path="/admin/billing" element={<Billing />} />
          <Route path="/admin/logs" element={<Logs />} />
          <Route path="/admin/export" element={<AdminExport />} />
        </Route>
      </Route>
    </Routes>
  )
}
