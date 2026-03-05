import type { ReactNode } from 'react'

export interface Column<T> {
  key: string
  header: string
  render?: (item: T) => ReactNode
  sortable?: boolean
}

interface TableProps<T> {
  columns: Column<T>[]
  data: T[]
  onRowClick?: (item: T) => void
  emptyMessage?: string
  sortKey?: string
  sortDirection?: 'asc' | 'desc'
  onSort?: (key: string) => void
}

export function Table<T extends Record<string, unknown>>({
  columns,
  data,
  onRowClick,
  emptyMessage = 'Nenhum registro encontrado.',
  sortKey,
  sortDirection,
  onSort,
}: TableProps<T>) {
  if (data.length === 0) {
    return <p className="py-8 text-center text-sm text-gray-500">{emptyMessage}</p>
  }

  return (
    <div className="overflow-x-auto rounded-lg border border-gray-200">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {columns.map(col => (
              <th
                key={col.key}
                className={`px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500 ${col.sortable && onSort ? 'cursor-pointer select-none hover:bg-gray-100' : ''}`}
                onClick={() => col.sortable && onSort && onSort(col.key)}
              >
                <span className="inline-flex items-center gap-1">
                  {col.header}
                  {col.sortable && onSort && (
                    <span className="inline-flex flex-col text-gray-400">
                      <svg
                        className={`h-3 w-3 -mb-0.5 ${sortKey === col.key && sortDirection === 'asc' ? 'text-blue-600' : ''}`}
                        fill="currentColor"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                      >
                        <path d="M7 14l5-5 5 5H7z" />
                      </svg>
                      <svg
                        className={`h-3 w-3 -mt-0.5 ${sortKey === col.key && sortDirection === 'desc' ? 'text-blue-600' : ''}`}
                        fill="currentColor"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                      >
                        <path d="M7 10l5 5 5-5H7z" />
                      </svg>
                    </span>
                  )}
                </span>
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100 bg-white">
          {data.map((item, i) => (
            <tr
              key={i}
              className={onRowClick ? 'cursor-pointer hover:bg-gray-50' : ''}
              onClick={() => onRowClick?.(item)}
            >
              {columns.map(col => (
                <td key={col.key} className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                  {col.render ? col.render(item) : String(item[col.key] ?? '')}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
