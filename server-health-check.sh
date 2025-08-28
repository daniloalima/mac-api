#!/bin/bash

echo "==========================================="
echo "        CHECKLIST DE SAÚDE DO SERVIDOR"
echo "        Domínio: macapi.xyz"
echo "==========================================="

echo ""
echo "1. VERIFICANDO STATUS DO NGINX..."
echo "-------------------------------------------"
sudo systemctl status nginx --no-pager

echo ""
echo "2. VERIFICANDO CONFIGURAÇÃO DO NGINX..."
echo "-------------------------------------------"
echo "Arquivos de configuração do nginx:"
sudo ls -la /etc/nginx/sites-available/
sudo ls -la /etc/nginx/sites-enabled/

echo ""
echo "Conteúdo da configuração (se existir):"
if [ -f /etc/nginx/sites-available/macapi.xyz ]; then
    echo "Arquivo: /etc/nginx/sites-available/macapi.xyz"
    sudo cat /etc/nginx/sites-available/macapi.xyz
elif [ -f /etc/nginx/sites-available/default ]; then
    echo "Arquivo: /etc/nginx/sites-available/default"
    sudo cat /etc/nginx/sites-available/default
fi

echo ""
echo "3. VERIFICANDO CERTIFICADOS SSL..."
echo "-------------------------------------------"
echo "Certificados Let's Encrypt:"
sudo ls -la /etc/letsencrypt/live/ 2>/dev/null || echo "Diretório Let's Encrypt não encontrado"

if [ -d /etc/letsencrypt/live/macapi.xyz ]; then
    echo "Detalhes do certificado macapi.xyz:"
    sudo openssl x509 -in /etc/letsencrypt/live/macapi.xyz/cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After)"
fi

echo ""
echo "4. TESTANDO CERTIFICADOS ONLINE..."
echo "-------------------------------------------"
echo "Verificando SSL do domínio:"
openssl s_client -connect macapi.xyz:443 -servername macapi.xyz </dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "Erro ao conectar via HTTPS"

echo ""
echo "5. VERIFICANDO DNS..."
echo "-------------------------------------------"
echo "Resolução DNS do domínio:"
dig macapi.xyz A +short
dig www.macapi.xyz A +short

echo ""
echo "6. VERIFICANDO PROCESSOS DA APLICAÇÃO..."
echo "-------------------------------------------"
echo "Processos Python/FastAPI rodando:"
ps aux | grep -E "(python|uvicorn|fastapi)" | grep -v grep

echo ""
echo "7. VERIFICANDO PORTAS EM USO..."
echo "-------------------------------------------"
echo "Portas 80, 443 e 8000:"
sudo netstat -tlnp | grep -E ":80 |:443 |:8000 "

echo ""
echo "8. VERIFICANDO LOGS DO NGINX..."
echo "-------------------------------------------"
echo "Últimas 10 linhas do log de erro:"
sudo tail -10 /var/log/nginx/error.log 2>/dev/null || echo "Log de erro não encontrado"

echo "Últimas 10 linhas do log de acesso:"
sudo tail -10 /var/log/nginx/access.log 2>/dev/null || echo "Log de acesso não encontrado"

echo ""
echo "9. VERIFICANDO FIREWALL..."
echo "-------------------------------------------"
echo "Status do UFW:"
sudo ufw status

echo ""
echo "10. TESTANDO CONECTIVIDADE..."
echo "-------------------------------------------"
echo "Teste HTTP:"
curl -I http://macapi.xyz 2>/dev/null || echo "Erro ao conectar via HTTP"

echo ""
echo "Teste HTTPS:"
curl -I https://macapi.xyz 2>/dev/null || echo "Erro ao conectar via HTTPS"

echo ""
echo "==========================================="
echo "        CHECKLIST CONCLUÍDO"
echo "==========================================="
