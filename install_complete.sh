#!/bin/bash

# BarrierLayer Installation Script
# Instala e configura o BarrierLayer para compatibilidade com anti-cheats

set -e

INSTALL_DIR="/opt/barrierlayer"
CONFIG_DIR="/etc/barrierlayer"
LOG_DIR="/var/log/barrierlayer"
SERVICE_DIR="/etc/systemd/system"

echo "=== BarrierLayer Installation Script ==="
echo "Instalando BarrierLayer para compatibilidade com jogos anti-cheat no Linux"
echo

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root (use sudo)" 
   exit 1
fi

# Criar diretórios
echo "[INFO] Criando diretórios..."
mkdir -p "$INSTALL_DIR"/{bin,lib,share}
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"

# Copiar binários
echo "[INFO] Copiando binários..."
cp bin/barrierlayer_hook64.so "$INSTALL_DIR/lib/"
cp bin/barrierlayer_hook32.so "$INSTALL_DIR/lib/"
cp bin/stealth_launcher "$INSTALL_DIR/bin/"
cp bin/sandbox_launcher "$INSTALL_DIR/bin/"

# Definir permissões
chmod 755 "$INSTALL_DIR/bin/"*
chmod 644 "$INSTALL_DIR/lib/"*

# Criar configuração padrão
echo "[INFO] Criando configuração padrão..."
cat > "$CONFIG_DIR/barrierlayer.conf" << 'EOF'
# BarrierLayer Configuration File

# Logging
LOG_LEVEL=INFO
LOG_DIR=/var/log/barrierlayer

# Anti-cheat compatibility
ENABLE_EAC=true
ENABLE_BATTLEYE=true
ENABLE_VANGUARD=true

# Hardware spoofing
SPOOF_CPU=true
SPOOF_TPM=true
SPOOF_SECURE_BOOT=true

# Memory protection
ENABLE_SHADOW_PAGES=true
ENABLE_INTEGRITY_CHECKS=true

# Process hiding
HIDE_BARRIERLAYER_PROCESSES=true
ENABLE_ANTI_DEBUG=true

# Wine/Proton integration
AUTO_DETECT_PROTON=true
PROTON_PATH=
WINE_PREFIX=

# Advanced features
ENABLE_KERNEL_MODULE=false
KERNEL_MODULE_PATH=/opt/barrierlayer/kernel/barrierlayer.ko
EOF

# Criar script de inicialização
echo "[INFO] Criando script de inicialização..."
cat > "$INSTALL_DIR/bin/barrierlayer" << 'EOF'
#!/bin/bash

# BarrierLayer Main Script
CONFIG_FILE="/etc/barrierlayer/barrierlayer.conf"
HOOK_LIB_64="/opt/barrierlayer/lib/barrierlayer_hook64.so"
HOOK_LIB_32="/opt/barrierlayer/lib/barrierlayer_hook32.so"

# Carregar configuração
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Detectar arquitetura do executável
detect_arch() {
    local exe="$1"
    if file "$exe" | grep -q "ELF 64-bit"; then
        echo "64"
    elif file "$exe" | grep -q "ELF 32-bit"; then
        echo "32"
    else
        echo "unknown"
    fi
}

# Função principal
run_with_barrierlayer() {
    local target="$1"
    shift
    
    if [[ ! -f "$target" ]]; then
        echo "Erro: Executável não encontrado: $target"
        exit 1
    fi
    
    local arch=$(detect_arch "$target")
    local hook_lib=""
    
    case "$arch" in
        "64")
            hook_lib="$HOOK_LIB_64"
            ;;
        "32")
            hook_lib="$HOOK_LIB_32"
            ;;
        *)
            echo "Erro: Arquitetura não suportada para $target"
            exit 1
            ;;
    esac
    
    echo "[BARRIERLAYER] Executando $target com proteção anti-cheat"
    echo "[BARRIERLAYER] Arquitetura: $arch-bit"
    echo "[BARRIERLAYER] Hook library: $hook_lib"
    
    # Configurar variáveis de ambiente
    export BARRIERLAYER_ACTIVE=1
    export BARRIERLAYER_VERSION="2.0"
    export BARRIERLAYER_CONFIG="$CONFIG_FILE"
    
    # Executar com LD_PRELOAD
    LD_PRELOAD="$hook_lib" "$target" "$@"
}

