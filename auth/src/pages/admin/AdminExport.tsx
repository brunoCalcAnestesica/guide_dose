import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'

export default function AdminExport() {
  const stub = (label: string) => () => alert(`Exportação "${label}" disponível em breve.`)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Exportar Dados (Admin)</h1>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <Card title="Usuários">
          <p className="text-sm text-gray-500">Exporte a lista completa de usuários.</p>
          <div className="mt-4 flex gap-2">
            <Button size="sm" variant="secondary" onClick={stub('Usuários CSV')}>CSV</Button>
            <Button size="sm" variant="secondary" onClick={stub('Usuários JSON')}>JSON</Button>
          </div>
        </Card>

        <Card title="Logs de Acesso">
          <p className="text-sm text-gray-500">Exporte os logs de acesso do sistema.</p>
          <div className="mt-4 flex gap-2">
            <Button size="sm" variant="secondary" onClick={stub('Logs CSV')}>CSV</Button>
            <Button size="sm" variant="secondary" onClick={stub('Logs JSON')}>JSON</Button>
          </div>
        </Card>

        <Card title="Feedbacks">
          <p className="text-sm text-gray-500">Exporte os feedbacks recebidos.</p>
          <div className="mt-4 flex gap-2">
            <Button size="sm" variant="secondary" onClick={stub('Feedbacks CSV')}>CSV</Button>
            <Button size="sm" variant="secondary" onClick={stub('Feedbacks JSON')}>JSON</Button>
          </div>
        </Card>

        <Card title="Exportar Tudo" className="sm:col-span-2 lg:col-span-3">
          <p className="text-sm text-gray-500">Exportação completa dos dados administrativos.</p>
          <div className="mt-4 flex gap-2">
            <Button onClick={stub('Admin Tudo CSV')}>Exportar tudo (CSV)</Button>
            <Button variant="secondary" onClick={stub('Admin Tudo JSON')}>Exportar tudo (JSON)</Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
