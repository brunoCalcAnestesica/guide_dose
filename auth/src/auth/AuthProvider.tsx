import { createContext, useContext, useEffect, useState, useRef, useCallback, type ReactNode } from 'react'
import {
  apiLogin, apiSignup, apiLogout, apiResetPassword,
  apiGetUser, apiRefreshSession, getStoredToken, clearTokens,
  type AuthUser,
} from '../lib/api'

const ADMIN_EMAIL = 'bhdaroz@gmail.com'
const REFRESH_INTERVAL_MS = 10 * 60 * 1000

interface AuthState {
  user: AuthUser | null
  loading: boolean
  isAdmin: boolean
}

interface AuthContextType extends AuthState {
  token: string | null
  signIn: (email: string, password: string) => Promise<{ error: string | null }>
  signUp: (email: string, password: string) => Promise<{ error: string | null }>
  signOut: () => Promise<void>
  resetPassword: (email: string) => Promise<{ error: string | null }>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    loading: true,
    isAdmin: false,
  })
  const refreshTimer = useRef<ReturnType<typeof setInterval> | null>(null)

  const setUser = useCallback((user: AuthUser | null) => {
    setState({
      user,
      loading: false,
      isAdmin: user?.email?.toLowerCase() === ADMIN_EMAIL,
    })
  }, [])

  const startRefreshCycle = useCallback(() => {
    if (refreshTimer.current) clearInterval(refreshTimer.current)
    refreshTimer.current = setInterval(async () => {
      const result = await apiRefreshSession()
      if (result.error) {
        clearTokens()
        setUser(null)
      } else if (result.user) {
        setUser(result.user)
      }
    }, REFRESH_INTERVAL_MS)
  }, [setUser])

  useEffect(() => {
    const token = getStoredToken()
    if (!token) {
      setState(prev => ({ ...prev, loading: false }))
      return
    }

    apiGetUser().then(result => {
      if (result.error) {
        clearTokens()
        setUser(null)
      } else if (result.user) {
        setUser(result.user)
        startRefreshCycle()
      }
    })

    return () => {
      if (refreshTimer.current) clearInterval(refreshTimer.current)
    }
  }, [setUser, startRefreshCycle])

  const signIn = async (email: string, password: string) => {
    const result = await apiLogin(email, password)
    if (result.error) return { error: result.error }
    if (result.user) {
      setUser(result.user)
      startRefreshCycle()
    }
    return { error: null }
  }

  const signUp = async (email: string, password: string) => {
    const result = await apiSignup(email, password)
    return { error: result.error }
  }

  const signOut = async () => {
    if (refreshTimer.current) clearInterval(refreshTimer.current)
    await apiLogout()
    setUser(null)
  }

  const resetPassword = async (email: string) => {
    const result = await apiResetPassword(email, `${window.location.origin}/login`)
    return { error: result.error }
  }

  const token = getStoredToken()

  return (
    <AuthContext.Provider value={{ ...state, token, signIn, signUp, signOut, resetPassword }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth deve ser usado dentro de <AuthProvider>')
  return context
}
