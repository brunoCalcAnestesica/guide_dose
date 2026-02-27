import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'

export default function Export() {
  const stub = (label: string) => () => alert(`Exportação "${label}" disponível em breve.`)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Exportar Dados</h1>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <Card title="Anotações de Pacientes">
          <p className="text-sm text-gray-500">Exporte todas as suas anotações de pacientes.</p>
          <div className="mt-4 flex gap-2">
            <Button size="sm" variant="secondary" onClick={stub('Anotações Pacientes CSV')}>CSV</Button>
            <Button size="sm" variant="secondary" onClick={stub('Anotações Pacientes JSON')}>JSON</Button>
          </div>
        </Card>

        <Card title="Notas Gerais">
          <p className="text-sm text-gray-500">Exporte suas notas gerais e bloco de notas.</p>
          <div className="mt-4 flex gap-2">
            <Button size="sm" variant="secondary" onClick={stub('Notas Gerais CSV')}>CSV</Button>
            <Button size="sm" variant="secondary" onClick={stub('Notas Gerais JSON')}>JSON</Button>
          </div>
        </Card>

        <Card title="Escala de Plantões">
          <p className="text-sm text-gray-500">Exporte sua escala completa.</p>
          <div className="mt-4 flex gap-2">
            <Button size="sm" variant="secondary" onClick={stub('Escala CSV')}>CSV</Button>
            <Button size="sm" variant="secondary" onClick={stub('Escala PDF')}>PDF</Button>
          </div>
        </Card>

        <Card title="Exportar Tudo" className="sm:col-span-2 lg:col-span-3">
          <p className="text-sm text-gray-500">Exporte todos os seus dados em um único arquivo.</p>
          <div className="mt-4 flex gap-2">
            <Button onClick={stub('Tudo CSV')}>Exportar tudo (CSV)</Button>
            <Button variant="secondary" onClick={stub('Tudo JSON')}>Exportar tudo (JSON)</Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
