import { Card } from '../../components/ui/Card'
import { Table } from '../../components/ui/Table'
import { Badge } from '../../components/ui/Badge'
import { mockAccessLogs } from '../../mocks/data'
import type { AccessLog } from '../../types'

const acaoColors: Record<AccessLog['acao'], 'success' | 'danger' | 'info'> = {
  login: 'success',
  logout: 'danger',
  acessoPagina: 'info',
}

export default function Logs() {
  const columns = [
    { key: 'email', header: 'Usuário' },
    { key: 'acao', header: 'Ação', render: (l: AccessLog) => <Badge variant={acaoColors[l.acao]}>{l.acao}</Badge> },
    { key: 'dataHora', header: 'Data/Hora', render: (l: AccessLog) => new Date(l.dataHora).toLocaleString('pt-BR') },
    { key: 'ip', header: 'IP' },
  ]

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Logs de Acesso</h1>

      <Card>
        <Table columns={columns} data={mockAccessLogs as unknown as Record<string, unknown>[]} />
      </Card>
    </div>
  )
}
