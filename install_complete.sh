#!/bin/bash

# BarrierLayer - Complete Installation Script
# Installs everything needed for anti-cheat bypass on Linux
# Compatible with Arch Linux, Ubuntu/Debian, and other distributions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Unicode symbols
CHECKMARK="✅"
CROSSMARK="❌"
ARROW="➤"
GEAR="⚙️"
ROCKET="🚀"
SHIELD="🛡️"
GAME="🎮"
WINE="🍷"
ARCH="🏗️"

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${WHITE}                    ${SHIELD}  BARRIERLAYER ${SHIELD}                      ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}              Complete Installation Script                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║${WHITE}  ${GAME} Anti-Cheat Bypass for Linux Gaming                      ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}  ${WINE} Wine/Proton Compatible                                   ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}  ${ARCH}  Arch Linux Ready                                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_step() {
    echo -e "${CYAN}${ARROW} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSSMARK} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Este script não deve ser executado como root!"
        echo -e "${YELLOW}💡 Execute como usuário normal. O sudo será solicitado quando necessário.${NC}"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/arch-release ]; then
        DISTRO="arch"
        DISTRO_NAME="Arch Linux"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
        DISTRO_NAME="Debian/Ubuntu"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
        DISTRO_NAME="Fedora"
    elif [ -f /etc/opensuse-release ]; then
        DISTRO="opensuse"
        DISTRO_NAME="openSUSE"
    else
        DISTRO="unknown"
        DISTRO_NAME="Unknown"
    fi
    
    print_step "Detectando distribuição Linux..."
    print_success "$DISTRO_NAME detectado"
}

# Install dependencies based on distribution
install_dependencies() {
    print_step "Instalando dependências..."
    
    case $DISTRO in
        "arch")
            print_step "Atualizando sistema Arch Linux..."
            sudo pacman -Syu --noconfirm
            
            print_step "Instalando dependências de desenvolvimento..."
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
                glibc \
                lib32-glibc
            ;;
            
        "debian")
            print_step "Atualizando sistema Debian/Ubuntu..."
            sudo apt update && sudo apt upgrade -y
            
            print_step "Instalando dependências de desenvolvimento..."
            # Get kernel version for headers
            KERNEL_VERSION=$(uname -r)
            
            sudo apt install -y \
                build-essential \
                gcc \
                gcc-multilib \
                make \
                cmake \
                git \
                linux-headers-$(uname -r) \
                libseccomp-dev \
                libseccomp2 \
                wine \
                wine64 \
                winetricks \
                libc6-dev \
                libc6-dev-i386 \
                pkg-config \
                curl \
                wget || {
                print_warning "Algumas dependências podem não estar disponíveis. Continuando..."
            }
            ;;
            
        "fedora")
            print_step "Atualizando sistema Fedora..."
            sudo dnf update -y
            
            print_step "Instalando dependências de desenvolvimento..."
            sudo dnf install -y \
                @development-tools \
                gcc \
                gcc-c++ \
                make \
                cmake \
                git \
                kernel-headers \
                kernel-devel \
                libseccomp-devel \
                wine \
                winetricks \
                glibc-devel \
                glibc-devel.i686
            ;;
            
        "opensuse")
            print_step "Atualizando sistema openSUSE..."
            sudo zypper refresh && sudo zypper update -y
            
            print_step "Instalando dependências de desenvolvimento..."
            sudo zypper install -y \
                -t pattern devel_basis \
                gcc \
                gcc-c++ \
                make \
                cmake \
                git \
                kernel-default-devel \
                libseccomp-devel \
                wine \
                glibc-devel \
                glibc-devel-32bit
            ;;
            
        *)
            print_warning "Distribuição não reconhecida. Tentando instalação genérica..."
            print_warning "Você pode precisar instalar manualmente:"
            echo "  - build-essential/development tools"
            echo "  - gcc, gcc-multilib"
            echo "  - make, cmake"
            echo "  - git"
            echo "  - linux-headers/kernel-devel"
            echo "  - libseccomp-dev/libseccomp-devel"
            echo "  - wine"
            ;;
    esac
    
    print_success "Dependências instaladas"
}

