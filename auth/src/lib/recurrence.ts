import type { RecurrenceRuleData, RecurrenceDefinition, Shift } from '../types'

const MAX_OCCURRENCES = 999
const MAX_DAYS_AHEAD = 730

function sameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
}

function addDays(d: Date, n: number): Date {
  const r = new Date(d)
  r.setDate(r.getDate() + n)
  return r
}

function toIso(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function parseLocalDate(s: string): Date {
  const [y, m, d] = s.split('-').map(Number)
  return new Date(y, m - 1, d)
}

function getNthWeekdayOfMonth(year: number, month: number, weekday: number, n: number): Date | null {
  if (n === -1) {
    const lastDay = new Date(year, month, 0)
    let current = new Date(lastDay)
    while (current.getMonth() === month - 1) {
      if (current.getDay() === weekday % 7) return current
      current = addDays(current, -1)
    }
    return null
  }
  let count = 0
  for (let d = 1; d <= 31; d++) {
    const date = new Date(year, month - 1, d)
    if (date.getMonth() !== month - 1) break
    if (date.getDay() === weekday % 7) {
      count++
      if (count === n) return date
    }
  }
  return null
}

function generateOccurrences(rule: RecurrenceRuleData, startDate: Date, maxDateOverride?: Date): Date[] {
  if (rule.type === 'none') return [startDate]

  const dates: Date[] = []
  const ruleMax = rule.endType === 'date' && rule.endDate
    ? parseLocalDate(rule.endDate)
    : addDays(startDate, MAX_DAYS_AHEAD)
  const maxDate = maxDateOverride && maxDateOverride < ruleMax ? maxDateOverride : ruleMax
  const maxCount = rule.endType === 'count' && rule.endCount ? rule.endCount : MAX_OCCURRENCES
  const interval = rule.interval || 1

  switch (rule.type) {
    case 'daily': {
      let current = new Date(startDate)
      while (current <= maxDate && dates.length < maxCount) {
        dates.push(new Date(current))
        current = addDays(current, interval)
      }
      break
    }
    case 'weekly': {
      const wd = startDate.getDay()
      let current = new Date(startDate)
      while (current <= maxDate && dates.length < maxCount) {
        if (current.getDay() === wd) {
          dates.push(new Date(current))
        }
        current = addDays(current, 7 * interval)
      }
      break
    }
    case 'monthly': {
      let current = new Date(startDate)
      while (current <= maxDate && dates.length < maxCount) {
        dates.push(new Date(current))
        current = new Date(current.getFullYear(), current.getMonth() + interval, current.getDate())
      }
      break
    }
    case 'monthlyWeekday': {
      if (rule.weekOfMonth == null || !rule.daysOfWeek?.length) {
        dates.push(startDate)
        break
      }
      const targetWeekday = rule.daysOfWeek[0]
      let cYear = startDate.getFullYear()
      let cMonth = startDate.getMonth() + 1
      while (dates.length < maxCount) {
        const date = getNthWeekdayOfMonth(cYear, cMonth, targetWeekday, rule.weekOfMonth)
        if (date) {
          if (date >= startDate && date <= maxDate) dates.push(date)
          if (date > maxDate) break
        }
        cMonth += interval
        if (cMonth > 12) {
          cYear += Math.floor(cMonth / 12)
          cMonth = cMonth % 12
          if (cMonth === 0) { cMonth = 12; cYear-- }
        }
      }
      break
    }
    case 'yearly': {
      let current = new Date(startDate)
      while (current <= maxDate && dates.length < maxCount) {
        dates.push(new Date(current))
        current = new Date(current.getFullYear() + interval, current.getMonth(), current.getDate())
      }
      break
    }
    case 'weekdays': {
      let current = new Date(startDate)
      while (current <= maxDate && dates.length < maxCount) {
        const dow = current.getDay()
        if (dow >= 1 && dow <= 5) dates.push(new Date(current))
        current = addDays(current, 1)
      }
      break
    }
    case 'custom': {
      if (rule.daysOfWeek?.length) {
        let weekStart = new Date(startDate)
        while ((weekStart <= maxDate) && dates.length < maxCount) {
          const mondayOffset = (weekStart.getDay() + 6) % 7
          const monday = addDays(weekStart, -mondayOffset)
          for (const day of rule.daysOfWeek) {
            const date = addDays(monday, day - 1)
            if (date >= startDate && date <= maxDate) {
              if (!dates.some(d => sameDay(d, date))) {
                dates.push(date)
                if (dates.length >= maxCount) break
              }
            }
          }
          weekStart = addDays(weekStart, 7 * interval)
        }
      } else {
        let current = new Date(startDate)
        while (current <= maxDate && dates.length < maxCount) {
          dates.push(new Date(current))
          current = addDays(current, interval)
        }
      }
      break
    }
    default:
      dates.push(startDate)
  }

  return dates
}

function generateInRange(rule: RecurrenceRuleData, startDate: Date, rangeStart: Date, rangeEnd: Date): Date[] {
  const all = generateOccurrences(rule, startDate, rangeEnd)
  return all.filter(d => (d >= rangeStart || sameDay(d, rangeStart)) && (d <= rangeEnd || sameDay(d, rangeEnd)))
}

export function expandRecurrenceRules(
  rules: RecurrenceDefinition[],
  rangeStart: Date,
  rangeEnd: Date,
): Shift[] {
  const shifts: Shift[] = []

  for (const def of rules) {
    const startDate = parseLocalDate(def.start_date)
    const effectiveEnd = def.end_date ? parseLocalDate(def.end_date) : null
    const rEnd = effectiveEnd && effectiveEnd < rangeEnd ? effectiveEnd : rangeEnd

    if (startDate > rEnd) continue

    const allDates = generateInRange(def.recurrence_rule, startDate, rangeStart, rEnd)
    const excludedSet = new Set(def.excluded_dates || [])
    const paidSet = new Set(def.paid_dates || [])
    const dates = allDates.filter(d => !excludedSet.has(toIso(d)))

    for (const date of dates) {
      const iso = toIso(date)
      shifts.push({
        id: `${def.id}_${iso}`,
        user_id: def.user_id,
        hospital_name: def.hospital_name,
        date: iso,
        start_time: def.start_time,
        end_time: def.end_time,
        duration_hours: def.duration_hours,
        value: def.value,
        type: def.type,
        informacoes: def.informations,
        is_all_day: def.is_all_day,
        is_completed: paidSet.has(iso),
        recurrence_group_id: def.id,
        recurrence_rule: def.recurrence_rule,
        created_at: def.created_at,
        updated_at: def.updated_at,
      })
    }
  }

  shifts.sort((a, b) => {
    const dc = a.date.localeCompare(b.date)
    return dc !== 0 ? dc : a.start_time.localeCompare(b.start_time)
  })

  return shifts
}