# Verificar argumentos
if [[ $# -eq 0 ]]; then
    echo "Uso: barrierlayer <executável> [argumentos...]"
    echo
    echo "Exemplos:"
    echo "  barrierlayer /path/to/game.exe"
    echo "  barrierlayer steam steam://rungameid/123456"
    echo "  barrierlayer lutris lutris:rungame/game-name"
    exit 1
fi

run_with_barrierlayer "$@"
EOF

chmod +x "$INSTALL_DIR/bin/barrierlayer"

# Criar link simbólico
echo "[INFO] Criando link simbólico..."
ln -sf "$INSTALL_DIR/bin/barrierlayer" /usr/local/bin/barrierlayer

# Criar script de teste
echo "[INFO] Criando script de teste..."
cat > "$INSTALL_DIR/bin/test_barrierlayer" << 'EOF'
#!/bin/bash

echo "=== BarrierLayer Test Suite ==="
echo

# Teste 1: Verificar bibliotecas
echo "[TEST 1] Verificando bibliotecas..."
if [[ -f "/opt/barrierlayer/lib/barrierlayer_hook64.so" ]]; then
    echo "✓ Hook library 64-bit encontrada"
else
    echo "✗ Hook library 64-bit não encontrada"
fi

if [[ -f "/opt/barrierlayer/lib/barrierlayer_hook32.so" ]]; then
    echo "✓ Hook library 32-bit encontrada"
else
    echo "✗ Hook library 32-bit não encontrada"
fi

# Teste 2: Verificar executáveis
echo
echo "[TEST 2] Verificando executáveis..."
if [[ -x "/opt/barrierlayer/bin/stealth_launcher" ]]; then
    echo "✓ Stealth launcher encontrado"
else
    echo "✗ Stealth launcher não encontrado"
fi

if [[ -x "/opt/barrierlayer/bin/sandbox_launcher" ]]; then
    echo "✓ Sandbox launcher encontrado"
else
    echo "✗ Sandbox launcher não encontrado"
fi

# Teste 3: Verificar configuração
echo
echo "[TEST 3] Verificando configuração..."
if [[ -f "/etc/barrierlayer/barrierlayer.conf" ]]; then
    echo "✓ Arquivo de configuração encontrado"
else
    echo "✗ Arquivo de configuração não encontrado"
fi

# Teste 4: Teste básico de hook
echo
echo "[TEST 4] Testando hook básico..."
export BARRIERLAYER_ACTIVE=1
export BARRIERLAYER_VERSION="2.0"

if LD_PRELOAD="/opt/barrierlayer/lib/barrierlayer_hook64.so" /bin/echo "Hook test" > /dev/null 2>&1; then
    echo "✓ Hook 64-bit funcional"
else
    echo "✗ Hook 64-bit com problemas"
fi

# Teste 5: Verificar logs
echo
echo "[TEST 5] Verificando sistema de logs..."
if [[ -d "/var/log/barrierlayer" ]]; then
    echo "✓ Diretório de logs criado"
else
    echo "✗ Diretório de logs não encontrado"
fi

echo
echo "=== Teste concluído ==="
echo "Para usar o BarrierLayer: barrierlayer <seu_jogo>"
EOF

chmod +x "$INSTALL_DIR/bin/test_barrierlayer"

# Criar documentação
echo "[INFO] Criando documentação..."
cat > "$INSTALL_DIR/share/README.md" << 'EOF'
# BarrierLayer - Anti-Cheat Compatibility Layer

BarrierLayer é uma camada de compatibilidade que permite executar jogos com anti-cheat no Linux.

## Uso Básico

```bash
# Executar um jogo
barrierlayer /path/to/game.exe

# Executar via Steam
barrierlayer steam steam://rungameid/123456

# Executar via Lutris
barrierlayer lutris lutris:rungame/game-name
```

## Configuração

Edite `/etc/barrierlayer/barrierlayer.conf` para personalizar o comportamento.

## Teste

Execute o teste para verificar a instalação:
```bash
/opt/barrierlayer/bin/test_barrierlayer
```

## Logs

Os logs são salvos em `/var/log/barrierlayer/`

## Suporte

- EasyAntiCheat (EAC)
- BattlEye
- Vanguard (Riot Games)
- Outros anti-cheats baseados em kernel

## Recursos

- Spoofing de hardware (CPU, TPM, Secure Boot)
- Proteção de memória avançada
- Ocultação de processos
- Integração com Wine/Proton
- Sistema de logging avançado
EOF

echo
echo "=== Instalação Concluída ==="
echo
echo "BarrierLayer foi instalado com sucesso!"
echo
echo "Localização dos arquivos:"
echo "  Binários: $INSTALL_DIR/bin/"
echo "  Bibliotecas: $INSTALL_DIR/lib/"
echo "  Configuração: $CONFIG_DIR/"
echo "  Logs: $LOG_DIR/"
echo
echo "Para testar a instalação:"
echo "  sudo $INSTALL_DIR/bin/test_barrierlayer"
echo
echo "Para usar:"
echo "  barrierlayer <seu_jogo>"
echo
echo "Exemplo:"
echo "  barrierlayer ~/.steam/steam/steamapps/common/GameName/game.exe"
echo