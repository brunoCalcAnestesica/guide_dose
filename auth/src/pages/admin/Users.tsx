import { useState, useEffect, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { Card } from '../../components/ui/Card'
import { Table } from '../../components/ui/Table'
import type { Column } from '../../components/ui/Table'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { adminListUsers } from '../../lib/api'
import type { AdminUser } from '../../types'

const ITEMS_PER_PAGE = 15

// Código do país (locale) -> nome em português
const COUNTRY_NAMES: Record<string, string> = {
  BR: 'Brasil',
  US: 'Estados Unidos',
  GB: 'Reino Unido',
  PT: 'Portugal',
  ES: 'Espanha',
  AR: 'Argentina',
  MX: 'México',
  CO: 'Colômbia',
  CL: 'Chile',
  PE: 'Peru',
  FR: 'França',
  DE: 'Alemanha',
  IT: 'Itália',
  CA: 'Canadá',
  AU: 'Austrália',
  JP: 'Japão',
  CN: 'China',
  IN: 'Índia',
  RU: 'Rússia',
  ZA: 'África do Sul',
}

function countryDisplay(country: string | null | undefined): string {
  if (!country || !String(country).trim()) return '—'
  const code = String(country).trim().toUpperCase()
  return COUNTRY_NAMES[code] ?? code
}

export default function Users() {
  const navigate = useNavigate()
  const [users, setUsers] = useState<AdminUser[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [sortKey, setSortKey] = useState<string>('created_at')
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc')

  useEffect(() => {
    adminListUsers().then(({ data, error: err }) => {
      if (err) setError(err)
      else setUsers((data as AdminUser[]) ?? [])
      setLoading(false)
    })
  }, [])

  const filteredUsers = useMemo(() => {
    if (!search.trim()) return users
    const term = search.trim().toLowerCase()
    return users.filter(
      (u) =>
        (u.email ?? '').toLowerCase().includes(term) ||
        (u.id ?? '').toLowerCase().includes(term)
    )
  }, [users, search])

  const sortedUsers = useMemo(() => {
    const list = [...filteredUsers]
    list.sort((a, b) => {
      const aVal = a[sortKey as keyof AdminUser]
      const bVal = b[sortKey as keyof AdminUser]
      if (aVal == null && bVal == null) return 0
      if (aVal == null) return sortDir === 'asc' ? 1 : -1
      if (bVal == null) return sortDir === 'asc' ? -1 : 1
      let cmp = 0
      if (typeof aVal === 'string' && typeof bVal === 'string') {
        cmp = aVal.localeCompare(bVal, 'pt-BR')
      } else if (typeof aVal === 'number' && typeof bVal === 'number') {
        cmp = aVal - bVal
      } else if (aVal instanceof Date || (typeof aVal === 'string' && /^\d{4}-\d{2}-\d{2}/.test(String(aVal)))) {
        const tA = typeof aVal === 'string' ? new Date(aVal).getTime() : (aVal as Date).getTime()
        const tB = typeof bVal === 'string' ? new Date(bVal as string).getTime() : (bVal as Date).getTime()
        cmp = tA - tB
      } else {
        cmp = String(aVal).localeCompare(String(bVal), 'pt-BR')
      }
      return sortDir === 'asc' ? cmp : -cmp
    })
    return list
  }, [filteredUsers, sortKey, sortDir])

  const totalPages = Math.max(1, Math.ceil(sortedUsers.length / ITEMS_PER_PAGE))
  const currentPage = Math.min(page, totalPages)
  const paginatedUsers = useMemo(() => {
    const start = (currentPage - 1) * ITEMS_PER_PAGE
    return sortedUsers.slice(start, start + ITEMS_PER_PAGE)
  }, [sortedUsers, currentPage])

  useEffect(() => {
    setPage((p) => (p > totalPages ? totalPages : p))
  }, [totalPages])

  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'))
    } else {
      setSortKey(key)
      setSortDir('asc')
    }
    setPage(1)
  }

  if (loading) return <p className="text-sm text-gray-500">Carregando usuários...</p>
  if (error) return <p className="text-sm text-red-500">Erro: {error}</p>

  const columns: Column<AdminUser>[] = [
    { key: 'email', header: 'E-mail', sortable: true, render: (u: AdminUser) => (
      <div>
        <p className="font-medium text-gray-900">{u.email}</p>
        <p className="text-xs text-gray-500">ID: {u.id.slice(0, 8)}...</p>
      </div>
    )},
    { key: 'country', header: 'País', sortable: true, render: (u: AdminUser) => countryDisplay(u.country) },
    { key: 'created_at', header: 'Cadastro', sortable: true, render: (u: AdminUser) => u.created_at ? new Date(u.created_at).toLocaleDateString('pt-BR') : '—' },
    { key: 'last_sign_in_at', header: 'Último Login', sortable: true, render: (u: AdminUser) => u.last_sign_in_at ? new Date(u.last_sign_in_at).toLocaleDateString('pt-BR') : '—' },
    { key: 'email_confirmed_at', header: 'Status', sortable: true, render: (u: AdminUser) => (
      <Badge variant={u.email_confirmed_at ? 'success' : 'warning'}>
        {u.email_confirmed_at ? 'Confirmado' : 'Pendente'}
      </Badge>
    )},
    { key: 'access_count', header: 'Acessos', sortable: true, render: (u: AdminUser) => String(u.access_count ?? 0) },
    { key: 'acoes', header: 'Ações', render: (u: AdminUser) => (
      <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); navigate(`/admin/usuarios/${u.id}`) }}>
        Detalhes
      </Button>
    )},
  ]

  const startItem = (currentPage - 1) * ITEMS_PER_PAGE + 1
  const endItem = Math.min(currentPage * ITEMS_PER_PAGE, filteredUsers.length)

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Gerenciamento de Usuários</h1>
        <p className="text-sm text-gray-600">
          Total de cadastrados: <span className="font-semibold text-gray-900">{users.length}</span>
        </p>
      </div>

      <Card>
        <div className="space-y-4">
          <div className="relative">
            <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
              <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </span>
            <input
              type="search"
              placeholder="Pesquisar por e-mail ou ID..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1) }}
              className="w-full rounded-lg border border-gray-300 py-2 pl-10 pr-4 text-sm placeholder-gray-400 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              aria-label="Pesquisar usuários"
            />
            {search && (
              <button
                type="button"
                onClick={() => { setSearch(''); setPage(1) }}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                aria-label="Limpar pesquisa"
              >
                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            )}
          </div>

          <Table<AdminUser>
            columns={columns}
            data={paginatedUsers}
            onRowClick={(u) => navigate(`/admin/usuarios/${u.id}`)}
            emptyMessage={search ? 'Nenhum usuário encontrado para essa pesquisa.' : 'Nenhum usuário cadastrado.'}
            sortKey={sortKey}
            sortDirection={sortDir}
            onSort={handleSort}
          />

          {totalPages > 1 && (
            <div className="flex flex-col items-center justify-between gap-2 border-t border-gray-200 pt-4 sm:flex-row">
              <p className="text-sm text-gray-500">
                Exibindo {startItem}–{endItem} de {sortedUsers.length} usuário(s)
              </p>
              <div className="flex items-center gap-2">
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage <= 1}
                >
                  Anterior
                </Button>
                <span className="text-sm text-gray-600">
                  Página {currentPage} de {totalPages}
                </span>
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage >= totalPages}
                >
                  Próxima
                </Button>
              </div>
            </div>
          )}
        </div>
      </Card>
    </div>
  )
}
