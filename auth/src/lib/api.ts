const AUTH_URL = '/.netlify/functions/auth'
const API_URL = '/.netlify/functions/api'
const ADMIN_API_URL = '/.netlify/functions/admin-api'
const USERS_URL = '/.netlify/functions/users'
const PUSH_URL = '/.netlify/functions/push'

const TOKEN_KEY = 'gd_access_token'
const REFRESH_KEY = 'gd_refresh_token'

export function getStoredToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function getStoredRefreshToken(): string | null {
  return localStorage.getItem(REFRESH_KEY)
}

export function storeTokens(access: string, refresh: string) {
  localStorage.setItem(TOKEN_KEY, access)
  localStorage.setItem(REFRESH_KEY, refresh)
}

export function clearTokens() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(REFRESH_KEY)
}

function authHeaders(): Record<string, string> {
  const token = getStoredToken()
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (token) headers['Authorization'] = `Bearer ${token}`
  return headers
}

interface AuthSession {
  access_token: string
  refresh_token: string
  expires_in: number
  user: AuthUser
}

export interface AuthUser {
  id: string
  email?: string
  user_metadata?: Record<string, unknown>
  created_at?: string
}

interface AuthResult {
  error: string | null
  session?: AuthSession
  user?: AuthUser
  message?: string
}

export async function apiLogin(email: string, password: string): Promise<AuthResult> {
  try {
    const res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'login', email, password }),
    })
    const data = await res.json()
    if (!res.ok) return { error: data.error || 'Falha ao autenticar.' }
    storeTokens(data.access_token, data.refresh_token)
    return { error: null, session: data, user: data.user }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function apiSignup(email: string, password: string): Promise<AuthResult> {
  try {
    const res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'signup', email, password }),
    })
    const data = await res.json()
    if (!res.ok) {
      const msg = data?.error ?? data?.message ?? 'Falha ao criar conta.'
      return { error: typeof msg === 'string' ? msg : 'Falha ao criar conta.' }
    }
    return { error: null, user: data.user, message: data.message }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function apiLogout(): Promise<void> {
  try {
    await fetch(AUTH_URL, {
      method: 'POST',
      headers: authHeaders(),
      body: JSON.stringify({ action: 'logout' }),
    })
  } finally {
    clearTokens()
  }
}

