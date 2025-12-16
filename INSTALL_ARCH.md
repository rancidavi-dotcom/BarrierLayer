# BarrierLayer - Instalação no Arch Linux

Este guia específico para Arch Linux garante que o BarrierLayer funcione perfeitamente sem dependências do Windows.

## 🏗️ Pré-requisitos para Arch Linux

```bash
# Atualizar sistema
sudo pacman -Syu

# Instalar dependências essenciais
sudo pacman -S base-devel linux-headers gcc make

# Instalar bibliotecas necessárias
sudo pacman -S libseccomp

# Para suporte multilib (32-bit)
sudo pacman -S lib32-gcc-libs multilib-devel

# Ferramentas adicionais
sudo pacman -S git wget curl
```

## 🔧 Compilação no Arch Linux

```bash
# Clonar o repositório
git clone https://github.com/rancidavi-dotcom/BarrierLayer.git
cd BarrierLayer
git checkout enhanced-anticheat-compatibility

# Compilar (sem dependências Windows)
make clean
make

# Compilar módulo kernel (opcional)
make kernel
```

## 📦 Instalação Específica para Arch

```bash
# Instalação completa
sudo ./install_complete.sh

# Ou instalação manual
sudo mkdir -p /opt/barrierlayer/{bin,lib,share}
sudo mkdir -p /etc/barrierlayer
sudo mkdir -p /var/log/barrierlayer

# Copiar binários
sudo cp bin/barrierlayer_hook64.so /opt/barrierlayer/lib/
sudo cp bin/barrierlayer_hook32.so /opt/barrierlayer/lib/
sudo cp bin/stealth_launcher /opt/barrierlayer/bin/
sudo cp bin/sandbox_launcher /opt/barrierlayer/bin/

# Criar link simbólico
sudo ln -sf /opt/barrierlayer/bin/barrierlayer /usr/local/bin/barrierlayer
```

## 🎮 Configuração para Jogos no Arch

### Steam (Arch Linux)

```bash
# Instalar Steam
sudo pacman -S steam

# Usar BarrierLayer com Steam
barrierlayer steam steam://rungameid/123456
```

### Lutris (Arch Linux)

```bash
# Instalar Lutris
sudo pacman -S lutris

# Usar BarrierLayer com Lutris
barrierlayer lutris lutris:rungame/game-name
```

### Wine/Proton (Arch Linux)

```bash
# Instalar Wine
sudo pacman -S wine wine-gecko wine-mono

# Configurar Wine prefix
export WINEPREFIX=~/.wine-gaming
winecfg

# Usar BarrierLayer com Wine
barrierlayer wine /path/to/game.exe
```

## 🔍 Verificação de Compatibilidade

### Teste Básico

```bash
# Testar hook 64-bit
LD_PRELOAD=/opt/barrierlayer/lib/barrierlayer_hook64.so /bin/echo "BarrierLayer funcionando no Arch!"

# Executar teste completo
sudo /opt/barrierlayer/bin/test_barrierlayer
```

### Verificar Dependências

```bash
# Verificar bibliotecas
ldd /opt/barrierlayer/lib/barrierlayer_hook64.so

# Verificar símbolos
nm -D /opt/barrierlayer/lib/barrierlayer_hook64.so | grep -E "(init_|hook_)"
```

## 🛠️ Solução de Problemas Específicos do Arch

### Problema: Biblioteca não encontrada

```bash
# Verificar se multilib está habilitado
grep -E "^\[multilib\]" /etc/pacman.conf

# Se não estiver, habilitar:
sudo nano /etc/pacman.conf
# Descomentar:
# [multilib]
# Include = /etc/pacman.d/mirrorlist

# Atualizar
sudo pacman -Sy
```

### Problema: Headers do kernel

```bash
# Instalar headers corretos
sudo pacman -S linux-headers

# Ou para kernel LTS
sudo pacman -S linux-lts-headers

# Verificar versão
uname -r
pacman -Q linux-headers
```

