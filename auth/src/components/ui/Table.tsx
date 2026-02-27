import type { ReactNode } from 'react'

interface Column<T> {
  key: string
  header: string
  render?: (item: T) => ReactNode
}

interface TableProps<T> {
  columns: Column<T>[]
  data: T[]
  onRowClick?: (item: T) => void
  emptyMessage?: string
}

export function Table<T extends Record<string, unknown>>({
  columns,
  data,
  onRowClick,
  emptyMessage = 'Nenhum registro encontrado.',
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
              <th key={col.key} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                {col.header}
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
