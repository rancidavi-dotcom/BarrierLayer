#!/bin/bash
# BarrierLayer Complete Installation Script
# Instala tudo automaticamente: dependências, compilação, configuração e Wine-safe mode

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🛡️  BARRIERLAYER 🛡️                      ║"
echo "║              Complete Installation Script                    ║"
echo "║                                                              ║"
echo "║  🎮 Anti-Cheat Bypass for Linux Gaming                      ║"
echo "║  🍷 Wine/Proton Compatible                                   ║"
echo "║  🏗️  Arch Linux Ready                                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ Este script não deve ser executado como root!${NC}"
   echo -e "${YELLOW}💡 Execute como usuário normal. O sudo será solicitado quando necessário.${NC}"
   exit 1
fi

# Detect distribution
echo -e "${BLUE}🔍 Detectando distribuição Linux...${NC}"

if command -v pacman &> /dev/null; then
    DISTRO="arch"
    echo -e "${GREEN}✅ Arch Linux detectado${NC}"
elif command -v apt &> /dev/null; then
    DISTRO="debian"
    echo -e "${GREEN}✅ Debian/Ubuntu detectado${NC}"
elif command -v dnf &> /dev/null; then
    DISTRO="fedora"
    echo -e "${GREEN}✅ Fedora detectado${NC}"
elif command -v zypper &> /dev/null; then
    DISTRO="opensuse"
    echo -e "${GREEN}✅ openSUSE detectado${NC}"
else
    echo -e "${RED}❌ Distribuição não suportada!${NC}"
    echo -e "${YELLOW}💡 Suportado: Arch Linux, Debian/Ubuntu, Fedora, openSUSE${NC}"
    exit 1
fi

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}📦 Instalando dependências...${NC}"
    
    case $DISTRO in
        "arch")
            echo -e "${CYAN}🏗️  Atualizando sistema Arch Linux...${NC}"
            sudo pacman -Syu --noconfirm
            
            echo -e "${CYAN}📚 Instalando dependências de desenvolvimento...${NC}"
            sudo pacman -S --needed --noconfirm \
                base-devel \
                gcc \
                make \
                cmake \
                git \
                linux-headers \
                libseccomp \
                wine \
                winetricks \
                lib32-libseccomp \
                nasm \
                pkg-config \
                dkms
            ;;
        "debian")
            echo -e "${CYAN}🏗️  Atualizando sistema Debian/Ubuntu...${NC}"
            sudo apt update && sudo apt upgrade -y
            
            echo -e "${CYAN}📚 Instalando dependências de desenvolvimento...${NC}"
            sudo apt install -y \
                build-essential \
                gcc \
                gcc-multilib \
                make \
                cmake \
                git \
                linux-headers-$(uname -r) \
                libseccomp-dev \
                libseccomp2:i386 \
                wine \
                winetricks \
                nasm \
                pkg-config \
                dkms
            ;;
        "fedora")
            echo -e "${CYAN}🏗️  Atualizando sistema Fedora...${NC}"
            sudo dnf update -y
            
            echo -e "${CYAN}📚 Instalando dependências de desenvolvimento...${NC}"
            sudo dnf install -y \
                @development-tools \
                gcc \
                gcc.i686 \
                make \
                cmake \
                git \
                kernel-devel \
                libseccomp-devel \
                wine \
                winetricks \
                nasm \
                pkg-config \
                dkms
            ;;
        "opensuse")
            echo -e "${CYAN}🏗️  Atualizando sistema openSUSE...${NC}"
            sudo zypper refresh && sudo zypper update -y
            
            echo -e "${CYAN}📚 Instalando dependências de desenvolvimento...${NC}"
            sudo zypper install -y \
                -t pattern devel_basis \
                gcc \
                gcc-32bit \
                make \
                cmake \
                git \
                kernel-devel \
                libseccomp-devel \
                wine \
                nasm \
                pkg-config \
                dkms
            ;;
    esac
    
    echo -e "${GREEN}✅ Dependências instaladas com sucesso!${NC}"
}

# Function to setup directories
setup_directories() {
    echo -e "${BLUE}📁 Configurando diretórios...${NC}"
    
    # Create BarrierLayer config directory
    mkdir -p "$HOME/BarrierLayer"
    mkdir -p "$HOME/.config/barrierlayer"
    
    # Create log directory
    sudo mkdir -p /var/log/barrierlayer
    sudo chown $USER:$USER /var/log/barrierlayer
    
    echo -e "${GREEN}✅ Diretórios configurados!${NC}"
}