export async function apiResetPassword(email: string, redirectTo: string): Promise<AuthResult> {
  try {
    const res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'reset', email, redirectTo }),
    })
    const data = await res.json()
    if (!res.ok) return { error: data.error || 'Falha ao enviar link.' }
    return { error: null, message: data.message }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function apiRefreshSession(): Promise<AuthResult> {
  const refresh = getStoredRefreshToken()
  if (!refresh) return { error: 'Sem refresh token.' }

  try {
    const res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'refresh', refresh_token: refresh }),
    })
    const data = await res.json()
    if (!res.ok) {
      clearTokens()
      return { error: data.error || 'Sessao expirada.' }
    }
    storeTokens(data.access_token, data.refresh_token)
    return { error: null, session: data, user: data.user }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function apiGetUser(): Promise<AuthResult> {
  const token = getStoredToken()
  if (!token) return { error: 'Nao autenticado.' }

  try {
    const res = await fetch(AUTH_URL, {
      method: 'GET',
      headers: { Authorization: `Bearer ${token}` },
    })
    const data = await res.json()
    if (!res.ok) {
      const refreshResult = await apiRefreshSession()
      if (refreshResult.error) {
        clearTokens()
        return { error: 'Sessao expirada.' }
      }
      return refreshResult
    }
    return { error: null, user: data.user }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function apiUpdatePassword(newPassword: string): Promise<AuthResult> {
  try {
    const res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: authHeaders(),
      body: JSON.stringify({ action: 'update_password', password: newPassword }),
    })
    const data = await res.json()
    if (!res.ok) return { error: data.error || 'Falha ao alterar senha.' }
    return { error: null, message: data.message }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function apiQuery<T = unknown>(
  table: string,
  params?: Record<string, string>,
): Promise<{ data: T | null; error: string | null }> {
  try {
    const qs = new URLSearchParams({ table, ...params }).toString()
    const res = await fetch(`${API_URL}?${qs}`, {
      method: 'GET',
      headers: authHeaders(),
    })
    const data = await res.json()
    if (!res.ok) return { data: null, error: data.error || 'Erro na consulta.' }
    return { data: data as T, error: null }
  } catch {
    return { data: null, error: 'Erro de conexao.' }
  }
}

export async function apiInsert<T = unknown>(
  table: string,
  body: unknown,
): Promise<{ data: T | null; error: string | null }> {
  try {
    const res = await fetch(`${API_URL}?table=${table}`, {
      method: 'POST',
      headers: authHeaders(),
      body: JSON.stringify(body),
    })
    const data = await res.json()
    if (!res.ok) return { data: null, error: data.error || 'Erro ao inserir.' }
    return { data: data as T, error: null }
  } catch {
    return { data: null, error: 'Erro de conexao.' }
  }
}

export async function apiUpdate<T = unknown>(
  table: string,
  params: Record<string, string>,
  body: unknown,
): Promise<{ data: T | null; error: string | null }> {
  try {
    const qs = new URLSearchParams({ table, ...params }).toString()
    const res = await fetch(`${API_URL}?${qs}`, {
      method: 'PATCH',
      headers: authHeaders(),
      body: JSON.stringify(body),
    })
    const data = await res.json()
    if (!res.ok) return { data: null, error: data.error || 'Erro ao atualizar.' }
    return { data: data as T, error: null }
  } catch {
    return { data: null, error: 'Erro de conexao.' }
  }
}

export async function apiDelete(
  table: string,
  params: Record<string, string>,
): Promise<{ error: string | null }> {
  try {
    const qs = new URLSearchParams({ table, ...params }).toString()
    const res = await fetch(`${API_URL}?${qs}`, {
      method: 'DELETE',
      headers: authHeaders(),
    })
    if (!res.ok) {
      const data = await res.json()
      return { error: data.error || 'Erro ao deletar.' }
    }
    return { error: null }
  } catch {
    return { error: 'Erro de conexao.' }
  }
}

export async function adminQuery<T = unknown>(
  table: string,
  params?: Record<string, string>,
): Promise<{ data: T | null; error: string | null }> {
  try {
    const qs = new URLSearchParams({ table, ...params }).toString()
    const res = await fetch(`${ADMIN_API_URL}?${qs}`, {
      method: 'GET',
      headers: authHeaders(),
    })
    const data = await res.json()
    if (!res.ok) return { data: null, error: data.error || 'Erro na consulta admin.' }
    return { data: data as T, error: null }
  } catch {
    return { data: null, error: 'Erro de conexao.' }
  }
}

export async function adminListUsers(): Promise<{ data: unknown[] | null; error: string | null }> {
  try {
    const res = await fetch(USERS_URL, {
      method: 'GET',
      headers: authHeaders(),
    })
    const data = await res.json()
    if (!res.ok) return { data: null, error: data.error || 'Erro ao listar usuarios.' }
    return { data: data.users || [], error: null }
  } catch {
    return { data: null, error: 'Erro de conexao.' }
  }
}

export async function apiSendPush(
  payload: { target: string | string[]; title: string; body: string; link?: string; source?: string },
): Promise<{ data: { sent?: number; total_tokens?: number } | null; error: string | null }> {
  try {
    const res = await fetch(PUSH_URL, {
      method: 'POST',
      headers: authHeaders(),
      body: JSON.stringify(payload),
    })
    const data = await res.json()
    if (!res.ok) return { data: null, error: data.error || 'Erro ao enviar push.' }
    return { data, error: null }
  } catch {
    return { data: null, error: 'Erro de conexao.' }
  }
}
