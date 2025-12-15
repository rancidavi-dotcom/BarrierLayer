#!/bin/bash

# BarrierLayer - Verificação de Compatibilidade Arch Linux
# Este script verifica se o sistema Arch Linux está pronto para o BarrierLayer

set -e

echo "=== BarrierLayer - Verificação de Compatibilidade Arch Linux ==="
echo

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir status
print_status() {
    local status=$1
    local message=$2
    
    if [[ $status == "OK" ]]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [[ $status == "WARNING" ]]; then
        echo -e "${YELLOW}⚠${NC} $message"
    elif [[ $status == "ERROR" ]]; then
        echo -e "${RED}✗${NC} $message"
    else
        echo -e "${BLUE}ℹ${NC} $message"
    fi
}

# Verificar se é Arch Linux
echo "=== Verificação do Sistema ==="
if [[ -f /etc/arch-release ]]; then
    print_status "OK" "Sistema Arch Linux detectado"
    ARCH_VERSION=$(cat /etc/arch-release)
    print_status "INFO" "Versão: $ARCH_VERSION"
else
    print_status "WARNING" "Sistema não é Arch Linux puro, mas pode ser compatível"
fi

# Verificar kernel
KERNEL_VERSION=$(uname -r)
print_status "INFO" "Kernel: $KERNEL_VERSION"

# Verificar arquitetura
ARCH=$(uname -m)
if [[ $ARCH == "x86_64" ]]; then
    print_status "OK" "Arquitetura x86_64 suportada"
else
    print_status "ERROR" "Arquitetura $ARCH não suportada"
fi

echo
echo "=== Verificação de Dependências ==="

# Verificar pacman
if command -v pacman &> /dev/null; then
    print_status "OK" "Pacman encontrado"
else
    print_status "ERROR" "Pacman não encontrado - não é um sistema Arch"
    exit 1
fi

# Verificar base-devel
if pacman -Qq base-devel &> /dev/null; then
    print_status "OK" "base-devel instalado"
else
    print_status "ERROR" "base-devel não instalado"
    echo "  Execute: sudo pacman -S base-devel"
fi

# Verificar GCC
if command -v gcc &> /dev/null; then
    GCC_VERSION=$(gcc --version | head -n1)
    print_status "OK" "GCC encontrado: $GCC_VERSION"
else
    print_status "ERROR" "GCC não encontrado"
    echo "  Execute: sudo pacman -S gcc"
fi

# Verificar make
if command -v make &> /dev/null; then
    MAKE_VERSION=$(make --version | head -n1)
    print_status "OK" "Make encontrado: $MAKE_VERSION"
else
    print_status "ERROR" "Make não encontrado"
    echo "  Execute: sudo pacman -S make"
fi

# Verificar headers do kernel
if [[ -d "/usr/lib/modules/$KERNEL_VERSION/build" ]]; then
    print_status "OK" "Headers do kernel encontrados"
else
    print_status "ERROR" "Headers do kernel não encontrados"
    echo "  Execute: sudo pacman -S linux-headers"
fi

# Verificar libseccomp
if pacman -Qq libseccomp &> /dev/null; then
    print_status "OK" "libseccomp instalada"
else
    print_status "ERROR" "libseccomp não instalada"
    echo "  Execute: sudo pacman -S libseccomp"
fi

# Verificar multilib
echo
echo "=== Verificação Multilib (32-bit) ==="
if grep -q "^\[multilib\]" /etc/pacman.conf; then
    print_status "OK" "Repositório multilib habilitado"
    
    if pacman -Qq lib32-gcc-libs &> /dev/null; then
        print_status "OK" "lib32-gcc-libs instalado"
    else
        print_status "WARNING" "lib32-gcc-libs não instalado"
        echo "  Execute: sudo pacman -S lib32-gcc-libs"
    fi
else
    print_status "WARNING" "Repositório multilib não habilitado"
    echo "  Para habilitar, edite /etc/pacman.conf e descomente [multilib]"
fi

echo
echo "=== Verificação de Ferramentas de Gaming ==="

# Verificar Steam
if pacman -Qq steam &> /dev/null; then
    print_status "OK" "Steam instalado"
else
    print_status "INFO" "Steam não instalado (opcional)"
    echo "  Para instalar: sudo pacman -S steam"
fi

