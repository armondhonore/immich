FROM mirror.gcr.io/library/node:22-slim

# Install build dependencies for native modules and general tools
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

# Use corepack to install the exact pnpm version specified in packageManager
RUN npm install -g corepack@latest && corepack enable && corepack prepare pnpm@11.6.0 --activate

WORKDIR /repo

# Copy everything first to avoid complex monorepo dependency mapping issues in single-stage
COPY . .

# Install dependencies skipping frozen lockfile and ignoring scripts to avoid husky/prepare failures
RUN pnpm install --no-frozen-lockfile --ignore-scripts

# The app is in packages/e2e-auth-server
# It uses 'tsx' to run 'startup.ts' directly (no build step needed based on package.json)
WORKDIR /repo/packages/e2e-auth-server

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

EXPOSE 3000

# Use npx tsx to ensure the binary is found regardless of pnpm pathing
CMD ["npx", "tsx", "startup.ts"]