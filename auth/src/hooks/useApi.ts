import { useState, useEffect, useCallback } from 'react'
import { apiQuery, apiInsert, apiUpdate, apiDelete } from '../lib/api'

interface UseApiState<T> {
  data: T[]
  loading: boolean
  error: string | null
}

export function useApiQuery<T>(
  table: string,
  params?: Record<string, string>,
  deps: unknown[] = [],
) {
  const [state, setState] = useState<UseApiState<T>>({
    data: [],
    loading: true,
    error: null,
  })

  const refetch = useCallback(async () => {
    setState(prev => ({ ...prev, loading: true, error: null }))
    const { data, error } = await apiQuery<T[]>(table, params)
    setState({
      data: data ?? [],
      loading: false,
      error,
    })
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [table, JSON.stringify(params)])

  useEffect(() => {
    refetch()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [refetch, ...deps])

  return { ...state, refetch }
}

export function useApiMutation<T>(table: string) {
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const insert = async (body: Partial<T>): Promise<T | null> => {
    setSaving(true)
    setError(null)
    const result = await apiInsert<T[]>(table, body)
    setSaving(false)
    if (result.error) {
      setError(result.error)
      return null
    }
    const arr = result.data
    return Array.isArray(arr) && arr.length > 0 ? arr[0] : null
  }

  const update = async (
    filterParams: Record<string, string>,
    body: Partial<T>,
  ): Promise<T | null> => {
    setSaving(true)
    setError(null)
    const result = await apiUpdate<T[]>(table, filterParams, body)
    setSaving(false)
    if (result.error) {
      setError(result.error)
      return null
    }
    const arr = result.data
    return Array.isArray(arr) && arr.length > 0 ? arr[0] : null
  }

  const remove = async (filterParams: Record<string, string>): Promise<boolean> => {
    setSaving(true)
    setError(null)
    const result = await apiDelete(table, filterParams)
    setSaving(false)
    if (result.error) {
      setError(result.error)
      return false
    }
    return true
  }

  return { insert, update, remove, saving, error }
}
