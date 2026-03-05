import { Card } from '../../components/ui/Card'

export default function Logs() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Logs de Acesso</h1>

      <Card>
        <div className="py-12 text-center">
          <p className="text-sm text-gray-400">
            Módulo de logs de acesso detalhados em desenvolvimento.
          </p>
          <p className="mt-2 text-xs text-gray-400">
            Os dados de contagem de acessos por usuário estão disponíveis na seção de Telemetria.
          </p>
        </div>
      </Card>
    </div>
  )
}