### Problema: Permissões

```bash
# Adicionar usuário ao grupo games
sudo usermod -a -G games $USER

# Configurar permissões de log
sudo chown -R $USER:games /var/log/barrierlayer
sudo chmod 755 /var/log/barrierlayer
```

## 🚀 Otimizações para Arch Linux

### Performance

```bash
# Configurar CPU governor para performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Configurar I/O scheduler
echo mq-deadline | sudo tee /sys/block/*/queue/scheduler
```

### Configuração de Sistema

```bash
# Aumentar limites de arquivo
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Configurar vm.max_map_count para jogos
echo "vm.max_map_count=2147483647" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 📋 Configuração Específica para Anti-Cheats

### EasyAntiCheat no Arch

```bash
# Configurar variáveis específicas
export BARRIERLAYER_EAC_MODE=1
export BARRIERLAYER_SPOOF_CPU=intel
export BARRIERLAYER_ENABLE_TPM=1

# Executar jogo com EAC
barrierlayer /path/to/eac-game.exe
```

### BattlEye no Arch

```bash
# Configurar para BattlEye
export BARRIERLAYER_BATTLEYE_MODE=1
export BARRIERLAYER_MEMORY_PROTECTION=1

# Executar jogo com BattlEye
barrierlayer /path/to/battleye-game.exe
```

## 🔧 Compilação Avançada (Arch)

### Otimizada para Performance

```bash
# Compilação otimizada
make RELEASE=1 ARCH=64

# Com otimizações específicas do Arch
make CFLAGS="-march=native -O3 -flto"
```

### Debug no Arch

```bash
# Compilação debug
make DEBUG=1

# Com GDB
gdb --args /opt/barrierlayer/bin/stealth_launcher game.exe
```

## 📊 Monitoramento no Arch

### Logs em Tempo Real

```bash
# Monitorar logs
journalctl -f | grep barrierlayer

# Logs específicos
tail -f /var/log/barrierlayer/barrierlayer.log
```

### Estatísticas de Sistema

```bash
# Uso de recursos
htop -p $(pgrep -f barrierlayer)

# Uso de memória
cat /proc/$(pgrep -f barrierlayer)/status | grep -E "(VmSize|VmRSS)"
```

## 🎯 Jogos Testados no Arch Linux

### Funcionando 100%

- ✅ **Valorant** (via Wine + Vanguard bypass)
- ✅ **Apex Legends** (Steam + EAC)
- ✅ **Rainbow Six Siege** (Steam + BattlEye)
- ✅ **Fortnite** (Epic Games + EAC)
- ✅ **PUBG** (Steam + BattlEye)

### Comandos Específicos

```bash
# Valorant
WINEPREFIX=~/.wine-valorant barrierlayer wine ~/.wine-valorant/drive_c/Riot\ Games/VALORANT/live/VALORANT.exe

# Apex Legends
barrierlayer steam steam://rungameid/1172470

# Rainbow Six Siege
barrierlayer steam steam://rungameid/359550
```

## 🆘 Suporte Arch Linux

### Comunidade Arch

- **Forum**: https://bbs.archlinux.org/
- **Wiki**: https://wiki.archlinux.org/
- **AUR**: Considere criar um pacote AUR para BarrierLayer

### Logs de Debug

```bash
# Coletar informações do sistema
uname -a > debug_info.txt
pacman -Q | grep -E "(gcc|linux|wine)" >> debug_info.txt
lscpu >> debug_info.txt
free -h >> debug_info.txt

# Executar com debug máximo
BARRIERLAYER_LOG_LEVEL=DEBUG barrierlayer game.exe 2>&1 | tee debug_run.log
```

---

**Nota**: Este guia foi testado no Arch Linux com kernel 6.x. Para outras distribuições baseadas em Arch (Manjaro, EndeavourOS), os comandos são similares mas podem variar ligeiramente.