import { Link } from 'react-router-dom'
import { useState } from 'react'

const featuresMain = [
  {
    title: 'Fisiologia',
    desc: 'Parâmetros antropométricos: peso ideal, IMC, superfície corporal, tubo orotraqueal e outros cálculos a partir do peso, altura e idade do paciente.',
    icon: '📐',
  },
  {
    title: 'Medicamentos e doses',
    desc: 'Listas personalizadas de medicamentos, doses e diluições por cenário. Ajuste por peso, idade e função renal quando necessário.',
    icon: '💊',
  },
  {
    title: 'Intubação',
    desc: 'Situações de intubação com doses e protocolos prontos. Favoritos e busca para acessar rápido no plantão.',
    icon: '🩺',
  },
  {
    title: 'PCR',
    desc: 'Protocolo de RCP com cronômetro, eventos e medicamentos (adrenalina, amiodarona, lidocaína, bicarbonato) em modo ACLS e PALS.',
    icon: '❤️‍🩹',
  },
]

const featuresExtra = [
  { title: 'Escala de plantões', desc: 'Calendário de plantões, histórico e relatórios. Sincronização com sua conta.' },
  { title: 'Notas e pacientes', desc: 'Anotações e lista de pacientes para organizar o plantão.' },
  { title: 'Divisor de plantão', desc: 'Ferramenta para passar o plantão de forma organizada.' },
  { title: 'IA médica', desc: 'Acesso a assistente com IA a partir do app.' },
]

const faqItems = [
  { q: 'A GuideDose é gratuita?', a: 'Sim. O aplicativo GuideDose é 100% gratuito, com todos os recursos disponíveis sem custo.' },
  { q: 'Quais funcionalidades o app tem?', a: 'O app oferece: parâmetros de fisiologia (peso ideal, IMC, SCorp etc.), medicamentos com doses e diluições, protocolos de intubação, PCR (ACLS/PALS) com cronômetro, escala de plantões, notas e pacientes, divisor de plantão e IA médica. Tudo usa os dados do paciente (peso, altura, idade, creatinina) que você informa uma vez.' },
  { q: 'Onde posso usar?', a: 'Em smartphones Android e iOS, e também em tablet ou navegador (área web para escala, notas e configurações).' },
  { q: 'Quem pode usar?', a: 'Médicos e acadêmicos de medicina.' },
  { q: 'Como entro em contato?', a: 'Por e-mail ou pela seção de contato/feedback no site e no app.' },
]

