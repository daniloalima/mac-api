# Guia de Verificação - Servidor EC2 com macapi.xyz

## 🔍 CHECKLIST DE VERIFICAÇÃO COMPLETA

### 1. **Verificar Status dos Serviços**

```bash
# Status do Nginx
sudo systemctl status nginx

# Status do seu processo Python/FastAPI
ps aux | grep -E "(python|uvicorn|fastapi)" | grep -v grep

# Verificar se o processo está rodando na porta correta
sudo netstat -tlnp | grep :8000
```

### 2. **Verificar Configuração do Nginx**

```bash
# Listar configurações disponíveis
sudo ls -la /etc/nginx/sites-available/
sudo ls -la /etc/nginx/sites-enabled/

# Ver configuração ativa (ajuste o nome do arquivo conforme necessário)
sudo cat /etc/nginx/sites-available/macapi.xyz
# OU
sudo cat /etc/nginx/sites-available/default

# Testar configuração do Nginx
sudo nginx -t
```

### 3. **Verificar Certificados SSL**

```bash
# Verificar certificados Let's Encrypt
sudo ls -la /etc/letsencrypt/live/

# Detalhes do certificado (se usar Let's Encrypt)
sudo openssl x509 -in /etc/letsencrypt/live/macapi.xyz/cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before|Not After)"

# Testar certificado online
openssl s_client -connect macapi.xyz:443 -servername macapi.xyz </dev/null 2>/dev/null | openssl x509 -noout -dates

# Verificar validade do certificado
echo | openssl s_client -servername macapi.xyz -connect macapi.xyz:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates
```

### 4. **Verificar DNS**

```bash
# Resolução DNS
dig macapi.xyz A +short
dig www.macapi.xyz A +short

# Verificar registros completos
dig macapi.xyz ANY
```

### 5. **Verificar Conectividade**

```bash
# Teste HTTP
curl -I http://macapi.xyz

# Teste HTTPS
curl -I https://macapi.xyz

# Teste da API
curl https://macapi.xyz/
curl https://macapi.xyz/mesas
```

### 6. **Verificar Logs**

```bash
# Logs do Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Logs do sistema
sudo journalctl -u nginx -f
```

### 7. **Verificar Firewall e Portas**

```bash
# Status do firewall
sudo ufw status

# Portas abertas
sudo netstat -tlnp | grep -E ":80 |:443 |:8000 "

# Verificar iptables
sudo iptables -L -n
```

---

## 🚨 PROBLEMAS COMUNS E SOLUÇÕES

### **Certificado SSL Expirado**
```bash
# Renovar certificado Let's Encrypt
sudo certbot renew --dry-run
sudo certbot renew

# Reiniciar Nginx após renovação
sudo systemctl reload nginx
```

### **Nginx não iniciando**
```bash
# Verificar erros de configuração
sudo nginx -t

# Ver logs de erro detalhados
sudo journalctl -u nginx --since "1 hour ago"
```

### **API não respondendo**
```bash
# Verificar se o processo Python está rodando
ps aux | grep python

# Verificar logs da aplicação (ajuste o caminho)
tail -f /var/log/mac-api/app.log  # ou onde estão seus logs

# Reiniciar aplicação (exemplo com systemd)
sudo systemctl restart mac-api  # ajuste conforme seu setup
```

### **Problemas de CORS**
Verificar se a configuração de CORS no `app.py` permite o domínio correto:
```python
origins = [
    "https://macapi.xyz",
    "http://macapi.xyz",
    "https://www.macapi.xyz",
]
```

---

## 📋 CONFIGURAÇÃO NGINX RECOMENDADA

Exemplo de configuração para `/etc/nginx/sites-available/macapi.xyz`:

```nginx
server {
    listen 80;
    server_name macapi.xyz www.macapi.xyz;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name macapi.xyz www.macapi.xyz;

    # Certificados SSL
    ssl_certificate /etc/letsencrypt/live/macapi.xyz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/macapi.xyz/privkey.pem;
    
    # Configurações SSL seguras
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Headers de segurança
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;

    # Proxy para a aplicação FastAPI
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

---

## 🔧 COMANDOS DE MANUTENÇÃO

```bash
# Recarregar Nginx (sem downtime)
sudo systemctl reload nginx

# Reiniciar Nginx
sudo systemctl restart nginx

# Verificar status dos certificados
sudo certbot certificates

# Renovação automática (já deve estar configurada)
sudo crontab -l | grep certbot
```

---

## ✅ SCRIPT AUTOMATIZADO

Execute o script que criei para fazer todas as verificações de uma vez:

```bash
# No seu servidor EC2
./server-health-check.sh
```

Este script fará todas as verificações automaticamente e te dará um relatório completo do status do seu servidor.
