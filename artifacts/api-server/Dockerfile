# Gurme API sunucusu — Google Cloud Run imajı
#
# Depo kökünden derlenir (workspace paketlerine erişmek için):
#   docker build -f artifacts/api-server/Dockerfile -t gurme-api .
# Apple Silicon üzerinde Cloud Run için: --platform linux/amd64

FROM node:24-slim AS build
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc tsconfig.base.json tsconfig.json ./
COPY lib ./lib
COPY scripts/package.json ./scripts/package.json
COPY artifacts/api-server ./artifacts/api-server
RUN pnpm install --frozen-lockfile --filter @workspace/api-server...
RUN pnpm --filter @workspace/api-server run build
# Paketlenmeyen (external) bağımlılıkları çalışma imajı için ayır
RUN pnpm --filter @workspace/api-server deploy --prod --legacy /out \
  && cp -r artifacts/api-server/dist /out/dist

FROM node:24-slim
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /out ./
USER node
# Cloud Run PORT değişkenini kendisi verir (varsayılan 8080)
ENV PORT=8080
CMD ["node", "dist/index.cjs"]