export default function Home() {
  const [openFaq, setOpenFaq] = useState<number | null>(null)

  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="relative overflow-hidden bg-gradient-to-br from-guide-700 via-guide-600 to-guide-800 text-white">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'0.03\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')] opacity-80" />
        <div className="relative mx-auto max-w-7xl px-4 py-16 sm:px-6 sm:py-24 lg:px-8 lg:py-28">
          <div className="mx-auto max-w-3xl text-center">
            <p className="text-sm font-semibold uppercase tracking-wider text-guide-200">Guide Dose ®</p>
            <h1 className="mt-4 text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl">
              Referência clínica no plantão
            </h1>
            <p className="mt-6 text-lg leading-relaxed text-guide-100">
              Fisiologia, medicamentos, intubação, PCR, escala de plantões e mais — com os dados do seu paciente em um só lugar.
            </p>
            <p className="mt-6 text-base font-medium text-white">100% gratuito</p>
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <a
                href="https://apps.apple.com/app/guidedose"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-xl bg-white px-6 py-3.5 text-sm font-semibold text-guide-800 shadow-lg transition hover:bg-guide-50"
              >
                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                App Store
              </a>
              <a
                href="https://play.google.com/store/apps/details?id=com.companyname.medcalc"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-xl bg-white px-6 py-3.5 text-sm font-semibold text-guide-800 shadow-lg transition hover:bg-guide-50"
              >
                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.61 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z" />
                </svg>
                Google Play
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* O que o app oferece */}
      <section className="bg-white py-16 sm:py-20 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="mx-auto max-w-3xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              O que tem no app
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              Você informa peso, altura, idade e creatinina do paciente uma vez; o GuideDose usa em todos os cálculos.
            </p>
          </div>
          <div className="mt-14 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
            {featuresMain.map((f) => (
              <div key={f.title} className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
                <span className="text-2xl" aria-hidden>{f.icon}</span>
                <h3 className="mt-4 text-lg font-semibold text-gray-900">{f.title}</h3>
                <p className="mt-2 text-sm text-gray-600">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Escala, notas, divisor, IA */}
      <section className="bg-guide-50 py-16 sm:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="mx-auto max-w-3xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Escala e organização do plantão
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              Calendário de plantões, anotações, lista de pacientes e ferramenta para passar o plantão. Ainda: IA médica integrada.
            </p>
          </div>
          <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {featuresExtra.map((f) => (
              <div key={f.title} className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-gray-900">{f.title}</h3>
                <p className="mt-2 text-sm text-gray-600">{f.desc}</p>
              </div>
            ))}
          </div>
          <div className="mt-10 text-center">
            <Link
              to="/login"
              className="inline-flex rounded-xl bg-guide-600 px-8 py-3.5 text-base font-semibold text-white shadow-lg transition hover:bg-guide-700"
            >
              Acessar área do usuário
            </Link>
          </div>
        </div>
      </section>

      {/* Gratuito */}
      <section className="bg-gradient-to-br from-guide-600 to-guide-800 py-16 sm:py-20">
        <div className="mx-auto max-w-3xl px-4 text-center sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
            Tudo gratuito
          </h2>
          <p className="mt-4 text-lg text-guide-100">
            Sem assinatura nem anúncios invasivos. Baixe o app ou use o site para escala e conta.
          </p>
          <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
            <a
              href="https://apps.apple.com/app/guidedose"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-xl bg-white px-8 py-3.5 text-base font-semibold text-guide-800 shadow-lg transition hover:bg-guide-50"
            >
              Baixar no App Store
            </a>
            <a
              href="https://play.google.com/store/apps/details?id=com.companyname.medcalc"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-xl bg-white px-8 py-3.5 text-base font-semibold text-guide-800 shadow-lg transition hover:bg-guide-50"
            >
              Baixar no Google Play
            </a>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="bg-gray-50 py-16 sm:py-20">
        <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
          <h2 className="text-center text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Perguntas frequentes
          </h2>
          <div className="mt-12 space-y-3">
            {faqItems.map((item, i) => (
              <div
                key={i}
                className="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm"
              >
                <button
                  type="button"
                  onClick={() => setOpenFaq(openFaq === i ? null : i)}
                  className="flex w-full items-center justify-between px-6 py-4 text-left font-medium text-gray-900 hover:bg-gray-50"
                >
                  {item.q}
                  <svg
                    className={`h-5 w-5 shrink-0 text-gray-500 transition ${openFaq === i ? 'rotate-180' : ''}`}
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>
                {openFaq === i && (
                  <div className="border-t border-gray-100 px-6 py-4 text-gray-600">
                    {item.a}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA final */}
      <section className="bg-guide-700 py-16 sm:py-20">
        <div className="mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
            Comece agora
          </h2>
          <p className="mt-4 text-xl text-guide-100">
            Baixe o app ou acesse sua conta no site. Sem custo.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <a
              href="https://apps.apple.com/app/guidedose"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-xl bg-white px-6 py-3.5 text-sm font-semibold text-guide-800 transition hover:bg-guide-50"
            >
              App Store
            </a>
            <a
              href="https://play.google.com/store/apps/details?id=com.companyname.medcalc"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-xl bg-white px-6 py-3.5 text-sm font-semibold text-guide-800 transition hover:bg-guide-50"
            >
              Google Play
            </a>
            <Link
              to="/login"
              className="inline-flex rounded-xl border-2 border-white px-6 py-3.5 text-sm font-semibold text-white transition hover:bg-white/10"
            >
              Acessar minha conta
            </Link>
          </div>
        </div>
      </section>
    </div>
  )
}
