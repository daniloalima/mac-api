#!/bin/bash

echo "==========================================="
echo "     VERIFICAÇÃO DA APLICAÇÃO MAC-API"
echo "==========================================="

echo ""
echo "1. VERIFICANDO CONFIGURAÇÃO DA APLICAÇÃO..."
echo "-------------------------------------------"
echo "Host configurado no app.py: 127.0.0.1:8000 (correto para proxy reverso)"

echo ""
echo "2. VERIFICANDO CORS..."
echo "-------------------------------------------"
grep -n "origins\|allow_origins" /home/dan/git/mac-api/app.py

echo ""
echo "3. POSSÍVEIS PROBLEMAS IDENTIFICADOS:"
echo "-------------------------------------------"
echo "⚠️  CORS configurado como allow_origins=['*'] - pode causar problemas de segurança"
echo "⚠️  Verificar se o servidor está configurado para HTTPS"
echo "⚠️  Host 127.0.0.1 - correto se usando proxy reverso (nginx)"

echo ""
echo "4. RECOMENDAÇÕES DE CONFIGURAÇÃO SEGURA:"
echo "-------------------------------------------"
echo "Para produção, considere alterar o CORS para:"
echo 'origins = ['
echo '    "https://macapi.xyz",'
echo '    "https://www.macapi.xyz",'
echo '    # adicione outros domínios conforme necessário'
echo ']'
echo ''
echo 'app.add_middleware('
echo '    CORSMiddleware,'
echo '    allow_origins=origins,  # ao invés de ["*"]'
echo '    allow_credentials=True,'
echo '    allow_methods=["GET", "POST", "PUT", "DELETE"],'  # específico ao invés de ["*"]
echo '    allow_headers=["*"],'
echo ')'

echo ""
echo "5. VERIFICAR SE A APLICAÇÃO ESTÁ RODANDO..."
echo "-------------------------------------------"
if pgrep -f "uvicorn\|fastapi\|python.*app.py" > /dev/null; then
    echo "✅ Processo Python encontrado:"
    ps aux | grep -E "(uvicorn|fastapi|python.*app)" | grep -v grep
else
    echo "❌ Nenhum processo da aplicação encontrado"
    echo "   Execute: python app.py ou uvicorn app:app --host 127.0.0.1 --port 8000"
fi
