# Estágio 1: Pegar os arquivos da Evolution API
FROM evoapicloud/evolution-api:v2.3.7 AS evo_source

# Estágio 2: Imagem Final baseada em Node Alpine (Leve e com apk funcionando)
FROM node:20-alpine

USER root

# 1. Instalar Nginx e dependências do sistema
# graphicsmagick é recomendado para o n8n lidar com imagens
RUN apk add --no-cache nginx ffmpeg curl git graphicsmagick

# 2. Instalar o n8n manualmente na versão desejada
RUN npm install -g n8n@2.7.1

# 3. Configurar Evolution API
WORKDIR /evolution
# Copia a aplicação Evolution pronta
COPY --from=evo_source /evolution /evolution

# Tenta reconstruir dependências nativas caso haja incompatibilidade de sistema
# (Isso previne erros de 'musl' vs 'glibc')
RUN npm rebuild

# 4. Configurar Nginx
RUN mkdir -p /run/nginx
# Remove config padrão e adiciona a nossa
RUN rm -f /etc/nginx/http.d/default.conf
COPY nginx.conf /etc/nginx/http.d/default.conf

# 5. Script de Inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define diretório de trabalho padrão
WORKDIR /home/node

# Porta do Render
EXPOSE 10000

# Inicia tudo
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