# Compile BarrierLayer
compile_barrierlayer() {
    print_step "Compilando BarrierLayer..."
    
    # Clean previous builds
    make clean > /dev/null 2>&1 || true
    
    # Compile
    if make -j$(nproc); then
        print_success "Compilação concluída com sucesso"
    else
        print_error "Falha na compilação"
        exit 1
    fi
}

# Install BarrierLayer
install_barrierlayer() {
    print_step "Instalando BarrierLayer no sistema..."
    
    # Create directories
    sudo mkdir -p /usr/local/lib/barrierlayer
    sudo mkdir -p /usr/local/bin
    sudo mkdir -p /usr/local/share/barrierlayer
    
    # Install libraries
    sudo cp bin/barrierlayer_hook64.so /usr/local/lib/barrierlayer/
    if [ -f bin/barrierlayer_hook32.so ]; then
        sudo cp bin/barrierlayer_hook32.so /usr/local/lib/barrierlayer/
    fi
    
    # Install executables
    if [ -f bin/stealth_launcher ]; then
        sudo cp bin/stealth_launcher /usr/local/bin/
    fi
    if [ -f bin/sandbox_launcher ]; then
        sudo cp bin/sandbox_launcher /usr/local/bin/
    fi
    
    # Install configuration files
    sudo cp files.conf /usr/local/share/barrierlayer/ 2>/dev/null || true
    
    print_success "BarrierLayer instalado em /usr/local/"
}

# Create usage scripts
create_usage_scripts() {
    print_step "Criando scripts de uso simplificado..."
    
    # Create main BarrierLayer script (with logging)
    cat > /tmp/barrierlayer << 'EOF'
#!/bin/bash
# BarrierLayer - Anti-Cheat Bypass (with logging)

export LD_PRELOAD="/usr/local/lib/barrierlayer/barrierlayer_hook64.so:$LD_PRELOAD"

# Enable Wine-safe mode by default
export BARRIERLAYER_WINE_SAFE=1

# Execute the command
exec "$@"
EOF

    # Create BarrierLayer script without logging
    cat > /tmp/barrierlayer-nolog << 'EOF'
#!/bin/bash
# BarrierLayer - Anti-Cheat Bypass (without logging)

export LD_PRELOAD="/usr/local/lib/barrierlayer/barrierlayer_hook64.so:$LD_PRELOAD"

# Disable logging
export BARRIERLAYER_NOLOG=1

# Enable Wine-safe mode by default
export BARRIERLAYER_WINE_SAFE=1

# Execute the command
exec "$@"
EOF

    # Install scripts
    sudo mv /tmp/barrierlayer /usr/local/bin/
    sudo mv /tmp/barrierlayer-nolog /usr/local/bin/
    sudo chmod +x /usr/local/bin/barrierlayer
    sudo chmod +x /usr/local/bin/barrierlayer-nolog
    
    print_success "Scripts de uso criados:"
    echo "  - barrierlayer (com logs)"
    echo "  - barrierlayer-nolog (sem logs)"
}

# Create desktop entries for easy access
create_desktop_entries() {
    print_step "Criando entradas do menu..."
    
    # Create desktop directory if it doesn't exist
    mkdir -p ~/.local/share/applications
    
    # BarrierLayer with logging
    cat > ~/.local/share/applications/barrierlayer.desktop << EOF
[Desktop Entry]
Name=BarrierLayer
Comment=Anti-Cheat Bypass for Linux Gaming (with logging)
Exec=barrierlayer %F
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;
MimeType=application/x-wine-extension-msp;
EOF

    # BarrierLayer without logging
    cat > ~/.local/share/applications/barrierlayer-nolog.desktop << EOF
[Desktop Entry]
Name=BarrierLayer (No Log)
Comment=Anti-Cheat Bypass for Linux Gaming (without logging)
Exec=barrierlayer-nolog %F
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;
MimeType=application/x-wine-extension-msp;
EOF

    print_success "Entradas do menu criadas"
}

