#!/bin/sh

echo "Iniciando servicos..."

# 1. Inicia Evolution API em background
# Ajuste de memória para o Node da Evolution (tentar economizar RAM)
export NODE_OPTIONS="--max-old-space-size=200"
cd /evolution && npm run start:prod &
EVO_PID=$!
echo "Evolution API iniciada (PID $EVO_PID)"

# 2. Inicia Nginx em background
nginx &
NGINX_PID=$!
echo "Nginx iniciado (PID $NGINX_PID)"

# 3. Inicia n8n (Processo principal, não usamos & aqui para manter o container vivo)
# Mas para monitorar todos, vamos jogar em background e usar wait
cd /home/node
n8n &
N8N_PID=$!
echo "n8n iniciado (PID $N8N_PID)"

# Monitora os processos. Se algum cair, mata o container.
wait -n $N8N_PID $EVO_PID $NGINX_PID

# Se o wait terminar, significa que um processo morreu
echo "Um dos processos falhou. Encerrando container..."
kill -TERM $N8N_PID $EVO_PID $NGINX_PID
exit 1