# Function to compile BarrierLayer
compile_barrierlayer() {
    echo -e "${BLUE}🔨 Compilando BarrierLayer...${NC}"
    
    # Clean previous builds
    make clean
    
    # Compile in release mode for production
    echo -e "${CYAN}⚙️  Compilando em modo release...${NC}"
    BUILD_MODE=release make -j$(nproc)
    
    echo -e "${GREEN}✅ Compilação concluída com sucesso!${NC}"
}

# Function to install BarrierLayer
install_barrierlayer() {
    echo -e "${BLUE}📦 Instalando BarrierLayer no sistema...${NC}"
    
    # Create installation directories
    sudo mkdir -p /opt/barrierlayer/{bin,lib,share,config}
    sudo mkdir -p /usr/local/bin
    sudo mkdir -p /usr/local/share/applications
    sudo mkdir -p /etc/barrierlayer
    
    # Install binaries
    echo -e "${CYAN}📋 Instalando binários...${NC}"
    sudo cp bin/* /opt/barrierlayer/bin/
    sudo chmod +x /opt/barrierlayer/bin/*
    
    # Install Wine-safe wrapper
    echo -e "${CYAN}🍷 Instalando wrapper Wine-safe...${NC}"
    sudo cp barrierlayer-wine /usr/local/bin/
    sudo chmod +x /usr/local/bin/barrierlayer-wine
    
    # Create main launcher script with NOLOG support
    echo -e "${CYAN}🚀 Criando launcher principal...${NC}"
    sudo tee /usr/local/bin/barrierlayer > /dev/null << 'EOF'
#!/bin/bash
# BarrierLayer Main Launcher

BARRIERLAYER_DIR="/opt/barrierlayer"
HOOK_LIB64="$BARRIERLAYER_DIR/bin/barrierlayer_hook64.so"
HOOK_LIB32="$BARRIERLAYER_DIR/bin/barrierlayer_hook32.so"

# Detect architecture
if file "$1" 2>/dev/null | grep -q "32-bit"; then
    HOOK_LIB="$HOOK_LIB32"
else
    HOOK_LIB="$HOOK_LIB64"
fi

# Check if hook library exists
if [[ ! -f "$HOOK_LIB" ]]; then
    echo "❌ BarrierLayer hook library not found: $HOOK_LIB"
    exit 1
fi

# Set environment
export LD_PRELOAD="$HOOK_LIB"
export BARRIERLAYER_CONFIG_DIR="$HOME/.config/barrierlayer"
export BARRIERLAYER_LOG_DIR="/var/log/barrierlayer"

# Configure logging based on BARRIERLAYER_NOLOG
if [[ "$BARRIERLAYER_NOLOG" == "1" ]]; then
    export BARRIERLAYER_LOG_LEVEL=SILENT
    export BARRIERLAYER_DISABLE_ULTRA_LOG=1
else
    export BARRIERLAYER_LOG_LEVEL=INFO
fi

# Wine-safe mode by default
export BARRIERLAYER_WINE_SAFE=1

# Execute target application
exec "$@"
EOF
    sudo chmod +x /usr/local/bin/barrierlayer
    
    # Update Wine wrapper to support NOLOG
    sudo tee /usr/local/bin/barrierlayer-wine > /dev/null << 'EOF'
#!/bin/bash
# BarrierLayer Wine-Safe Launcher

# Enable Wine-safe mode by default
export BARRIERLAYER_WINE_SAFE=1

# Configure logging based on BARRIERLAYER_NOLOG
if [[ "$BARRIERLAYER_NOLOG" == "1" ]]; then
    export BARRIERLAYER_LOG_LEVEL=SILENT
    export BARRIERLAYER_DISABLE_ULTRA_LOG=1
else
    export BARRIERLAYER_LOG_LEVEL=INFO
fi

# Execute BarrierLayer with Wine-safe mode
exec /usr/local/bin/barrierlayer "$@"
EOF
    sudo chmod +x /usr/local/bin/barrierlayer-wine
    
    # Create Wine-safe symlinks
    sudo ln -sf /usr/local/bin/barrierlayer-wine /usr/local/bin/barrierlayer-wine-safe
    sudo ln -sf /usr/local/bin/barrierlayer-wine /usr/local/bin/bl-wine
    sudo ln -sf /usr/local/bin/barrierlayer /usr/local/bin/bl
    
    # Install desktop entry
    echo -e "${CYAN}🖥️  Criando entrada no menu...${NC}"
    sudo tee /usr/local/share/applications/barrierlayer.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=BarrierLayer
Comment=Anti-Cheat Bypass for Linux Gaming
Exec=barrierlayer-wine wine
Icon=applications-games
Terminal=true
Type=Application
Categories=Game;Utility;
Keywords=anticheat;bypass;wine;gaming;
EOF
    
    echo -e "${GREEN}✅ BarrierLayer instalado no sistema!${NC}"
}

# Function to setup kernel module
setup_kernel_module() {
    echo -e "${BLUE}🔧 Configurando módulo do kernel...${NC}"
    
    if [[ -d "kernel" ]]; then
        echo -e "${CYAN}⚙️  Compilando módulo do kernel...${NC}"
        cd kernel
        make
        
        # Install kernel module
        sudo make install
        
        # Load module
        sudo modprobe barrierlayer_stealth || echo -e "${YELLOW}⚠️  Módulo do kernel opcional não carregado${NC}"
        
        cd ..
        echo -e "${GREEN}✅ Módulo do kernel configurado!${NC}"
    else
        echo -e "${YELLOW}⚠️  Diretório do kernel não encontrado, pulando...${NC}"
    fi
}

# Function to create configuration files
create_config_files() {
    echo -e "${BLUE}⚙️  Criando arquivos de configuração...${NC}"
    
    # Main config
    tee "$HOME/.config/barrierlayer/config.conf" > /dev/null << 'EOF'
# BarrierLayer Configuration File

[General]
log_level=INFO
stealth_mode=true
wine_safe_mode=true

[AntiCheat]
eac_bypass=true
battleye_bypass=true
vac_bypass=true

[Wine]
auto_detect=true
safe_mode=true
filter_system_processes=true

[Logging]
enable_ultra_logging=true
log_directory=/var/log/barrierlayer
max_log_size=10MB
rotate_logs=true
EOF

    # Files config
    tee "$HOME/BarrierLayer/files.conf" > /dev/null << 'EOF'
# BarrierLayer File Hiding Configuration
# Format: action:path_pattern

# Hide BarrierLayer files
hide:/opt/barrierlayer/*
hide:*barrierlayer*
hide:*.so.barrierlayer

# Hide common cheat detection files
hide:/proc/*/maps
hide:/proc/*/mem
hide:/proc/*/status
EOF

    # Network config
    tee "$HOME/BarrierLayer/network.conf" > /dev/null << 'EOF'
# BarrierLayer Network Configuration
# Format: action:address:port

# Block common anti-cheat servers
block:*.easyanticheat.net:*
block:*.battleye.com:*
block:*.valvesoftware.com:*
EOF

    echo -e "${GREEN}✅ Arquivos de configuração criados!${NC}"
}

