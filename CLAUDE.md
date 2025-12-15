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

---

## Implementation Progress

### Phase 1: Foundation (Week 1) - 75% Complete

**✅ Completed:**
- [x] Git repository initialized with proper `.gitignore`
- [x] Next.js 15 project set up with TypeScript and Tailwind CSS
- [x] Brand color palette implemented in `tailwind.config.ts`
- [x] Coming soon page created (`app/page.tsx`)
- [x] ClickUp project created with all 47 tasks across 6 phases
- [x] Comprehensive documentation:
  - `docs/IMPLEMENTATION_PLAN.md` - Complete 5-week plan
  - `docs/ARCHITECTURE.md` - Technical architecture details
  - `docs/README.md` - Documentation index
  - Obsidian notes in `02-FusionCloudX/` directory
- [x] Development server verified working (http://localhost:3000)
- [x] All dependencies installed (364 packages, 0 vulnerabilities)

**⏳ Remaining Phase 1 Tasks:**
- [ ] Set up Terraform directory structure (modules + environments)
- [ ] Configure Terraform remote state (S3 backend + DynamoDB locking)
- [ ] Create GitHub repository and push code
- [ ] Create CI/CD pipeline workflow skeletons (`.github/workflows/`)

**📋 Next Session Priorities:**
1. Complete Terraform directory structure and initial module files
2. Set up GitHub repository and push existing commits
3. Create CI/CD workflow skeletons for staging and production
4. Begin Phase 2: Logo design and typography selection

---

## Technical Learnings

### Architecture Decisions Made

**Static Export Configuration:**
- Using `output: 'export'` in `next.config.js` for S3 deployment
- Images set to `unoptimized: true` (required for static export)
- Estimated cost: $2-5/month vs $15-50/month for Amplify

**Git Conventions Established:**
- Format: `<gitmoji> <type>: <subject>`
- Example: `🎨 style: update button colors`
- Co-authored by Claude Sonnet 4.5
- Small, focused commits (best practices followed)

**Brand Color System:**
- Extracted from current website HTML/CSS
- Primary: `#00D4FF` (cyan), `#3B5A7E` (blue), `#D5081A` (red)
- Background: `#0A0A0A` (black)
- XP Pillar mapping: integrity=#3B5A7E, impact=#00D4FF, innovation=#D5081A

**7 XP Framework Pillars:**
1. Vision XP - Integrity, Impact, Innovation
2. Leadership XP - Distributed, Intentional, Aligned
3. Creative Flow - Design and development process
4. Payment XP - Fair compensation structure
5. Culture XP - Dope Work, Real Fun, True Impact
6. Boundaries XP - Work-life balance
7. Signature XP - Unique approach and delivery

### Performance Insights

**Development Server:**
- Startup time: 3.7 seconds
- Hot reload: Working correctly
- Build output: Static files to `/out` directory

**Dependencies:**
- Total packages: 364
- Vulnerabilities: 0
- Size: ~225KB package-lock.json

---

## Project Context

**Last Updated:** 2025-12-14

**Current Status:** Phase 1 (Foundation) - 75% Complete

**Next Session Focus:**
- Complete remaining Phase 1 infrastructure setup
- Prepare for Phase 2 (Brand Development & Infrastructure)

**Repository Location:** `F:\Clients\FusionCloudX\Repositories\fusioncloud-website`

**External Resources:**
- ClickUp: https://app.clickup.com/9014459252/v/l/li/901413761431
- Live Site: https://www.fusioncloudinnovations.com/
- Obsidian: `C:/Users/FusionCloudX/Obsidian/02-FusionCloudX/`
