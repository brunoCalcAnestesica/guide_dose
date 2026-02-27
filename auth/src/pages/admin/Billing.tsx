import { Card } from '../../components/ui/Card'
import { Table } from '../../components/ui/Table'
import { Badge } from '../../components/ui/Badge'
import { mockBilling, mockUsers } from '../../mocks/data'
import type { BillingInfo } from '../../types'

export default function Billing() {
  const columns = [
    {
      key: 'userId', header: 'Usuário', render: (b: BillingInfo) => {
        const user = mockUsers.find(u => u.id === b.userId)
        return <span>{user?.nome || user?.email || b.userId}</span>
      },
    },
    { key: 'plano', header: 'Plano', render: (b: BillingInfo) => <Badge variant={b.plano === 'premium' ? 'success' : 'default'}>{b.plano}</Badge> },
    {
      key: 'statusPagamento', header: 'Status', render: (b: BillingInfo) => (
        <Badge variant={b.statusPagamento === 'ativo' ? 'success' : b.statusPagamento === 'pendente' ? 'warning' : 'danger'}>
          {b.statusPagamento}
        </Badge>
      ),
    },
    { key: 'dataInicio', header: 'Início', render: (b: BillingInfo) => new Date(b.dataInicio).toLocaleDateString('pt-BR') },
    { key: 'dataRenovacao', header: 'Renovação', render: (b: BillingInfo) => b.dataRenovacao ? new Date(b.dataRenovacao).toLocaleDateString('pt-BR') : '—' },
  ]

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Billing / Plano Premium</h1>
      <p className="text-sm text-gray-500">Módulo de assinaturas e pagamentos (placeholder).</p>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="border-l-4 border-l-green-500">
          <p className="text-sm text-gray-500">Premium Ativos</p>
          <p className="mt-1 text-3xl font-bold">{mockBilling.filter(b => b.plano === 'premium' && b.statusPagamento === 'ativo').length}</p>
        </Card>
        <Card className="border-l-4 border-l-yellow-500">
          <p className="text-sm text-gray-500">Pagamento Pendente</p>
          <p className="mt-1 text-3xl font-bold">{mockBilling.filter(b => b.statusPagamento === 'pendente').length}</p>
        </Card>
        <Card className="border-l-4 border-l-gray-400">
          <p className="text-sm text-gray-500">Free</p>
          <p className="mt-1 text-3xl font-bold">{mockBilling.filter(b => b.plano === 'free').length}</p>
        </Card>
      </div>

      <Card>
        <Table columns={columns} data={mockBilling as unknown as Record<string, unknown>[]} />
      </Card>
    </div>
  )
}
