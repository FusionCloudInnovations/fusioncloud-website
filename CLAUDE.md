# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
npm run dev          # Start development server (http://localhost:3000)
npm run build        # Build for production (static export to /out)
npm run type-check   # Run TypeScript compiler without emitting files
npm run lint         # Run ESLint
```

## Architecture Overview

### Static Site Export for AWS S3

This is a **Next.js 15 static site** configured with `output: 'export'` in `next.config.js`. The build process generates static HTML/CSS/JS files in the `/out` directory for deployment to AWS S3 + CloudFront.

**Critical constraints:**
- No server-side runtime features (no `getServerSideProps`)
- Images must use `unoptimized: true` (already configured)
- API routes are not available (use separate Lambda functions instead)
- All pages must be pre-rendered at build time

### Brand Color System

The Tailwind configuration (`tailwind.config.ts`) contains the complete FusionCloud brand palette:

**Primary colors:**
- `brand-cyan` (#00D4FF) - Primary brand color, logo
- `brand-blue` (#3B5A7E) - Professional blue
- `brand-red` (#D5081A) - Accent/CTA color
- `brand-black` (#0A0A0A) - Background
- `brand-white` (#FFFFFF) - Text

**XP Pillar colors** (mapped to brand values):
- `integrity` - Professional blue (#3B5A7E)
- `impact` - Vibrant cyan (#00D4FF)
- `innovation` - Bold red (#D5081A)

**Gray scale:** `fusion-gray-{100,200,300,700,800}` for depth and hierarchy

### Planned Infrastructure (Not Yet Implemented)

The project will include:
- **terraform/** - IaC for S3, CloudFront, Route 53, ACM certificates
- **lambda/** - Contact form backend (API Gateway + Lambda + SES)
- **.github/workflows/** - CI/CD pipelines for staging and production

These directories exist but are empty. Do not generate infrastructure code without reviewing the implementation plan first.

## App Router Structure

Using Next.js 15 App Router:
- `app/layout.tsx` - Root layout with SEO metadata
- `app/page.tsx` - Home page (currently "Coming Soon")
- `app/globals.css` - Global styles with Tailwind directives
- Planned routes: `app/about/`, `app/services/`, `app/contact/`

## Important Constraints

1. **Static export only** - No dynamic rendering or server-side features
2. **Brand consistency** - Always use Tailwind brand colors, never hardcode hex values
3. **Git conventions** - Use conventional commits with gitmoji (e.g., `🎨 style: update button colors`)
4. **TypeScript strict mode** - All code must pass `npm run type-check`
5. **Mobile-first** - Responsive design is required, test all breakpoints

## Mission & Messaging

FusionCloud Innovations tagline: *"We're here to shift lives through design, technology, and experience with every frame, every feature, every flow."*

Core values (Vision XP): **Integrity. Impact. Innovation.**

Maintain this purpose-driven, anti-burnout culture messaging throughout the site.
