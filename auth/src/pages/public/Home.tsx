import { Link } from 'react-router-dom'
import { mockNews } from '../../mocks/data'

export default function Home() {
  return (
    <div>
      {/* Hero */}
      <section className="bg-gradient-to-br from-brand-700 via-brand-600 to-brand-800 text-white">
        <div className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
          <div className="mx-auto max-w-3xl text-center">
            <h1 className="text-4xl font-extrabold tracking-tight sm:text-5xl">
              GuideDose
            </h1>
            <p className="mt-4 text-lg text-brand-100">
              O aplicativo de referência clínica para profissionais de saúde.
              Cálculos, protocolos, farmacoteca e muito mais — direto no seu bolso.
            </p>
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <a
                href="https://apps.apple.com/app/guidedose"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-xl bg-black px-6 py-3 text-sm font-semibold text-white transition hover:bg-gray-800"
              >
                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                </svg>
                App Store
              </a>
              <a
                href="https://play.google.com/store/apps/details?id=com.companyname.medcalc"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-xl bg-black px-6 py-3 text-sm font-semibold text-white transition hover:bg-gray-800"
              >
                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.61 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                </svg>
                Google Play
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Sobre */}
      <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold text-gray-900">Sobre o GuideDose</h2>
          <p className="mt-4 text-gray-600 leading-relaxed">
            O GuideDose é uma ferramenta clínica desenvolvida por médicos, para médicos.
            Oferece cálculos de doses, diluições, scores de gravidade, protocolos atualizados
            e uma farmacoteca completa — tudo validado por evidências científicas e pronto
            para uso no dia a dia do plantão.
          </p>
        </div>
        <div className="mt-12 grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
          {[
            { title: 'Cálculos Rápidos', desc: 'Doses, diluições e ajustes renais calculados em segundos.', icon: '🧮' },
            { title: 'Farmacoteca Completa', desc: 'Mais de 200 medicamentos com informações detalhadas.', icon: '💊' },
            { title: 'Protocolos Atualizados', desc: 'Sepse, PCR, IAM e outros protocolos de emergência.', icon: '📋' },
          ].map(feat => (
            <div key={feat.title} className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
              <span className="text-3xl">{feat.icon}</span>
              <h3 className="mt-3 text-lg font-semibold text-gray-900">{feat.title}</h3>
              <p className="mt-2 text-sm text-gray-600">{feat.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Notícias */}
      <section className="bg-white">
        <div className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-gray-900">Novidades</h2>
          <div className="mt-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {mockNews.map(news => (
              <article key={news.id} className="rounded-xl border border-gray-200 p-6 transition hover:shadow-md">
                <time className="text-xs font-medium text-brand-600">{new Date(news.data).toLocaleDateString('pt-BR')}</time>
                <h3 className="mt-2 text-lg font-semibold text-gray-900">{news.titulo}</h3>
                <p className="mt-2 text-sm text-gray-600">{news.resumo}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="bg-brand-50">
        <div className="mx-auto max-w-7xl px-4 py-16 text-center sm:px-6 lg:px-8">
          <h2 className="text-2xl font-bold text-gray-900">Pronto para começar?</h2>
          <p className="mt-2 text-gray-600">Acesse sua área de usuário ou baixe o app no seu celular.</p>
          <div className="mt-6 flex flex-wrap items-center justify-center gap-4">
            <Link to="/login" className="rounded-lg bg-brand-600 px-6 py-3 text-sm font-semibold text-white hover:bg-brand-700">
              Acessar minha conta
            </Link>
            <Link to="/login" className="rounded-lg border border-gray-300 bg-white px-6 py-3 text-sm font-semibold text-gray-700 hover:bg-gray-50">
              Criar conta
            </Link>
          </div>
        </div>
      </section>
    </div>
  )
}