# Function to setup Wine environment
setup_wine() {
    echo -e "${BLUE}🍷 Configurando ambiente Wine...${NC}"
    
    # Initialize Wine if not already done
    if [[ ! -d "$HOME/.wine" ]]; then
        echo -e "${CYAN}🔧 Inicializando Wine...${NC}"
        WINEARCH=win64 winecfg &
        sleep 3
        pkill winecfg || true
    fi
    
    # Install common Wine dependencies
    echo -e "${CYAN}📚 Instalando dependências Wine...${NC}"
    winetricks -q vcrun2019 corefonts || echo -e "${YELLOW}⚠️  Algumas dependências Wine podem ter falhado${NC}"
    
    echo -e "${GREEN}✅ Wine configurado!${NC}"
}

# Function to run tests
run_tests() {
    echo -e "${BLUE}🧪 Executando testes...${NC}"
    
    # Test basic functionality
    echo -e "${CYAN}🔍 Testando funcionalidade básica...${NC}"
    if LD_PRELOAD="./bin/barrierlayer_hook64.so" /bin/echo "Teste BarrierLayer" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Teste básico passou!${NC}"
    else
        echo -e "${RED}❌ Teste básico falhou!${NC}"
        return 1
    fi
    
    # Test Wine-safe mode
    echo -e "${CYAN}🍷 Testando modo Wine-safe...${NC}"
    cp /bin/echo ./svchost.exe
    if BARRIERLAYER_WINE_SAFE=1 LD_PRELOAD="./bin/barrierlayer_hook64.so" ./svchost.exe "Teste Wine Safe" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Teste Wine-safe passou!${NC}"
    else
        echo -e "${RED}❌ Teste Wine-safe falhou!${NC}"
        return 1
    fi
    rm -f ./svchost.exe
    
    # Test NOLOG mode
    echo -e "${CYAN}🔇 Testando modo NOLOG...${NC}"
    if BARRIERLAYER_NOLOG=1 LD_PRELOAD="./bin/barrierlayer_hook64.so" /bin/echo "Teste NOLOG" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Teste NOLOG passou!${NC}"
    else
        echo -e "${RED}❌ Teste NOLOG falhou!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Todos os testes passaram!${NC}"
}