# Verificar Wine
if command -v wine &> /dev/null; then
    WINE_VERSION=$(wine --version)
    print_status "OK" "Wine encontrado: $WINE_VERSION"
else
    print_status "INFO" "Wine não instalado (opcional)"
    echo "  Para instalar: sudo pacman -S wine"
fi

# Verificar Lutris
if pacman -Qq lutris &> /dev/null; then
    print_status "OK" "Lutris instalado"
else
    print_status "INFO" "Lutris não instalado (opcional)"
    echo "  Para instalar: sudo pacman -S lutris"
fi

echo
echo "=== Verificação de Sistema ==="

# Verificar espaço em disco
DISK_SPACE=$(df -h / | awk 'NR==2 {print $4}')
print_status "INFO" "Espaço livre: $DISK_SPACE"

# Verificar memória
MEMORY=$(free -h | awk 'NR==2 {print $2}')
print_status "INFO" "Memória total: $MEMORY"

# Verificar CPU
CPU_INFO=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
print_status "INFO" "CPU: $CPU_INFO"

echo
echo "=== Verificação de Configurações ==="

# Verificar vm.max_map_count
MAX_MAP_COUNT=$(cat /proc/sys/vm/max_map_count)
if [[ $MAX_MAP_COUNT -ge 1048576 ]]; then
    print_status "OK" "vm.max_map_count configurado corretamente: $MAX_MAP_COUNT"
else
    print_status "WARNING" "vm.max_map_count muito baixo: $MAX_MAP_COUNT"
    echo "  Execute: echo 'vm.max_map_count=2147483647' | sudo tee -a /etc/sysctl.conf"
fi

# Verificar ulimit
ULIMIT_N=$(ulimit -n)
if [[ $ULIMIT_N -ge 65536 ]]; then
    print_status "OK" "ulimit -n configurado corretamente: $ULIMIT_N"
else
    print_status "WARNING" "ulimit -n muito baixo: $ULIMIT_N"
    echo "  Configure em /etc/security/limits.conf"
fi

echo
echo "=== Teste de Compilação ==="

# Criar arquivo de teste
TEST_FILE="/tmp/barrierlayer_test.c"
cat > "$TEST_FILE" << 'EOF'
#include <stdio.h>
#include <stdint.h>
#include <dlfcn.h>
#include <unistd.h>

int main() {
    printf("Teste de compilação BarrierLayer OK\n");
    return 0;
}
EOF

# Tentar compilar
if gcc -o /tmp/barrierlayer_test "$TEST_FILE" -ldl 2>/dev/null; then
    print_status "OK" "Teste de compilação bem-sucedido"
    /tmp/barrierlayer_test
    rm -f /tmp/barrierlayer_test "$TEST_FILE"
else
    print_status "ERROR" "Teste de compilação falhou"
    echo "  Verifique se todas as dependências estão instaladas"
fi

echo
echo "=== Resumo ==="

# Contar problemas
ERRORS=$(grep -c "✗" /tmp/barrierlayer_check.log 2>/dev/null || echo "0")
WARNINGS=$(grep -c "⚠" /tmp/barrierlayer_check.log 2>/dev/null || echo "0")

if [[ $ERRORS -eq 0 ]]; then
    if [[ $WARNINGS -eq 0 ]]; then
        print_status "OK" "Sistema totalmente compatível com BarrierLayer!"
        echo "  Você pode prosseguir com a compilação e instalação."
    else
        print_status "WARNING" "Sistema compatível com $WARNINGS avisos"
        echo "  Você pode prosseguir, mas considere resolver os avisos."
    fi
else
    print_status "ERROR" "Sistema tem $ERRORS erros que precisam ser corrigidos"
    echo "  Corrija os erros antes de prosseguir."
fi

echo
echo "=== Próximos Passos ==="
echo "1. Corrija quaisquer erros listados acima"
echo "2. Clone o repositório: git clone https://github.com/rancidavi-dotcom/BarrierLayer.git"
echo "3. Entre no diretório: cd BarrierLayer"
echo "4. Mude para o branch: git checkout enhanced-anticheat-compatibility"
echo "5. Compile: make"
echo "6. Instale: sudo ./install_complete.sh"
echo "7. Teste: sudo /opt/barrierlayer/bin/test_barrierlayer"
echo

# Salvar log
exec > >(tee /tmp/barrierlayer_check.log)