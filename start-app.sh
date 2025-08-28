#!/bin/bash

echo "==========================================="
echo "    INICIANDO A APLICAÇÃO MAC-API"
echo "==========================================="

echo ""
echo "1. VERIFICANDO SE A APLICAÇÃO JÁ ESTÁ RODANDO..."
echo "-------------------------------------------"
if pgrep -f "python.*app.py\|uvicorn.*app:app" > /dev/null; then
    echo "⚠️  Aplicação já está rodando:"
    ps aux | grep -E "(python.*app|uvicorn.*app)" | grep -v grep
    echo ""
    echo "Para reiniciar, execute: pkill -f 'python.*app.py'"
    exit 0
else
    echo "✅ Nenhuma instância da aplicação encontrada. Prosseguindo..."
fi

echo ""
echo "2. VERIFICANDO DEPENDÊNCIAS..."
echo "-------------------------------------------"
if command -v python3 &> /dev/null; then
    echo "✅ Python3 encontrado: $(python3 --version)"
else
    echo "❌ Python3 não encontrado!"
    exit 1
fi

if command -v pip3 &> /dev/null; then
    echo "✅ pip3 encontrado"
else
    echo "❌ pip3 não encontrado!"
    exit 1
fi

echo ""
echo "3. VERIFICANDO ESTRUTURA DO PROJETO..."
echo "-------------------------------------------"
if [ -f "app.py" ]; then
    echo "✅ app.py encontrado"
else
    echo "❌ app.py não encontrado no diretório atual!"
    echo "   Navegue para o diretório do projeto primeiro"
    exit 1
fi

if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt encontrado"
else
    echo "⚠️  requirements.txt não encontrado"
fi

echo ""
echo "4. INSTALANDO/VERIFICANDO DEPENDÊNCIAS..."
echo "-------------------------------------------"
echo "Instalando dependências necessárias..."
pip3 install fastapi uvicorn --user

echo ""
echo "5. INICIANDO A APLICAÇÃO..."
echo "-------------------------------------------"
echo "Iniciando aplicação em background..."
nohup python3 app.py > mac-api.log 2>&1 &
APP_PID=$!

echo "✅ Aplicação iniciada com PID: $APP_PID"
echo "   Log: mac-api.log"

# Aguardar um pouco para a aplicação inicializar
sleep 3

echo ""
echo "6. VERIFICANDO SE A APLICAÇÃO INICIOU..."
echo "-------------------------------------------"
if netstat -tlnp 2>/dev/null | grep ":8000 " > /dev/null; then
    echo "✅ Aplicação rodando na porta 8000"
    echo "   Processo: $(ps aux | grep -E 'python.*app.py' | grep -v grep)"
else
    echo "❌ Aplicação não está rodando na porta 8000"
    echo "   Verificando logs:"
    tail -10 mac-api.log
    exit 1
fi

echo ""
echo "7. TESTANDO A APLICAÇÃO..."
echo "-------------------------------------------"
echo "Testando endpoint local..."
if curl -s http://127.0.0.1:8000/ > /dev/null; then
    echo "✅ Aplicação respondendo localmente"
    curl -s http://127.0.0.1:8000/ | head -1
else
    echo "❌ Aplicação não responde localmente"
    echo "   Verificando logs:"
    tail -10 mac-api.log
fi

echo ""
echo "8. TESTANDO VIA NGINX..."
echo "-------------------------------------------"
echo "Testando via nginx..."
if curl -s https://macapi.xyz/ > /dev/null; then
    echo "✅ Aplicação acessível via HTTPS"
else
    echo "⚠️  Problema ao acessar via HTTPS - verifique nginx"
fi

echo ""
echo "==========================================="
echo "        INICIALIZAÇÃO CONCLUÍDA"
echo "==========================================="
echo ""
echo "📋 RESUMO:"
echo "   • PID da aplicação: $APP_PID"
echo "   • Log da aplicação: mac-api.log"
echo "   • Para parar: kill $APP_PID"
echo "   • Para ver logs: tail -f mac-api.log"
echo ""
echo "🔧 COMANDOS ÚTEIS:"
echo "   • Ver processos: ps aux | grep python"
echo "   • Ver porta 8000: netstat -tlnp | grep :8000"
echo "   • Testar API: curl http://127.0.0.1:8000/"
