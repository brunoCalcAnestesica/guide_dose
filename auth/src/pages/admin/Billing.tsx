import { Card } from '../../components/ui/Card'

export default function Billing() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Billing / Plano Premium</h1>
      <p className="text-sm text-gray-500">Módulo de assinaturas e pagamentos (placeholder).</p>

      <Card>
        <div className="py-12 text-center">
          <p className="text-sm text-gray-400">
            Sistema de cobrança e planos premium em desenvolvimento.
          </p>
          <p className="mt-2 text-xs text-gray-400">
            Esta funcionalidade será implementada quando o modelo de monetização estiver definido.
          </p>
        </div>
      </Card>
    </div>
  )
}
