import { useState, useEffect, useCallback } from 'react'
import { Card } from '../../components/ui/Card'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { adminQuery } from '../../lib/api'
import type { Feedback } from '../../types'

const statusColors: Record<Feedback['status'], 'warning' | 'info' | 'success'> = {
  pendente: 'warning',
  em_analise: 'info',
  resolvido: 'success',
}

const statusLabels: Record<Feedback['status'], string> = {
  pendente: 'Pendente',
  em_analise: 'Em Análise',
  resolvido: 'Resolvido',
}

export default function AdminFeedback() {
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([])
  const [loading, setLoading] = useState(true)

  const fetchFeedbacks = useCallback(async () => {
    setLoading(true)
    const { data } = await adminQuery<Feedback[]>('feedback', {
      order: 'created_at.desc',
      select: '*',
    })
    setFeedbacks(data ?? [])
    setLoading(false)
  }, [])

  useEffect(() => { fetchFeedbacks() }, [fetchFeedbacks])

  const changeStatus = async (id: string, status: Feedback['status']) => {
    const headers: Record<string, string> = { 'Content-Type': 'application/json' }
    const token = localStorage.getItem('gd_access_token')
    if (token) headers['Authorization'] = `Bearer ${token}`

    await fetch(`/.netlify/functions/api?table=feedback&id=eq.${id}`, {
      method: 'PATCH',
      headers,
      body: JSON.stringify({ status }),
    })

    setFeedbacks(prev => prev.map(f => f.id === id ? { ...f, status } : f))
  }

  if (loading) return <p className="text-sm text-gray-500">Carregando feedbacks...</p>

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Feedbacks dos Usuários</h1>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="border-l-4 border-l-yellow-400">
          <p className="text-sm text-gray-500">Pendentes</p>
          <p className="mt-1 text-3xl font-bold">{feedbacks.filter(f => f.status === 'pendente').length}</p>
        </Card>
        <Card className="border-l-4 border-l-blue-400">
          <p className="text-sm text-gray-500">Em Análise</p>
          <p className="mt-1 text-3xl font-bold">{feedbacks.filter(f => f.status === 'em_analise').length}</p>
        </Card>
        <Card className="border-l-4 border-l-green-400">
          <p className="text-sm text-gray-500">Resolvidos</p>
          <p className="mt-1 text-3xl font-bold">{feedbacks.filter(f => f.status === 'resolvido').length}</p>
        </Card>
      </div>

      {feedbacks.length === 0 ? (
        <Card>
          <p className="py-8 text-center text-sm text-gray-400">Nenhum feedback recebido ainda.</p>
        </Card>
      ) : (
        <div className="space-y-4">
          {feedbacks.map(fb => (
            <Card key={fb.id}>
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <Badge variant={fb.tipo === 'bug' ? 'danger' : fb.tipo === 'sugestao' ? 'info' : 'success'}>
                      {fb.tipo}
                    </Badge>
                    <Badge variant={statusColors[fb.status]}>{statusLabels[fb.status]}</Badge>
                  </div>
                  <p className="mt-2 text-sm text-gray-700">{fb.mensagem}</p>
                  <p className="mt-1 text-xs text-gray-400">{fb.user_email} &middot; {new Date(fb.created_at).toLocaleDateString('pt-BR')}</p>
                </div>
                <div className="flex gap-1">
                  {fb.status !== 'em_analise' && (
                    <Button size="sm" variant="secondary" onClick={() => changeStatus(fb.id, 'em_analise')}>Analisar</Button>
                  )}
                  {fb.status !== 'resolvido' && (
                    <Button size="sm" variant="secondary" onClick={() => changeStatus(fb.id, 'resolvido')}>Resolver</Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
