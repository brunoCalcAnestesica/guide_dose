import { useState, useEffect } from 'react'
import { Card } from '../../components/ui/Card'
import { Table } from '../../components/ui/Table'
import { Badge } from '../../components/ui/Badge'
import { adminListUsers } from '../../lib/api'
import type { AdminUser } from '../../types'

const ADMIN_EMAIL_EXCLUDE_FROM_TELEMETRY = 'bhdaroz@gmail.com'

export default function Telemetry() {
  const [users, setUsers] = useState<AdminUser[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    adminListUsers().then(({ data }) => {
      setUsers((data as AdminUser[]) ?? [])
      setLoading(false)
    })
  }, [])

  if (loading) return <p className="text-sm text-gray-500">Carregando telemetria...</p>

  const totalAccess = users
    .filter((u) => (u.email || '').toLowerCase() !== ADMIN_EMAIL_EXCLUDE_FROM_TELEMETRY)
    .reduce((sum, u) => sum + (u.access_count ?? 0), 0)
  const confirmedUsers = users.filter(u => u.email_confirmed_at)
  const recentUsers = users.filter(u => {
    if (!u.last_sign_in_at) return false
    const diff = Date.now() - new Date(u.last_sign_in_at).getTime()
    return diff < 30 * 24 * 60 * 60 * 1000
  })

  const columns = [
    { key: 'email', header: 'Usuário', render: (u: AdminUser) => (
      <div>
        <p className="font-medium text-gray-900">{u.email}</p>
      </div>
    )},
    { key: 'access_count', header: 'Total Acessos', render: (u: AdminUser) => String(u.access_count ?? 0) },
    { key: 'last_sign_in_at', header: 'Último Login', render: (u: AdminUser) => u.last_sign_in_at ? new Date(u.last_sign_in_at).toLocaleString('pt-BR') : '—' },
    { key: 'created_at', header: 'Cadastro', render: (u: AdminUser) => new Date(u.created_at).toLocaleDateString('pt-BR') },
    { key: 'status', header: 'Status', render: (u: AdminUser) => (
      <Badge variant={u.email_confirmed_at ? 'success' : 'warning'}>
        {u.email_confirmed_at ? 'Ativo' : 'Pendente'}
      </Badge>
    )},
  ]

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Telemetria de Uso</h1>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="border-l-4 border-l-brand-500">
          <p className="text-sm text-gray-500">Usuários Cadastrados</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{users.length}</p>
        </Card>
        <Card className="border-l-4 border-l-green-500">
          <p className="text-sm text-gray-500">Total de Acessos</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{totalAccess}</p>
        </Card>
        <Card className="border-l-4 border-l-yellow-500">
          <p className="text-sm text-gray-500">Ativos (30 dias)</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{recentUsers.length}</p>
        </Card>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <Card className="border-l-4 border-l-blue-500">
          <p className="text-sm text-gray-500">E-mails Confirmados</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{confirmedUsers.length}</p>
        </Card>
        <Card className="border-l-4 border-l-red-400">
          <p className="text-sm text-gray-500">E-mails Pendentes</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{users.length - confirmedUsers.length}</p>
        </Card>
      </div>

      <Card title="Detalhamento por Usuário">
        <Table columns={columns} data={users as unknown as Record<string, unknown>[]} />
      </Card>
    </div>
  )
}
