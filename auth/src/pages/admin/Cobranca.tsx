import { useState, useEffect } from 'react'
import { Card } from '../../components/ui/Card'
import { Tabs } from '../../components/ui/Tabs'
import { apiQuery, apiUpdate, apiInsert } from '../../lib/api'
import type { AppConfig } from '../../types'

const BILLING_KEY = 'billing_enabled'

const tabs = [
  { id: 'dashboard', label: 'Dashboard' },
  { id: 'usuarios', label: 'Gestão de Usuários' },
  { id: 'cupons', label: 'Gestão de Cupons' },
  { id: 'pacotes', label: 'Gestão de Pacotes' },
  { id: 'checkout', label: 'Checkout (Stripe)' },
]

function BillingToggle({
  enabled,
  saving,
  onToggle,
}: {
  enabled: boolean
  saving: boolean
  onToggle: () => void
}) {
  return (
    <Card>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-900">Cobrança do app</p>
          <p className="mt-1 text-xs text-gray-500">
            {enabled
              ? 'Ativa — usuários sem assinatura verão a tela de pagamento.'
              : 'Desativada — o app funciona sem exigir pagamento.'}
          </p>
        </div>
        <button
          type="button"
          disabled={saving}
          onClick={onToggle}
          className={`relative inline-flex h-7 w-12 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2 ${
            enabled ? 'bg-brand-600' : 'bg-gray-300'
          } ${saving ? 'opacity-50 cursor-wait' : ''}`}
        >
          <span
            className={`pointer-events-none inline-block h-6 w-6 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
              enabled ? 'translate-x-5' : 'translate-x-0'
            }`}
          />
        </button>
      </div>
    </Card>
  )
}

function TabDashboard({
  billingEnabled,
  billingSaving,
  onToggleBilling,
}: {
  billingEnabled: boolean
  billingSaving: boolean
  onToggleBilling: () => void
}) {
  return (
    <div className="space-y-4">
      <BillingToggle
        enabled={billingEnabled}
        saving={billingSaving}
        onToggle={onToggleBilling}
      />
      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <p className="text-sm text-gray-500">Assinantes ativos</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">—</p>
        </Card>
        <Card>
          <p className="text-sm text-gray-500">Receita mensal</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">—</p>
        </Card>
        <Card>
          <p className="text-sm text-gray-500">Cupons resgatados</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">—</p>
        </Card>
      </div>
    </div>
  )
}

function TabUsuarios() {
  return (
    <Card>
      <div className="py-8 text-center">
        <p className="text-sm text-gray-500">Assinaturas e pagamentos por usuário</p>
        <p className="mt-2 text-xs text-gray-400">
          Aqui será possível visualizar e gerenciar as assinaturas, status de pagamento e histórico de cada usuário.
        </p>
      </div>
    </Card>
  )
}

function TabCupons() {
  return (
    <Card>
      <div className="py-8 text-center">
        <p className="text-sm text-gray-500">Criar e gerenciar cupons de desconto</p>
        <p className="mt-2 text-xs text-gray-400">
          Aqui será possível criar cupons, definir percentual ou valor fixo de desconto, validade e limite de uso.
        </p>
      </div>
    </Card>
  )
}

function TabPacotes() {
  return (
    <Card>
      <div className="py-8 text-center">
        <p className="text-sm text-gray-500">Planos e pacotes disponíveis</p>
        <p className="mt-2 text-xs text-gray-400">
          Aqui será possível criar e editar os pacotes de assinatura (mensal, anual, trial, etc.) com seus respectivos preços e benefícios.
        </p>
      </div>
    </Card>
  )
}

function TabCheckout() {
  return (
    <Card>
      <div className="py-8 text-center">
        <p className="text-sm text-gray-500">Configuração do checkout (Stripe)</p>
        <p className="mt-2 text-xs text-gray-400">
          Aqui será possível configurar as chaves de API do Stripe (publishable key, secret key), webhooks e opções de pagamento.
        </p>
      </div>
    </Card>
  )
}

export default function Cobranca() {
  const [active, setActive] = useState('dashboard')
  const [billingEnabled, setBillingEnabled] = useState(false)
  const [billingSaving, setBillingSaving] = useState(false)
  const [configs, setConfigs] = useState<Record<string, string>>({})
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    apiQuery<AppConfig[]>('app_config', { select: '*', key: `eq.${BILLING_KEY}` }).then(
      ({ data }) => {
        const map: Record<string, string> = {}
        ;(data ?? []).forEach((c) => {
          map[c.key] = c.value
        })
        setConfigs(map)
        setBillingEnabled(map[BILLING_KEY] === 'true')
        setLoading(false)
      },
    )
  }, [])

  const handleToggleBilling = async () => {
    const next = !billingEnabled
    setBillingSaving(true)
    const value = next ? 'true' : 'false'
    const ts = new Date().toISOString()

    const result =
      configs[BILLING_KEY] !== undefined
        ? await apiUpdate('app_config', { key: `eq.${BILLING_KEY}` }, { value, updated_at: ts })
        : await apiInsert('app_config', { key: BILLING_KEY, value, updated_at: ts })

    if (!result.error) {
      setBillingEnabled(next)
      setConfigs((prev) => ({ ...prev, [BILLING_KEY]: value }))
    }
    setBillingSaving(false)
  }

  const renderContent = () => {
    switch (active) {
      case 'dashboard':
        return (
          <TabDashboard
            billingEnabled={billingEnabled}
            billingSaving={billingSaving}
            onToggleBilling={handleToggleBilling}
          />
        )
      case 'usuarios':
        return <TabUsuarios />
      case 'cupons':
        return <TabCupons />
      case 'pacotes':
        return <TabPacotes />
      case 'checkout':
        return <TabCheckout />
      default:
        return (
          <TabDashboard
            billingEnabled={billingEnabled}
            billingSaving={billingSaving}
            onToggleBilling={handleToggleBilling}
          />
        )
    }
  }

  if (loading) return <p className="text-sm text-gray-500">Carregando...</p>

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Cobrança / Pagamento</h1>

      <Tabs tabs={tabs} active={active} onChange={setActive} />

      {renderContent()}
    </div>
  )
}
