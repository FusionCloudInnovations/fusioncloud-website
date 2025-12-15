# FusionCloud Innovations Website - Architecture

**Project:** Marketing Website
**Last Updated:** December 14, 2025

---

## System Overview

Static website architecture using Next.js static export deployed to AWS S3 + CloudFront, with serverless backend for contact form functionality.

```
┌─────────────────────────────────────────────────────────┐
│                    Route 53 (DNS)                       │
│          fusioncloudinnovations.com                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              CloudFront Distribution                     │
│  - Global CDN with edge locations                       │
│  - SSL/TLS certificate (ACM)                           │
│  - Custom domain with HTTPS                             │
│  - Cache optimization for static assets                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              S3 Bucket (Origin)                         │
│  - Static website hosting enabled                       │
│  - Next.js exported static files                        │
│  - Private bucket (CloudFront OAI access)              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│         Contact Form Backend (Serverless)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ API Gateway  │→ │    Lambda    │→ │  SES + S3    │ │
│  │   (REST)     │  │  (Node.js)   │  │  (Storage)   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend
- **Framework:** Next.js 15 (App Router)
- **Language:** TypeScript 5 (strict mode)
- **Styling:** Tailwind CSS 3.4 with custom brand theme
- **Animations:** Framer Motion 11
- **Forms:** React Hook Form + Zod validation
- **Build Output:** Static HTML/CSS/JS (no server runtime)

### Infrastructure (Terraform)
- **Hosting:** AWS S3 + CloudFront
- **DNS:** Route 53
- **SSL:** ACM (Certificate Manager)
- **Backend:** API Gateway + Lambda + SES
- **State:** Terraform S3 backend + DynamoDB locking

### CI/CD
- **Platform:** GitHub Actions
- **Deployment:** Automatic on merge to main/staging
- **Process:** Build → S3 Sync → CloudFront Invalidation

---

## Key Architectural Decisions

### 1. Static Export vs. SSR

**Decision:** Static export (`output: 'export'` in next.config.js)

**Rationale:**
- Marketing site with infrequent content changes
- Maximum performance and lowest cost
- No server required, pure static hosting
- Build-time rendering provides SEO benefits
- ~$2-5/month vs $15-50/month for server-based solutions

**Constraints:**
- No server-side runtime features (`getServerSideProps` not available)
- Images must use `unoptimized: true`
- API routes not available (use separate Lambda functions)
- All pages must be pre-rendered at build time

### 2. Hosting Infrastructure

**Decision:** S3 + CloudFront with Terraform IaC

**Rationale:**
- **Cost-Effective:** Pay only for storage and bandwidth
- **Scalable:** CloudFront handles traffic spikes automatically
- **Secure:** Private S3 bucket, CloudFront OAI access
- **Fast:** Global CDN with edge caching
- **IaC-Native:** 100% Terraform-managed, version controlled

**Components:**
- S3 bucket (private, static website hosting)
- CloudFront distribution (HTTPS, caching, compression)
- ACM certificate (SSL/TLS in us-east-1)
- Route 53 (DNS with A/AAAA alias records)

### 3. Contact Form Backend

**Decision:** API Gateway + Lambda + SES

**Rationale:**
- **Serverless:** No server management, pay-per-use
- **Cost-Effective:** Free tier covers typical usage
- **Scalable:** Automatic scaling
- **Maintainable:** Single Lambda function, simple code
- **Terraform-Ready:** Easy to define as IaC

**Flow:**
1. User submits form on website
2. Frontend validates with Zod schema
3. POST request to API Gateway endpoint
4. Lambda validates and processes
5. SES sends email to info@fusioncloudinnovations.com
6. S3 stores submission backup
7. Response returned to frontend

---

## Infrastructure Modules

### Terraform Module: static-website

**Purpose:** Deploy S3 bucket, CloudFront distribution, SSL certificate, and DNS

**Key Resources:**
1. **S3 Bucket**
   - Private bucket with website configuration
   - Versioning enabled
   - Lifecycle policies for old versions

2. **CloudFront Origin Access Identity (OAI)**
   - Secure access to S3 (no public bucket)

3. **CloudFront Distribution**
   - Origin: S3 via OAI
   - Viewer protocol: Redirect HTTP to HTTPS
   - Caching: Optimized for static sites
   - Compression: Gzip/Brotli enabled
   - Custom error responses (404 → 404.html)
   - Price class: 100 (NA/EU for cost savings)

4. **ACM Certificate**
   - SSL/TLS in us-east-1 (CloudFront requirement)
   - DNS validation

5. **Route 53 Records**
   - A record (IPv4) alias to CloudFront
   - AAAA record (IPv6) alias to CloudFront

**Inputs:**
- `domain_name` (string): fusioncloudinnovations.com
- `environment` (string): staging/production
- `price_class` (string): CloudFront price class

**Outputs:**
- `cloudfront_distribution_id` (string): For cache invalidation
- `s3_bucket_name` (string): For deployment
- `website_url` (string): Final website URL

### Terraform Module: contact-api

**Purpose:** Deploy Lambda function, API Gateway, and SES configuration

**Key Resources:**
1. **Lambda Function**
   - Runtime: Node.js 18
   - Handler: index.handler
   - Memory: 512 MB
   - Timeout: 30 seconds

2. **IAM Role**
   - SES send email permission
   - S3 put object permission
   - CloudWatch logs permission

3. **API Gateway REST API**
   - Resource: `/contact`
   - Method: POST
   - CORS: Configured for website domain
   - Throttling: 10 req/sec per IP

4. **SES Configuration**
   - Domain verification
   - DKIM records
   - Email sending enabled

5. **S3 Bucket**
   - Form submissions storage
   - Encryption at rest

**Inputs:**
- `api_name` (string): contact-api
- `environment` (string): staging/production
- `contact_email` (string): info@fusioncloudinnovations.com
- `allowed_origins` (list): Website domains for CORS

**Outputs:**
- `api_endpoint` (string): API Gateway invoke URL
- `lambda_function_name` (string): For monitoring

---

## Frontend Architecture

### Directory Structure

```
app/                          # Next.js App Router
├── layout.tsx               # Root layout with SEO metadata
├── page.tsx                 # Home page
├── globals.css              # Global styles
├── about/
│   └── page.tsx
├── services/
│   └── page.tsx
└── contact/
    └── page.tsx

