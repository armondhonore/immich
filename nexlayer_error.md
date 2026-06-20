# Nexlayer Build Failure Report

**Pipeline:** 19ee7000481
**Repository:** https://github.com/armondhonore/immich
**Error category:** deploy_platform
**Error summary:** app URL https://relaxed-weasel-immich.cloud.nexlayer.ai did not resolve after deployment (HTTP 503) — the app may have crashed on missing/invalid env config, or DNS/routing was not provisioned

## Build log
```

```

## Repository build artifacts

These are the actual files from the repository. Use these to understand how the project
is SUPPOSED to be built — do not rely solely on the broken Dockerfile below.


### package.json
```
{
  "name": "immich-monorepo",
  "version": "3.0.0-rc.2",
  "description": "Monorepo for Immich",
  "type": "module",
  "private": true,
  "scripts": {
    "format": "prettier --cache --check i18n/",
    "format:fix": "prettier --cache --write --list-different i18n",
    "test": "vitest",
    "release": "./misc/release/pump-version.sh",
    "pump": "node ./misc/release/pump-wrapper.js"
  },
  "packageManager": "pnpm@11.6.0",
  "engines": {
    "pnpm": ">=10.0.0"
  },
  "devDependencies": {
    "@types/node": "^24.13.2",
    "prettier": "^3.8.3",
    "prettier-plugin-sort-json": "^4.2.0",
    "semver": "^7.8.1",
    "vitest": "^4.1.8"
  }
}

```

### pnpm-workspace.yaml
```
packages:
  - packages/**
  - docs
  - e2e
  - i18n
  - server
  - plugins
  - web
  - .github
  - packages/*
allowBuilds:
  '@nestjs/core': false
  '@parcel/watcher': false
  '@scarf/scarf': false
  '@swc/core': false
  bcrypt: true
  canvas: false
  core-js: false
  cpu-features: false
  es5-ext: false
  esbuild: false
  msgpackr-extract: false
  protobufjs: false
  sharp: true
  ssh2: false
  utimes: false
  '@tailwindcss/oxide': true
  core-js-pure: false
  postman-code-generators: false
overrides:
  canvas: 3.2.3
  sharp: ^0.34.5
packageExtensions:
  nestjs-kysely:
    dependencies:
      tslib: '*'
  nestjs-otel:
    dependencies:
      tslib: '*'
  '@photo-sphere-viewer/equirectangular-video-adapter':
    dependencies:
      three: '*'
  '@photo-sphere-viewer/video-plugin':
    dependencies:
      three: '*'
  sharp:
    dependencies:
      node-addon-api: '*'
      node-gyp: '*'
  '@immich/ui':
    dependencies:
      tailwindcss: '>=4.1'
  tailwind-variants:
    dependencies:
      tailwindcss: '>=4.1'
  bcrypt:
    dependencies:
      node-addon-api: '*'
      node-gyp: '*'
  '@nestjs/swagger':
    peerDependencies:
      typescript: '*'
dedupePeerDependents: false
preferWorkspacePackages: true
injectWorkspacePackages: true
shamefullyHoist: false
verifyDepsBeforeRun: install
minimumReleaseAgeExclude:
  - '@immich/ui@0.81.1'

```

### .nvmrc
```
24.15.0

```


## Last attempted Dockerfile
```dockerfile
FROM mirror.gcr.io/library/node:22-slim

# Install build dependencies for native modules (bcrypt, sharp)
# 'linux-headers' is an alpine package; for debian-slim we use 'linux-libc-dev'
RUN apt-get update && apt-get install -y python3 make g++ linux-libc-dev && rm -rf /var/lib/apt/lists/*

# Use corepack to install the exact pnpm version specified in packageManager
RUN npm install -g corepack@latest && corepack enable && corepack prepare pnpm@11.6.0 --activate

WORKDIR /repo

# Copy the entire monorepo to handle symlinks and workspace dependencies in a single stage
COPY . .

# Install dependencies skipping frozen lockfile and ignoring scripts to avoid husky/prepare failures
RUN pnpm install --no-frozen-lockfile --ignore-scripts

# The target app is packages/e2e-auth-server
WORKDIR /repo/packages/e2e-auth-server

# Critical runtime configuration
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

EXPOSE 3000

# Run with npx tsx to ensure the binary is available from the root node_modules
CMD ["npx", "tsx", "startup.ts"]
```

## Last attempted nexlayer.yaml
```yaml

```

## Instructions for frontier model

CRITICAL: Before writing any fix, read the repository build artifacts above and answer:
1. What language/runtime does this project use? (go.mod, package.json, pom.xml, Cargo.toml, requirements.txt)
2. What is the actual build command? (package.json scripts.build, Makefile targets, pom.xml goals, gradle tasks)
3. What is the actual start command? (package.json scripts.start, Makefile run target, Procfile)
4. What port does it serve? (EXPOSE, ENV PORT=, --port flag, framework default)
5. What dependencies does it need at runtime? (docker-compose.yml services, .env.example vars)

Then create a correct Dockerfile from scratch based on your analysis:
- All FROM base images must be standard public images (library/, gcr.io, ghcr.io, etc.)
- Use `mirror.gcr.io/library/` prefix for Docker Hub official images (node:*, python:*, golang:*, etc.)
- DO NOT copy broken steps from the "last attempted Dockerfile" — build from what the repo actually needs

Fix nexlayer.yaml if needed:
- Inter-pod service references MUST use `<podName>.pod:<port>` addressing (resolved by the platform via DNS at deploy time)
- Example: `DATABASE_URL: postgresql://user:pass@postgres.pod:5432/db`

Create a file named `nexlayer_fix.md` on THIS branch (`nexlayer`) with this structure:

---
# Nexlayer Fix

## Fixed Dockerfile
```dockerfile
<your fixed Dockerfile>
```

## Fixed nexlayer.yaml
```yaml
<your fixed nexlayer.yaml>
```

## Notes
<explain: what build command you found, what was wrong with the previous Dockerfile, what you changed and why>
---

Nexlayer detects `nexlayer_fix.md` on the next pipeline run and applies your fixes automatically.
