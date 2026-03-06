import { useState, useEffect, useCallback, useMemo } from 'react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Modal } from '../../components/ui/Modal'
import { useAuth } from '../../auth/AuthProvider'
import { apiQuery, apiInsert, apiUpdate, apiDelete } from '../../lib/api'
import { expandRecurrenceRules } from '../../lib/recurrence'
import type { Shift, RecurrenceDefinition } from '../../types'

const WEEKDAY_LABELS = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
const MONTH_LABELS = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
]

function toIso(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

// Cores bem distintas por hospital; mesmo nome = mesma cor (índice estável por nome ordenado)
const HOSPITAL_PALETTE: { bar: string; bg: string }[] = [
  { bar: 'bg-blue-600', bg: 'bg-blue-50' },
  { bar: 'bg-emerald-600', bg: 'bg-emerald-50' },
  { bar: 'bg-amber-500', bg: 'bg-amber-50' },
  { bar: 'bg-rose-500', bg: 'bg-rose-50' },
  { bar: 'bg-violet-600', bg: 'bg-violet-50' },
  { bar: 'bg-cyan-600', bg: 'bg-cyan-50' },
  { bar: 'bg-orange-500', bg: 'bg-orange-50' },
  { bar: 'bg-teal-600', bg: 'bg-teal-50' },
  { bar: 'bg-fuchsia-500', bg: 'bg-fuchsia-50' },
  { bar: 'bg-indigo-600', bg: 'bg-indigo-50' },
]

function getHospitalKey(name: string | null): string {
  return (name || '').trim() || 'Sem local'
}

function useHospitalColors(shifts: Shift[]) {
  return useMemo(() => {
    const names = Array.from(new Set(shifts.map(s => getHospitalKey(s.hospital_name)))).sort()
    const map = new Map<string, { bar: string; bg: string }>()
    names.forEach((name, i) => {
      const pair = HOSPITAL_PALETTE[i % HOSPITAL_PALETTE.length]
      map.set(name, pair)
    })
    return { map, names }
  }, [shifts])
}

const emptyForm = {
  date: '',
  hospital_name: '',
  type: 'Diurno',
  start_time: '',
  end_time: '',
  value: '',
  informacoes: '',
  is_all_day: false,
}

export default function Schedule() {
  const { user } = useAuth()
  const [shifts, setShifts] = useState<Shift[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Shift | null>(null)
  const [form, setForm] = useState(emptyForm)
  const [saving, setSaving] = useState(false)
  const [showHospitalSuggestions, setShowHospitalSuggestions] = useState(false)

  const today = useMemo(() => new Date(), [])
  const [viewYear, setViewYear] = useState(today.getFullYear())
  const [viewMonth, setViewMonth] = useState(today.getMonth())
  const [selectedDate, setSelectedDate] = useState<string>(toIso(today))

  const fetchData = useCallback(async () => {
    if (!user) return
    setLoading(true)

    const [shiftsRes, rulesRes] = await Promise.all([
      apiQuery<Shift[]>('shifts', {
        user_id: `eq.${user.id}`,
        order: 'date.asc',
        select: '*',
        limit: '10000',
      }),
      apiQuery<RecurrenceDefinition[]>('recurrence_rules', {
        user_id: `eq.${user.id}`,
        select: '*',
      }),
    ])

    const standalone = shiftsRes.data ?? []
    const rules = rulesRes.data ?? []

    const rangeStart = new Date(viewYear, viewMonth - 2, 1)
    const rangeEnd = new Date(viewYear, viewMonth + 4, 0)
    const virtualShifts = expandRecurrenceRules(rules, rangeStart, rangeEnd)

    const virtualIds = new Set(virtualShifts.map(s => s.id))
    const filtered = standalone.filter(s => !virtualIds.has(s.id) && !s.recurrence_group_id)
    const merged = [...filtered, ...virtualShifts].sort((a, b) => a.date.localeCompare(b.date))

    setShifts(merged)
    setLoading(false)
  }, [user, viewYear, viewMonth])

  useEffect(() => { fetchData() }, [fetchData])

  const { map: hospitalColors, names: hospitalNames } = useHospitalColors(shifts)

  const hospitalSuggestions = useMemo(() => {
    const names = new Set<string>()
    for (const s of shifts) {
      if (s.hospital_name?.trim()) names.add(s.hospital_name.trim())
    }
    return Array.from(names).sort()
  }, [shifts])

  const filteredSuggestions = useMemo(() => {
    const q = form.hospital_name.toLowerCase().trim()
    if (!q) return hospitalSuggestions
    return hospitalSuggestions.filter(h => h.toLowerCase().includes(q))
  }, [form.hospital_name, hospitalSuggestions])

  const shiftsByDate = useMemo(() => {
    const map = new Map<string, Shift[]>()
    for (const s of shifts) {
      const list = map.get(s.date) || []
      list.push(s)
      map.set(s.date, list)
    }
    return map
  }, [shifts])

  function colorForHospital(name: string | null): { bar: string; bg: string } {
    const key = getHospitalKey(name)
    return hospitalColors.get(key) ?? HOSPITAL_PALETTE[0]
  }

  const calendarDays = useMemo(() => {
    const firstDay = new Date(viewYear, viewMonth, 1)
    const lastDay = new Date(viewYear, viewMonth + 1, 0)
    const startOffset = firstDay.getDay()
    const days: { date: Date; iso: string; isCurrentMonth: boolean }[] = []

    for (let i = startOffset - 1; i >= 0; i--) {
      const d = new Date(viewYear, viewMonth, -i)
      days.push({ date: d, iso: toIso(d), isCurrentMonth: false })
    }
    for (let d = 1; d <= lastDay.getDate(); d++) {
      const date = new Date(viewYear, viewMonth, d)
      days.push({ date, iso: toIso(date), isCurrentMonth: true })
    }
    const remaining = 7 - (days.length % 7)
    if (remaining < 7) {
      for (let i = 1; i <= remaining; i++) {
        const d = new Date(viewYear, viewMonth + 1, i)
        days.push({ date: d, iso: toIso(d), isCurrentMonth: false })
      }
    }
    return days
  }, [viewYear, viewMonth])

  const selectedShifts = useMemo(() => shiftsByDate.get(selectedDate) || [], [shiftsByDate, selectedDate])

  const prevMonth = () => {
    if (viewMonth === 0) { setViewYear(y => y - 1); setViewMonth(11) }
    else setViewMonth(m => m - 1)
  }
  const nextMonth = () => {
    if (viewMonth === 11) { setViewYear(y => y + 1); setViewMonth(0) }
    else setViewMonth(m => m + 1)
  }
  const goToday = () => {
    setViewYear(today.getFullYear())
    setViewMonth(today.getMonth())
    setSelectedDate(toIso(today))
  }

  const openNew = (date?: string) => {
    setEditing(null)
    setForm({ ...emptyForm, date: date || selectedDate })
    setModalOpen(true)
  }

  const openEdit = (shift: Shift) => {
    setEditing(shift)
    setForm({
      date: shift.date,
      hospital_name: shift.hospital_name || '',
      type: shift.type,
      start_time: shift.start_time,
      end_time: shift.end_time,
      value: shift.value?.toString() || '',
      informacoes: shift.informacoes || '',
      is_all_day: shift.is_all_day,
    })
    setModalOpen(true)
  }

  const handleSave = async () => {
    if (!user) return
    setSaving(true)

    const start = form.start_time || '00:00'
    const end = form.end_time || '00:00'
    const [sh, sm] = start.split(':').map(Number)
    const [eh, em] = end.split(':').map(Number)
    let dur = (eh * 60 + em) - (sh * 60 + sm)
    if (dur <= 0) dur += 1440

    const payload = {
      hospital_name: form.hospital_name || '',
      date: form.date,
      start_time: start,
      end_time: end,
      duration_hours: dur / 60,
      value: form.value ? parseFloat(form.value) : 0,
      type: form.type,
      informacoes: form.informacoes || null,
      is_all_day: form.is_all_day,
      updated_at: new Date().toISOString(),
    }

    if (editing) {
      await apiUpdate('shifts', { id: `eq.${editing.id}` }, payload)
    } else {
      const id = crypto.randomUUID()
      await apiInsert('shifts', {
        id,
        user_id: user.id,
        ...payload,
        is_completed: false,
        created_at: new Date().toISOString(),
      })
    }

    setSaving(false)
    setModalOpen(false)
    fetchData()
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Excluir este plantão?')) return
    await apiDelete('shifts', { id: `eq.${id}` })
    fetchData()
  }

  const exportCsv = () => {
    const header = 'Data,Local,Tipo,Inicio,Fim,Valor,Observacoes\n'
    const rows = shifts.map(s =>
      `${s.date},"${s.hospital_name || ''}",${s.type},${s.start_time},${s.end_time},${s.value},"${s.informacoes || ''}"`
    ).join('\n')
    const blob = new Blob([header + rows], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'escala.csv'
    a.click()
    URL.revokeObjectURL(url)
  }

  const todayIso = toIso(today)

  const monthTotal = useMemo(() => {
    let total = 0
    let count = 0
    for (const [date, dayShifts] of shiftsByDate) {
      const [y, m] = date.split('-').map(Number)
      if (y === viewYear && m === viewMonth + 1) {
        count += dayShifts.length
        total += dayShifts.reduce((sum, s) => sum + (s.value || 0), 0)
      }
    }
    return { count, total }
  }, [shiftsByDate, viewYear, viewMonth])

  if (loading) {
    return (
      <div className="flex min-h-[40vh] items-center justify-center">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-guide-200 border-t-guide-600" />
      </div>
    )
  }

  return (
    <div className="min-h-full bg-surface-variant">
      <div className="mx-auto max-w-6xl space-y-6 pb-8">
        {/* Header com identidade Guide Dose */}
        <div className="border-b border-outline bg-white px-4 py-5 shadow-sm sm:rounded-xl sm:border sm:px-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-guide-100">
                <img src="/logo.png" alt="Guide Dose" className="h-7 w-7 object-contain" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-semibold text-guide-600">GuideDose</span>
                  <span className="text-guide-300">·</span>
                  <h1 className="text-2xl font-bold tracking-tight text-guide-800">Escala de Plantões</h1>
                </div>
                <p className="mt-0.5 text-sm text-guide-600">Gerencie sua escala e acompanhe plantões do mês</p>
              </div>
            </div>
            <div className="flex flex-shrink-0 gap-2">
              <Button variant="secondary" onClick={exportCsv} className="border-outline text-guide-700 hover:bg-guide-50">Exportar CSV</Button>
              <Button onClick={() => openNew()} className="bg-guide-600 text-white hover:bg-guide-700 focus:ring-guide-500">+ Novo Plantão</Button>
            </div>
          </div>
        </div>

        {/* Resumo do mês — cards com paleta Guide Dose */}
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Card className="!border-l-4 !border-l-guide-500 !border-outline !p-5 !shadow">
            <p className="text-sm font-medium uppercase tracking-wide text-guide-600">Plantões no mês</p>
            <p className="mt-1 text-3xl font-bold text-guide-800">{monthTotal.count}</p>
          </Card>
          <Card className="!border-l-4 !border-l-guide-400 !border-outline !p-5 !shadow">
            <p className="text-sm font-medium uppercase tracking-wide text-guide-600">Total no mês</p>
            <p className="mt-1 text-3xl font-bold text-guide-600">R$ {monthTotal.total.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</p>
          </Card>
        </div>

        {/* Calendário */}
        <Card className="!border-outline !p-4 !shadow sm:!p-5">
          {/* Nav do mês */}
          <div className="mb-4 flex items-center justify-between border-b border-outline pb-3">
            <button onClick={prevMonth} className="rounded-lg p-2 text-guide-600 transition-colors hover:bg-guide-50" aria-label="Mês anterior">
              <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" /></svg>
            </button>
            <div className="text-center">
              <h2 className="text-lg font-semibold text-guide-800">{MONTH_LABELS[viewMonth]} {viewYear}</h2>
              <button onClick={goToday} className="text-xs font-medium text-guide-600 hover:text-guide-700 underline-offset-2 hover:underline">Ir para hoje</button>
            </div>
            <button onClick={nextMonth} className="rounded-lg p-2 text-guide-600 transition-colors hover:bg-guide-50" aria-label="Próximo mês">
              <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" /></svg>
            </button>
          </div>

          {/* Dias da semana */}
          <div className="grid grid-cols-7 gap-px mb-1">
            {WEEKDAY_LABELS.map(d => (
              <div key={d} className="py-2 text-center text-xs font-semibold uppercase tracking-wide text-guide-600">{d}</div>
            ))}
          </div>

          {/* Grid de dias */}
          <div className="grid grid-cols-7 gap-px overflow-hidden rounded-lg border border-outline bg-outline">
            {calendarDays.map(({ iso, date, isCurrentMonth }) => {
              const dayShifts = shiftsByDate.get(iso) || []
              const isToday = iso === todayIso
              const isSelected = iso === selectedDate
              const hasShifts = dayShifts.length > 0

              return (
                <button
                  key={iso}
                  onClick={() => setSelectedDate(iso)}
                  className={`relative flex min-h-[72px] flex-col p-1.5 text-left transition-colors
                    ${isCurrentMonth ? 'bg-white' : 'bg-surface-variant'}
                    ${isSelected ? 'z-10 ring-2 ring-guide-500 ring-inset' : ''}
                    hover:bg-guide-50
                  `}
                >
                  <span className={`inline-flex h-7 w-7 items-center justify-center rounded-full text-sm
                    ${isToday ? 'bg-guide-600 font-bold text-white' : ''}
                    ${!isToday && isCurrentMonth ? 'text-guide-800' : ''}
                    ${!isToday && !isCurrentMonth ? 'text-guide-400' : ''}
                  `}>
                    {date.getDate()}
                  </span>
                  {hasShifts && (
                    <div className="mt-auto flex flex-wrap gap-0.5">
                      {dayShifts.slice(0, 3).map((s, i) => (
                        <span
                          key={i}
                          className={`block h-1.5 flex-1 rounded-full ${colorForHospital(s.hospital_name).bar}`}
                          title={`${s.hospital_name || 'Sem local'} - ${s.type}`}
                        />
                      ))}
                      {dayShifts.length > 3 && (
                        <span className="text-[10px] font-medium text-guide-600 leading-none">+{dayShifts.length - 3}</span>
                      )}
                    </div>
                  )}
                </button>
              )
            })}
          </div>

          {/* Legenda: cor por hospital */}
          {hospitalNames.length > 0 && (
            <div className="mt-4 flex flex-wrap gap-4 rounded-lg bg-guide-50 px-3 py-2">
              {hospitalNames.map(name => {
                const { bar } = hospitalColors.get(name) ?? HOSPITAL_PALETTE[0]
                return (
                  <div key={name} className="flex items-center gap-2">
                    <span className={`block h-3 w-3 shrink-0 rounded-full ${bar}`} />
                    <span className="text-xs font-medium text-guide-700 truncate max-w-[140px]" title={name}>{name}</span>
                  </div>
                )
              })}
            </div>
          )}
        </Card>

        {/* Plantões do dia selecionado */}
        <Card className="!border-outline !p-4 !shadow sm:!p-5">
          <div className="mb-4 flex items-center justify-between border-b border-outline pb-3">
            <h3 className="font-semibold text-guide-800">
              {new Date(selectedDate + 'T12:00').toLocaleDateString('pt-BR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
            </h3>
            <Button size="sm" onClick={() => openNew(selectedDate)} className="bg-guide-600 text-white hover:bg-guide-700">+ Plantão</Button>
          </div>

          {selectedShifts.length === 0 ? (
            <div className="rounded-lg border border-dashed border-outline bg-surface-variant py-10 text-center">
              <p className="text-sm text-guide-600">Nenhum plantão neste dia</p>
              <Button size="sm" variant="secondary" onClick={() => openNew(selectedDate)} className="mt-2 border-outline text-guide-700">Adicionar plantão</Button>
            </div>
          ) : (
            <div className="space-y-3">
              {selectedShifts.map(s => {
                const { bar, bg } = colorForHospital(s.hospital_name)
                return (
                <div key={s.id} className={`flex items-center gap-3 rounded-lg border border-outline p-3 ${bg}`}>
                  <div className={`h-12 w-1 shrink-0 rounded-full ${bar}`} />
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-medium text-guide-800 truncate">{s.hospital_name || 'Sem local'}</span>
                      <span className="rounded-full border border-outline bg-white/80 px-2 py-0.5 text-xs font-medium text-guide-700">{s.type}</span>
                      {s.recurrence_group_id && <span className="rounded-full bg-guide-200 px-2 py-0.5 text-xs font-medium text-guide-700">Recorrente</span>}
                    </div>
                    <div className="mt-1 flex flex-wrap items-center gap-3 text-sm text-guide-600">
                      <span>{s.start_time} — {s.end_time}</span>
                      {s.value ? <span className="font-semibold text-guide-700">R$ {s.value.toFixed(2)}</span> : null}
                      {s.informacoes && <span className="truncate text-guide-500">{s.informacoes}</span>}
                    </div>
                  </div>
                  <div className="flex shrink-0 gap-1">
                    {!s.recurrence_group_id && (
                      <>
                        <Button size="sm" variant="ghost" onClick={() => openEdit(s)} className="text-guide-600 hover:bg-guide-100">Editar</Button>
                        <Button size="sm" variant="ghost" onClick={() => handleDelete(s.id)} className="text-guide-600 hover:bg-guide-100">Excluir</Button>
                      </>
                    )}
                  </div>
                </div>
                )
              })}
            </div>
          )}
        </Card>

      {/* Modal — formulário com paleta Guide Dose */}
      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Plantão' : 'Novo Plantão'}>
        <form onSubmit={e => { e.preventDefault(); handleSave() }} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-guide-700">Data</label>
              <input type="date" required value={form.date} onChange={e => setForm(p => ({ ...p, date: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-guide-700">Tipo</label>
              <select value={form.type} onChange={e => setForm(p => ({ ...p, type: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500">
                <option>Diurno</option>
                <option>Noturno</option>
                <option>12h</option>
                <option>24h</option>
                <option>Extra</option>
              </select>
            </div>
          </div>
          <div className="relative">
            <label className="block text-sm font-medium text-guide-700">Hospital</label>
            <input type="text" value={form.hospital_name}
              onChange={e => { setForm(p => ({ ...p, hospital_name: e.target.value })); setShowHospitalSuggestions(true) }}
              onFocus={() => setShowHospitalSuggestions(true)}
              onBlur={() => setTimeout(() => setShowHospitalSuggestions(false), 150)}
              placeholder="Nome do hospital"
              autoComplete="off"
              className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 placeholder:text-guide-400 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500" />
            {showHospitalSuggestions && filteredSuggestions.length > 0 && (
              <div className="absolute z-20 mt-1 max-h-40 w-full overflow-auto rounded-lg border border-outline bg-white shadow-lg">
                {filteredSuggestions.map(name => (
                  <button
                    key={name}
                    type="button"
                    onMouseDown={e => e.preventDefault()}
                    onClick={() => { setForm(p => ({ ...p, hospital_name: name })); setShowHospitalSuggestions(false) }}
                    className="flex w-full items-center gap-2 px-3 py-2 text-left text-sm text-guide-800 hover:bg-guide-50 transition-colors"
                  >
                    <span className={`block h-2.5 w-2.5 shrink-0 rounded-full ${hospitalColors.get(name)?.bar || 'bg-gray-400'}`} />
                    {name}
                  </button>
                ))}
              </div>
            )}
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-guide-700">Início</label>
              <input type="time" required value={form.start_time} onChange={e => setForm(p => ({ ...p, start_time: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500" />
            </div>
            <div>
              <label className="block text-sm font-medium text-guide-700">Fim</label>
              <input type="time" required value={form.end_time} onChange={e => setForm(p => ({ ...p, end_time: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-guide-700">Valor (R$)</label>
              <input type="number" step="0.01" value={form.value} onChange={e => setForm(p => ({ ...p, value: e.target.value }))}
                className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500" />
            </div>
            <div className="flex items-end">
              <label className="flex cursor-pointer items-center gap-2 pb-2">
                <input type="checkbox" checked={form.is_all_day} onChange={e => setForm(p => ({ ...p, is_all_day: e.target.checked }))}
                  className="h-4 w-4 rounded border-outline text-guide-600 focus:ring-guide-500" />
                <span className="text-sm text-guide-700">Dia inteiro</span>
              </label>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-guide-700">Informações</label>
            <input value={form.informacoes} onChange={e => setForm(p => ({ ...p, informacoes: e.target.value }))}
              placeholder="Observações"
              className="mt-1 block w-full rounded-lg border border-outline bg-white px-3 py-2 text-sm text-guide-800 placeholder:text-guide-400 focus:border-guide-500 focus:outline-none focus:ring-1 focus:ring-guide-500" />
          </div>
          <div className="flex justify-end gap-2 border-t border-outline pt-4">
            <Button type="button" variant="secondary" onClick={() => setModalOpen(false)} className="border-outline text-guide-700">Cancelar</Button>
            <Button type="submit" disabled={saving} className="bg-guide-600 text-white hover:bg-guide-700">{saving ? 'Salvando...' : editing ? 'Salvar' : 'Criar'}</Button>
          </div>
        </form>
      </Modal>
      </div>
    </div>
  )
}
