import { Card } from '../../components/ui/Card'
import { Table } from '../../components/ui/Table'
import { Badge } from '../../components/ui/Badge'
import { mockUsers } from '../../mocks/data'
import type { User } from '../../types'

export default function Telemetry() {
  const columns = [
    { key: 'nome', header: 'Usuário', render: (u: User) => (
      <div>
        <p className="font-medium text-gray-900">{u.nome || '—'}</p>
        <p className="text-xs text-gray-500">{u.email}</p>
      </div>
    )},
    { key: 'totalLogins', header: 'Total Logins', render: (u: User) => String(u.totalLogins ?? 0) },
    { key: 'ultimoAcesso', header: 'Último Acesso', render: (u: User) => u.ultimoAcesso ? new Date(u.ultimoAcesso).toLocaleDateString('pt-BR') : '—' },
    { key: 'pais', header: 'País' },
    { key: 'cidade', header: 'Cidade' },
    { key: 'deviceType', header: 'Dispositivo', render: (u: User) => <Badge>{u.deviceType || '—'}</Badge> },
  ]

  const totalLogins = mockUsers.reduce((sum, u) => sum + (u.totalLogins ?? 0), 0)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Telemetria de Uso</h1>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="border-l-4 border-l-brand-500">
          <p className="text-sm text-gray-500">Usuários Cadastrados</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{mockUsers.length}</p>
        </Card>
        <Card className="border-l-4 border-l-green-500">
          <p className="text-sm text-gray-500">Total de Logins</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{totalLogins}</p>
        </Card>
        <Card className="border-l-4 border-l-yellow-500">
          <p className="text-sm text-gray-500">Usuários Ativos (30d)</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{mockUsers.filter(u => u.status === 'ativo').length}</p>
        </Card>
      </div>

      <Card title="Detalhamento por Usuário">
        <Table columns={columns} data={mockUsers as unknown as Record<string, unknown>[]} />
      </Card>
    </div>
  )
}
