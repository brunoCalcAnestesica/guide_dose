// Supabase Edge Function para fazer proxy da API OpenAI
// Salve este arquivo em: supabase/functions/openai-proxy/index.ts
// 
// Para fazer deploy:
// 1. Instale o Supabase CLI: npm install -g supabase
// 2. Faça login: supabase login
// 3. Link seu projeto: supabase link --project-ref SEU_PROJECT_REF
// 4. Configure a chave: supabase secrets set OPENAI_API_KEY=sk-...
// 5. Deploy: supabase functions deploy openai-proxy

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  try {
    const body = await req.json()
    const { messages, model, temperature, max_tokens, stream } = body

    if (!OPENAI_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'OpenAI API key not configured' }),
        {
          status: 500,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' }
        }
      )
    }

    const isStream = stream === true
    const payload = {
      model: model || 'gpt-4',
      messages: messages || [],
      temperature: temperature ?? 0.7,
      max_tokens: max_tokens || 4096,
      ...(isStream ? { stream: true } : {}),
    }

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify(payload),
    })

    if (isStream) {
      if (!response.ok) {
        const err = await response.json().catch(() => ({}))
        return new Response(
          JSON.stringify({ error: err.error?.message || 'OpenAI API error' }),
          {
            status: response.status,
            headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' }
          }
        )
      }
      return new Response(response.body, {
        status: response.status,
        headers: {
          ...CORS_HEADERS,
          'Content-Type': response.headers.get('Content-Type') || 'text/event-stream',
        },
      })
    }

    const data = await response.json()

    if (!response.ok) {
      return new Response(
        JSON.stringify({ error: data.error?.message || 'OpenAI API error' }),
        {
          status: response.status,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' }
        }
      )
    }

    return new Response(
      JSON.stringify(data),
      {
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' }
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } 
      }
    )
  }
})
