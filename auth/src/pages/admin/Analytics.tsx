import { Card } from '../../components/ui/Card'

export default function Analytics() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Analytics Clínico</h1>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <Card title="Tendência de Uso por Horário">
          <div className="flex h-48 items-center justify-center rounded-lg bg-gray-50">
            <p className="text-sm text-gray-400">Gráfico disponível em breve</p>
          </div>
        </Card>

        <Card title="Módulos Mais Acessados">
          <div className="space-y-3">
            {[
              { nome: 'Farmacoteca', pct: 38 },
              { nome: 'Cálculos de Dose', pct: 27 },
              { nome: 'Protocolos', pct: 18 },
              { nome: 'Scores', pct: 12 },
              { nome: 'Outros', pct: 5 },
            ].map(item => (
              <div key={item.nome}>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-700">{item.nome}</span>
                  <span className="font-medium text-gray-900">{item.pct}%</span>
                </div>
                <div className="mt-1 h-2 rounded-full bg-gray-100">
                  <div className="h-2 rounded-full bg-brand-500" style={{ width: `${item.pct}%` }} />
                </div>
              </div>
            ))}
          </div>
        </Card>

        <Card title="Logins por Dia (últimos 7d)">
          <div className="flex h-48 items-end justify-between gap-2 rounded-lg bg-gray-50 px-4 pb-4 pt-8">
            {[12, 18, 9, 24, 15, 21, 16].map((val, i) => (
              <div key={i} className="flex flex-1 flex-col items-center gap-1">
                <div className="w-full rounded-t bg-brand-500" style={{ height: `${(val / 24) * 100}%` }} />
                <span className="text-xs text-gray-500">{['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][i]}</span>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  )
}
