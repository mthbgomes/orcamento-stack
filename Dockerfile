# Estágio 1: Pegar os arquivos da Evolution API
FROM evoapicloud/evolution-api:v2.3.7 AS evo_source

# Estágio 2: Imagem Final baseada no n8n (Debian)
FROM n8nio/n8n:2.7.1

USER root

# 1. Instalar Nginx e dependências (Mudança de apk para apt-get)
# procps é necessário para lidar com processos
RUN apt-get update && \
    apt-get install -y nginx ffmpeg curl procps && \
    rm -rf /var/lib/apt/lists/*

# 2. Configurar Evolution API
WORKDIR /evolution
COPY --from=evo_source /evolution /evolution

# 3. Configurar Nginx
# No Debian, o caminho padrão é /etc/nginx/conf.d/default.conf
# Removemos o padrão se existir
RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 4. Script de Inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Voltamos para o diretório do n8n
WORKDIR /home/node

# Expõe a porta
EXPOSE 10000

# Define o shell como bash para garantir compatibilidade do script
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
