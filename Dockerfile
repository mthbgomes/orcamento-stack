# Estágio 1: Pegar os arquivos da Evolution API
FROM evoapicloud/evolution-api:v2.3.7 AS evo_source

# Estágio 2: Imagem Final baseada no n8n
FROM n8nio/n8n:2.7.1

USER root

# 1. Instalar Nginx e dependências básicas
# ffmpeg é necessário para áudios do WhatsApp
RUN apk add --no-cache nginx ffmpeg curl

# 2. Configurar Evolution API
WORKDIR /evolution
# Copiamos a aplicação já buildada e com node_modules da imagem original
COPY --from=evo_source /evolution /evolution

# 3. Configurar Nginx
# Removemos a config padrão e colocamos a nossa
RUN rm /etc/nginx/http.d/default.conf
COPY nginx.conf /etc/nginx/http.d/default.conf
RUN mkdir -p /run/nginx

# 4. Script de Inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Voltamos para o diretório do n8n para garantir compatibilidade
WORKDIR /home/node

# Expõe a porta que o Render usa (ele injeta a var PORT, mas 10000 é o default interno nosso)
EXPOSE 10000

# O Entrypoint gerencia os processos
ENTRYPOINT ["/entrypoint.sh"]