# Setup Wine integration
setup_wine_integration() {
    print_step "Configurando integração com Wine..."
    
    # Create Wine wrapper script
    cat > /tmp/barrierlayer-wine << 'EOF'
#!/bin/bash
# BarrierLayer Wine Wrapper

# Set Wine-safe mode
export BARRIERLAYER_WINE_SAFE=1

# Check if no-log mode is requested
if [[ "$1" == "--nolog" ]]; then
    export BARRIERLAYER_NOLOG=1
    shift
fi

# Set LD_PRELOAD for Wine
export LD_PRELOAD="/usr/local/lib/barrierlayer/barrierlayer_hook64.so:$LD_PRELOAD"

# Execute Wine with arguments
exec wine "$@"
EOF

    sudo mv /tmp/barrierlayer-wine /usr/local/bin/
    sudo chmod +x /usr/local/bin/barrierlayer-wine
    
    print_success "Integração Wine configurada"
    echo "  Use: barrierlayer-wine [--nolog] <programa.exe>"
}

# Create uninstall script
create_uninstall_script() {
    print_step "Criando script de desinstalação..."
    
    cat > /tmp/uninstall-barrierlayer.sh << 'EOF'
#!/bin/bash
# BarrierLayer Uninstaller

echo "Removendo BarrierLayer..."

# Remove files
sudo rm -rf /usr/local/lib/barrierlayer
sudo rm -f /usr/local/bin/barrierlayer
sudo rm -f /usr/local/bin/barrierlayer-nolog
sudo rm -f /usr/local/bin/barrierlayer-wine
sudo rm -f /usr/local/bin/stealth_launcher
sudo rm -f /usr/local/bin/sandbox_launcher
sudo rm -rf /usr/local/share/barrierlayer

# Remove desktop entries
rm -f ~/.local/share/applications/barrierlayer.desktop
rm -f ~/.local/share/applications/barrierlayer-nolog.desktop

echo "BarrierLayer removido com sucesso!"
EOF

    sudo mv /tmp/uninstall-barrierlayer.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/uninstall-barrierlayer.sh
    
    print_success "Script de desinstalação criado: uninstall-barrierlayer.sh"
}

# Print usage instructions
print_usage_instructions() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}                    INSTALAÇÃO CONCLUÍDA!                    ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}${ROCKET} Como usar o BarrierLayer:${NC}"
    echo
    echo -e "${CYAN}1. Modo padrão (com logs):${NC}"
    echo -e "   ${YELLOW}barrierlayer <comando>${NC}"
    echo -e "   Exemplo: ${YELLOW}barrierlayer steam${NC}"
    echo
    echo -e "${CYAN}2. Modo sem logs:${NC}"
    echo -e "   ${YELLOW}barrierlayer-nolog <comando>${NC}"
    echo -e "   Exemplo: ${YELLOW}barrierlayer-nolog steam${NC}"
    echo
    echo -e "${CYAN}3. Para jogos Wine:${NC}"
    echo -e "   ${YELLOW}barrierlayer-wine <programa.exe>${NC}"
    echo -e "   ${YELLOW}barrierlayer-wine --nolog <programa.exe>${NC}"
    echo
    echo -e "${WHITE}${GEAR} Configurações avançadas:${NC}"
    echo -e "   ${YELLOW}BARRIERLAYER_NOLOG=1${NC}          - Desabilita logs"
    echo -e "   ${YELLOW}BARRIERLAYER_WINE_SAFE=1${NC}      - Modo Wine seguro (padrão)"
    echo -e "   ${YELLOW}BARRIERLAYER_FORCE_ALL=1${NC}      - Força hook em todos os processos"
    echo
    echo -e "${WHITE}${SHIELD} Anticheats suportados:${NC}"
    echo -e "   • EasyAntiCheat (EAC)"
    echo -e "   • BattlEye"
    echo -e "   • Vanguard (Riot)"
    echo -e "   • VAC (Steam)"
    echo -e "   • E muitos outros..."
    echo
    echo -e "${WHITE}Para desinstalar:${NC} ${YELLOW}uninstall-barrierlayer.sh${NC}"
    echo
}

# Main installation function
main() {
    print_header
    
    check_root
    detect_distro
    
    print_step "Iniciando instalação completa do BarrierLayer..."
    echo
    
    install_dependencies
    compile_barrierlayer
    install_barrierlayer
    create_usage_scripts
    create_desktop_entries
    setup_wine_integration
    create_uninstall_script
    
    print_usage_instructions
}

# Run main function
main "$@"