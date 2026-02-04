#!/bin/sh

echo "Iniciando servicos..."

# Inicia Evolution API
export NODE_OPTIONS="--max-old-space-size=200"
cd /evolution && npm run start:prod &
EVO_PID=$!
echo "Evolution API iniciada (PID $EVO_PID)"

# Inicia Nginx
nginx &
NGINX_PID=$!
echo "Nginx iniciado (PID $NGINX_PID)"

# Inicia n8n
cd /home/node
n8n &
N8N_PID=$!
echo "n8n iniciado (PID $N8N_PID)"

# Monitora processos
wait -n $N8N_PID $EVO_PID $NGINX_PID

# Se algo cair, mata tudo
kill -TERM $N8N_PID $EVO_PID $NGINX_PID
exit 1
