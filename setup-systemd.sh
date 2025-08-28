#!/bin/bash

echo "==========================================="
echo "  CONFIGURANDO SERVIÇO SYSTEMD MAC-API"
echo "==========================================="

# Detectar o diretório atual do projeto
PROJECT_DIR=$(pwd)
USER=$(whoami)

echo "Projeto detectado em: $PROJECT_DIR"
echo "Usuário: $USER"

# Criar arquivo de serviço systemd
sudo tee /etc/systemd/system/mac-api.service > /dev/null <<EOF
[Unit]
Description=MAC API FastAPI Application
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment=PATH=$PROJECT_DIR/venv/bin
ExecStart=/usr/bin/python3 $PROJECT_DIR/app.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Arquivo de serviço criado: /etc/systemd/system/mac-api.service"

# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar o serviço para iniciar automaticamente
sudo systemctl enable mac-api

echo ""
echo "==========================================="
echo "           SERVIÇO CONFIGURADO"
echo "==========================================="
echo ""
echo "📋 COMANDOS DO SERVIÇO:"
echo "   • Iniciar:    sudo systemctl start mac-api"
echo "   • Parar:      sudo systemctl stop mac-api"
echo "   • Reiniciar:  sudo systemctl restart mac-api"
echo "   • Status:     sudo systemctl status mac-api"
echo "   • Logs:       sudo journalctl -u mac-api -f"
echo ""
echo "🔧 PRÓXIMOS PASSOS:"
echo "   1. sudo systemctl start mac-api"
echo "   2. sudo systemctl status mac-api"
echo "   3. curl http://127.0.0.1:8000/"
echo ""
echo "✅ O serviço será iniciado automaticamente no boot"
