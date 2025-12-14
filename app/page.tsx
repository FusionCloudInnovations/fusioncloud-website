export default function Home() {
  return (
    <main className="min-h-screen">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto text-center space-y-8">
          {/* Logo Placeholder */}
          <div className="mb-8">
            <h1 className="text-4xl md:text-6xl font-bold mb-4">
              FUSIONCLOUD
              <span className="block text-brand-cyan">INNOVATIONS</span>
            </h1>
          </div>

          {/* Coming Soon */}
          <div className="space-y-4">
            <h2 className="text-5xl md:text-7xl font-bold text-white">
              We Are
              <span className="block">Coming Soon</span>
            </h2>
          </div>

          {/* Tagline */}
          <div className="max-w-2xl mx-auto">
            <p className="text-xl md:text-2xl text-white/70">
              We're here to shift lives through design, technology, and experience with every frame, every feature, every flow.
            </p>
          </div>

          {/* visionXP */}
          <div className="pt-12 space-y-2">
            <p className="text-brand-cyan font-semibold tracking-wider uppercase text-sm">
              visionXP
            </p>
            <h3 className="text-2xl md:text-3xl font-bold text-white">
              Integrity. Impact. Innovation.
            </h3>
          </div>

          {/* Contact */}
          <div className="pt-8">
            <p className="text-white/50">
              Say hello!{' '}
              <a
                href="mailto:info@fusioncloudinnovations.com"
                className="text-brand-cyan hover:text-brand-cyan-light transition-colors"
              >
                info@fusioncloudinnovations.com
              </a>
            </p>
          </div>
        </div>
      </div>
    </main>
  )
}
