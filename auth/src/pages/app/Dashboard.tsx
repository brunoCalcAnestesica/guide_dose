import { Card } from '../../components/ui/Card'
import { Badge } from '../../components/ui/Badge'
import { mockPatientNotes, mockShifts, mockNotifications } from '../../mocks/data'

export default function Dashboard() {
  const recentNotes = mockPatientNotes.slice(0, 3)
  const nextShifts = mockShifts.slice(0, 3)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <Card className="border-l-4 border-l-brand-500">
          <p className="text-sm font-medium text-gray-500">Anotações de Pacientes</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{mockPatientNotes.length}</p>
        </Card>
        <Card className="border-l-4 border-l-green-500">
          <p className="text-sm font-medium text-gray-500">Próximos Plantões</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{mockShifts.length}</p>
        </Card>
        <Card className="border-l-4 border-l-yellow-500">
          <p className="text-sm font-medium text-gray-500">Notificações</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">
            {mockNotifications.filter(n => !n.lida).length}
          </p>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card title="Últimas Anotações">
          <div className="space-y-3">
            {recentNotes.map(note => (
              <div key={note.id} className="flex items-start justify-between rounded-lg bg-gray-50 p-3">
                <div>
                  <p className="text-sm font-medium text-gray-900">{note.titulo}</p>
                  <p className="text-xs text-gray-500">{note.nomePaciente} &middot; {new Date(note.data).toLocaleDateString('pt-BR')}</p>
                </div>
              </div>
            ))}
          </div>
        </Card>

        <Card title="Próximos Plantões">
          <div className="space-y-3">
            {nextShifts.map(shift => (
              <div key={shift.id} className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
                <div>
                  <p className="text-sm font-medium text-gray-900">{shift.local}</p>
                  <p className="text-xs text-gray-500">{new Date(shift.data).toLocaleDateString('pt-BR')} &middot; {shift.horarioInicio}-{shift.horarioFim}</p>
                </div>
                <Badge variant={shift.tipoPlantao === 'Diurno' ? 'info' : 'warning'}>
                  {shift.tipoPlantao}
                </Badge>
              </div>
            ))}
          </div>
        </Card>
      </div>

      <Card title="Notificações">
        <div className="space-y-2">
          {mockNotifications.map(n => (
            <div key={n.id} className={`flex items-center gap-3 rounded-lg p-3 ${n.lida ? 'bg-gray-50' : 'bg-brand-50'}`}>
              <span className={`h-2 w-2 shrink-0 rounded-full ${n.lida ? 'bg-gray-300' : 'bg-brand-500'}`} />
              <p className="text-sm text-gray-700">{n.mensagem}</p>
              <time className="ml-auto shrink-0 text-xs text-gray-400">{new Date(n.data).toLocaleDateString('pt-BR')}</time>
            </div>
          ))}
        </div>
      </Card>
    </div>
  )
}
