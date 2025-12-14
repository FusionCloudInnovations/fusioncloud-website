import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'FusionCloud Innovations - Integrity. Impact. Innovation.',
  description: "We're here to shift lives through design, technology, and experience with every frame, every feature, every flow.",
  keywords: ['Cloud Infrastructure', 'DevSecOps', 'Custom Software Development', 'AWS', 'Azure', 'Terraform', 'IaC'],
  authors: [{ name: 'FusionCloud Innovations' }],
  openGraph: {
    title: 'FusionCloud Innovations',
    description: "Shift lives through design, technology, and experience",
    url: 'https://www.fusioncloudinnovations.com',
    siteName: 'FusionCloud Innovations',
    locale: 'en_US',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="scroll-smooth">
      <body>
        {children}
      </body>
    </html>
  )
}
