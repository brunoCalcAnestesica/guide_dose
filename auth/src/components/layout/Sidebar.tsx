import { NavLink } from 'react-router-dom'

interface NavItem {
  to: string
  label: string
  icon: string
}

interface SidebarProps {
  items: NavItem[]
  open: boolean
  onClose: () => void
}

export function Sidebar({ items, open, onClose }: SidebarProps) {
  return (
    <>
      {open && (
        <div className="fixed inset-0 z-30 bg-black/30 lg:hidden" onClick={onClose} />
      )}
      <aside
        className={`fixed inset-y-0 left-0 z-40 flex w-64 flex-col border-r border-gray-200 bg-white pt-16 transition-transform lg:static lg:translate-x-0 lg:pt-0 ${
          open ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex items-center gap-2 border-b border-gray-100 px-6 py-5">
          <img src="/logo.png" alt="GuideDose" className="h-8 w-8 rounded-lg" />
          <span className="text-lg font-bold text-brand-700">GuideDose</span>
        </div>
        <nav className="flex-1 space-y-1 overflow-y-auto px-3 py-4">
          {items.map(item => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/app' || item.to === '/admin'}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-brand-50 text-brand-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`
              }
            >
              <span className="text-lg">{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>
      </aside>
    </>
  )
}
