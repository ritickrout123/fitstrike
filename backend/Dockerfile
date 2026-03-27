# --- STAGE 1: BUILD ---
FROM node:20-slim AS builder

ARG CACHEBUST=1

# Install build dependencies for mediasoup
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install all dependencies (including dev) to build native modules
RUN npm install

# Copy source code
COPY . .

# --- STAGE 2: RUNTIME ---
FROM node:20-slim

WORKDIR /app

# Install runtime dependencies for mediasoup (if any, usually none beyond libc)
RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy built node_modules and source from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/src ./src

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Use tini for proper signal handling
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

CMD ["npm", "start"]