components/                   # React components
├── layout/                  # Header, Footer, Navigation
├── ui/                      # Button, Card, Container, etc.
├── home/                    # Home page components
├── about/                   # About page components
├── services/                # Services page components
├── contact/                 # Contact form components
└── brand/                   # Brand elements (XP pillars, etc.)

lib/                          # Utilities
├── api.ts                   # API client for contact form
├── constants.ts             # App constants
└── utils.ts                 # Helper functions

hooks/                        # Custom React hooks
└── useContactForm.ts

types/                        # TypeScript definitions
└── index.ts
```

### Component Architecture

**Principles:**
- Atomic design: atoms (buttons) → molecules (cards) → organisms (sections)
- Server components by default (RSC)
- Client components only when needed ('use client' directive)
- Props validation with TypeScript
- Accessibility-first (WCAG 2.1 AA)

**Example Component:**
```tsx
// components/ui/Button.tsx
interface ButtonProps {
  variant: 'primary' | 'secondary'
  children: React.ReactNode
  onClick?: () => void
}

export function Button({ variant, children, onClick }: ButtonProps) {
  return (
    <button
      className={cn(
        'px-6 py-3 rounded font-semibold transition-colors',
        variant === 'primary' && 'bg-brand-cyan text-brand-black hover:bg-brand-cyan-light',
        variant === 'secondary' && 'border-2 border-brand-cyan text-brand-cyan hover:bg-brand-cyan/10'
      )}
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

---

## Data Flow

### Page Rendering (Build Time)

```
1. Developer runs: npm run build
2. Next.js processes all pages in app/
3. Static HTML generated for each route
4. CSS bundled and optimized
5. JS split into chunks
6. Output written to /out directory
7. Ready for deployment to S3
```

### Contact Form Submission (Runtime)

```
1. User fills form on website
2. React Hook Form validates locally (Zod schema)
3. If valid → POST to API Gateway endpoint
4. API Gateway invokes Lambda function
5. Lambda validates payload again
6. Lambda sends email via SES
7. Lambda stores submission in S3
8. Lambda returns success/error response
9. Frontend shows confirmation or error message
```

---

## Security Architecture

### Frontend Security
- **HTTPS Only:** CloudFront enforces HTTPS
- **CSP Headers:** Content Security Policy via CloudFront
- **XSS Prevention:** React automatic escaping
- **Dependency Scanning:** Dependabot enabled

### API Security
- **CORS:** Strict origin validation (only website domain)
- **Rate Limiting:** API Gateway throttling (10 req/sec)
- **Input Validation:** Server-side validation in Lambda
- **Bot Protection:** Optional reCAPTCHA v3

### Infrastructure Security
- **Private S3:** No public access, CloudFront OAI only
- **IAM Least Privilege:** Minimal permissions for each resource
- **State Encryption:** Terraform state encrypted in S3
- **Secrets Management:** AWS Secrets Manager for sensitive data
- **Monitoring:** CloudWatch logs and metrics

---

## Performance Optimization

### Build-Time Optimizations
- Code splitting (automatic with Next.js)
- Tree shaking (unused code removed)
- CSS purging (Tailwind removes unused classes)
- Asset minification (HTML, CSS, JS)

### Runtime Optimizations
- **CloudFront Caching:**
  - HTML: 1 hour TTL
  - Static assets: 1 year TTL (versioned URLs)
  - API: No caching

- **Compression:**
  - Gzip/Brotli enabled on CloudFront
  - Reduces transfer size by ~70%

- **Image Optimization:**
  - WebP format with fallbacks
  - Responsive images with srcset
  - Lazy loading below fold

### Monitoring
- CloudWatch metrics (requests, errors, latency)
- Real User Monitoring (Google Analytics)
- Lighthouse CI scores tracked

---

## Disaster Recovery

### Backup Strategy
- **Infrastructure:** Terraform state versioned in S3
- **Code:** Git repository (GitHub)
- **Form Submissions:** Stored in S3 with versioning
- **DNS:** Route 53 config exported regularly

### Rollback Procedures
1. **Code Rollback:** Revert Git commit, redeploy
2. **Infrastructure Rollback:** `terraform plan` previous version
3. **DNS Rollback:** Update Route 53 to previous CloudFront distribution
4. **Quick Fix:** Keep old S3 bucket for 1 week post-deployment

### High Availability
- **CloudFront:** Global edge locations, automatic failover
- **S3:** 99.999999999% durability, cross-AZ replication
- **Route 53:** 100% uptime SLA
- **Lambda:** Multi-AZ by default

---

## Monitoring & Observability

### Metrics to Track
- **Frontend:**
  - Page load time (Core Web Vitals)
  - Lighthouse scores
  - JavaScript errors

- **Backend:**
  - Lambda invocations
  - Lambda errors
  - Lambda duration
  - API Gateway latency

- **Infrastructure:**
  - CloudFront request count
  - CloudFront cache hit ratio
  - S3 bucket metrics
  - Cost by service

### Alerting
- Lambda error rate >5%
- API Gateway 5xx errors
- CloudFront origin errors
- Cost exceeds $50/month

---

## Related Documentation

- `IMPLEMENTATION_PLAN.md` - 5-week development plan
- `../README.md` - Quick start guide
- `../CLAUDE.md` - AI assistance guide
- Terraform modules: `../terraform/modules/`

---

*Architecture maintained by: Branden Miller*
*Last updated: December 14, 2025*