# Function to show usage instructions
show_usage() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 INSTALAÇÃO CONCLUÍDA! 🎉               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}🎯 COMO USAR - APENAS 2 OPÇÕES:${NC}"
    echo ""
    echo -e "${CYAN}📱 BARRIERLAYER (padrão com log):${NC}"
    echo "  barrierlayer <aplicação>              # Com logs detalhados"
    echo "  barrierlayer wine game.exe            # Wine com logs"
    echo "  bl <aplicação>                        # Atalho"
    echo ""
    echo -e "${CYAN}🔇 BARRIERLAYER_NOLOG=1 (sem logs):${NC}"
    echo "  BARRIERLAYER_NOLOG=1 barrierlayer <aplicação>    # Sem logs"
    echo "  BARRIERLAYER_NOLOG=1 barrierlayer wine game.exe  # Wine sem logs"
    echo "  BARRIERLAYER_NOLOG=1 bl <aplicação>              # Atalho sem logs"
    echo ""
    echo -e "${GREEN}🎮 EXEMPLOS PRÁTICOS:${NC}"
    echo ""
    echo -e "${CYAN}Com logs (padrão):${NC}"
    echo "  cd ~/Downloads"
    echo "  barrierlayer wine AutoClicker.exe"
    echo "  barrierlayer wine game.exe"
    echo "  barrierlayer ./meu_programa"
    echo ""
    echo -e "${CYAN}Sem logs (silencioso):${NC}"
    echo "  cd ~/Downloads"
    echo "  BARRIERLAYER_NOLOG=1 barrierlayer wine AutoClicker.exe"
    echo "  BARRIERLAYER_NOLOG=1 barrierlayer wine game.exe"
    echo "  BARRIERLAYER_NOLOG=1 barrierlayer ./meu_programa"
    echo ""
    echo -e "${GREEN}🔧 RECURSOS AUTOMÁTICOS:${NC}"
    echo "  ✅ Wine-safe mode ativado automaticamente"
    echo "  ✅ Detecção automática de arquitetura (32/64-bit)"
    echo "  ✅ Filtro de processos Wine system"
    echo "  ✅ Bypass de anti-cheat integrado"
    echo ""
    echo -e "${GREEN}📁 ARQUIVOS DE CONFIGURAÇÃO:${NC}"
    echo "  ~/.config/barrierlayer/config.conf    # Configuração principal"
    echo "  ~/BarrierLayer/files.conf             # Ocultação de arquivos"
    echo "  ~/BarrierLayer/network.conf           # Bloqueio de rede"
    echo ""
    echo -e "${GREEN}📋 LOGS (quando habilitados):${NC}"
    echo "  /var/log/barrierlayer/                # Logs do sistema"
    echo "  ~/barrierlayer_ultra_*.log            # Logs detalhados"
    echo ""
    echo -e "${YELLOW}💡 DICAS:${NC}"
    echo "  • Use BARRIERLAYER_NOLOG=1 para performance máxima"
    echo "  • Logs são úteis para debug de problemas"
    echo "  • Wine-safe mode evita problemas automaticamente"
    echo "  • Funciona com qualquer jogo/aplicação Windows"
    echo ""
    echo -e "${PURPLE}🎮 EXEMPLO COMPLETO:${NC}"
    echo "  # Baixar um jogo"
    echo "  cd ~/Downloads"
    echo "  wget https://example.com/game.exe"
    echo ""
    echo "  # Executar com logs (debug)"
    echo "  barrierlayer wine game.exe"
    echo ""
    echo "  # Executar sem logs (performance)"
    echo "  BARRIERLAYER_NOLOG=1 barrierlayer wine game.exe"
    echo ""
    echo -e "${GREEN}✨ BarrierLayer está pronto para uso! ✨${NC}"
    echo -e "${CYAN}🎯 Apenas 2 opções: com ou sem logs! 🎯${NC}"
}

# Main installation process
main() {
    echo -e "${BLUE}🚀 Iniciando instalação completa do BarrierLayer...${NC}"
    echo ""
    
    # Check if we're in the BarrierLayer directory
    if [[ ! -f "Makefile" ]] || [[ ! -d "src" ]]; then
        echo -e "${RED}❌ Execute este script no diretório do BarrierLayer!${NC}"
        echo -e "${YELLOW}💡 cd BarrierLayer && ./install.sh${NC}"
        exit 1
    fi
    
    # Installation steps
    install_dependencies
    echo ""
    
    setup_directories
    echo ""
    
    compile_barrierlayer
    echo ""
    
    install_barrierlayer
    echo ""
    
    setup_kernel_module
    echo ""
    
    create_config_files
    echo ""
    
    setup_wine
    echo ""
    
    run_tests
    echo ""
    
    show_usage
}

# Handle interruption
trap 'echo -e "\n${RED}❌ Instalação interrompida!${NC}"; exit 1' INT TERM

# Run main installation
main "$@"