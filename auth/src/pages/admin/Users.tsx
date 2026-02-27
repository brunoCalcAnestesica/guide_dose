import { useNavigate } from 'react-router-dom'
import { Card } from '../../components/ui/Card'
import { Table } from '../../components/ui/Table'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { mockUsers } from '../../mocks/data'
import type { User } from '../../types'

export default function Users() {
  const navigate = useNavigate()

  const columns = [
    { key: 'nome', header: 'Nome', render: (u: User) => (
      <div>
        <p className="font-medium text-gray-900">{u.nome || '—'}</p>
        <p className="text-xs text-gray-500">{u.email}</p>
      </div>
    )},
    { key: 'especialidade', header: 'Especialidade' },
    { key: 'dataCadastro', header: 'Cadastro', render: (u: User) => new Date(u.dataCadastro).toLocaleDateString('pt-BR') },
    { key: 'status', header: 'Status', render: (u: User) => (
      <Badge variant={u.status === 'ativo' ? 'success' : 'danger'}>{u.status}</Badge>
    )},
    { key: 'tipo', header: 'Tipo', render: (u: User) => (
      <Badge variant={u.tipo === 'admin' ? 'warning' : 'default'}>{u.tipo}</Badge>
    )},
    { key: 'totalLogins', header: 'Logins', render: (u: User) => String(u.totalLogins ?? 0) },
    { key: 'acoes', header: 'Ações', render: (u: User) => (
      <div className="flex gap-1">
        <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); navigate(`/admin/usuarios/${u.id}`) }}>Detalhes</Button>
        <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); alert('Bloquear/Desbloquear (stub)') }}>
          {u.status === 'ativo' ? 'Bloquear' : 'Desbloquear'}
        </Button>
      </div>
    )},
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Gerenciamento de Usuários</h1>
        <p className="text-sm text-gray-500">{mockUsers.length} usuário(s)</p>
      </div>

      <Card>
        <Table
          columns={columns}
          data={mockUsers as unknown as Record<string, unknown>[]}
          onRowClick={(u) => navigate(`/admin/usuarios/${(u as unknown as User).id}`)}
        />
      </Card>
    </div>
  )
}
