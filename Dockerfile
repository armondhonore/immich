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