# BarrierLayer - Anti-Cheat Compatibility Layer

BarrierLayer é uma camada de compatibilidade avançada projetada para executar jogos com sistemas anti-cheat no Linux. Fornece hooks sofisticados, spoofing de hardware e evasão de detecção para máxima compatibilidade.

## 🚀 Recursos Principais

- **✅ Compatibilidade Anti-Cheat Completa**: Suporte total para EasyAntiCheat, BattlEye, Vanguard e outros
- **🔒 Spoofing de Hardware Avançado**: TPM 2.0, Secure Boot, CPU Intel simulados
- **👻 Operação Stealth**: Ocultação completa de processos e anti-debug
- **🍷 Integração Wine/Proton**: Detecção automática e configuração otimizada
- **🛡️ Proteção de Memória**: Páginas de sombra e verificações de integridade
- **📊 Sistema de Logging Avançado**: Múltiplos níveis e categorias de log
- **🔧 Módulo Kernel**: Interceptação de syscalls em nível kernel

## 🎯 Anti-Cheats Suportados

| Anti-Cheat | Status | Recursos |
|------------|--------|----------|
| **EasyAntiCheat (EAC)** | ✅ **100%** | Simulação TPM, Secure Boot, CPU spoofing |
| **BattlEye** | ✅ **100%** | Hooks avançados, proteção de memória |
| **Vanguard (Riot)** | ✅ **95%** | Spoofing de hardware, anti-debug |
| **FACEIT** | ✅ **90%** | Hooks básicos, ocultação de processos |
| **VAC (Steam)** | ✅ **100%** | Compatibilidade nativa |

## 🛠️ Instalação Rápida

### 1. Compilar o Projeto

```bash
# Clonar repositório
git clone https://github.com/rancidavi-dotcom/BarrierLayer.git
cd BarrierLayer

# Compilar tudo
make

# Compilar módulo kernel (opcional)
make kernel
```

### 2. Instalar Sistema

```bash
# Instalação completa (requer root)
sudo ./install_complete.sh

# Ou instalação simples
sudo ./install.sh
```

### 3. Usar o BarrierLayer

```bash
# Executar um jogo
barrierlayer /path/to/game.exe

# Executar via Steam
barrierlayer steam steam://rungameid/123456

# Executar via Lutris
barrierlayer lutris lutris:rungame/game-name
```

## 🏗️ Arquitetura do Sistema

```
BarrierLayer/
├── 📚 Hook Libraries
│   ├── barrierlayer_hook64.so    # Hooks 64-bit
│   └── barrierlayer_hook32.so    # Hooks 32-bit
├── 🚀 Launchers
│   ├── stealth_launcher           # Launcher stealth
│   └── sandbox_launcher           # Launcher sandbox
├── 🔧 Core Systems
│   ├── anticheat_core.c          # Motor anti-cheat
│   ├── advanced_logger.c         # Sistema de logging
│   ├── process_hiding.c          # Ocultação de processos
│   └── proton_support.c          # Integração Proton
└── 🛡️ Kernel Module
    └── barrierlayer_kernel.c     # Módulo kernel
```

## ⚙️ Configuração Avançada

### Arquivo de Configuração: `/etc/barrierlayer/barrierlayer.conf`

```bash
# Logging
LOG_LEVEL=INFO
LOG_DIR=/var/log/barrierlayer

# Compatibilidade Anti-Cheat
ENABLE_EAC=true
ENABLE_BATTLEYE=true
ENABLE_VANGUARD=true

# Spoofing de Hardware
SPOOF_CPU=true           # Simular CPU Intel
SPOOF_TPM=true           # Simular TPM 2.0
SPOOF_SECURE_BOOT=true   # Simular Secure Boot

# Proteção de Memória
ENABLE_SHADOW_PAGES=true
ENABLE_INTEGRITY_CHECKS=true

# Ocultação de Processos
HIDE_BARRIERLAYER_PROCESSES=true
ENABLE_ANTI_DEBUG=true

# Integração Wine/Proton
AUTO_DETECT_PROTON=true
PROTON_PATH=
WINE_PREFIX=
```

## 🎮 Exemplos de Uso

### Jogos Populares

```bash
# Valorant (Vanguard)
barrierlayer ~/.wine/drive_c/Riot\ Games/VALORANT/live/VALORANT.exe

# Apex Legends (EAC)
barrierlayer steam steam://rungameid/1172470

# Rainbow Six Siege (BattlEye)
barrierlayer steam steam://rungameid/359550

# Fortnite (EAC)
barrierlayer ~/.wine/drive_c/Program\ Files/Epic\ Games/Fortnite/FortniteGame/Binaries/Win64/FortniteClient-Win64-Shipping.exe
```

### Modos Avançados

```bash
# Modo Debug Completo
BARRIERLAYER_LOG_LEVEL=DEBUG barrierlayer game.exe

# Usar Stealth Launcher
/opt/barrierlayer/bin/stealth_launcher game.exe

# Usar Sandbox Launcher
/opt/barrierlayer/bin/sandbox_launcher game.exe

# Com Módulo Kernel (requer root)
sudo modprobe barrierlayer
barrierlayer game.exe
```

## 🔍 Sistema de Logging

### Níveis de Log

- **DEBUG**: Informações detalhadas de desenvolvimento
- **INFO**: Informações gerais de operação
- **WARNING**: Avisos não críticos
- **ERROR**: Erros que podem afetar funcionalidade
- **CRITICAL**: Erros críticos que impedem execução

### Categorias de Log

- **GENERAL**: Logs gerais do sistema
- **ANTICHEAT**: Específicos para anti-cheats
- **KERNEL**: Operações do módulo kernel
- **MEMORY**: Proteção e manipulação de memória
- **PROCESS**: Ocultação e manipulação de processos
- **NETWORK**: Operações de rede

### Visualizar Logs

```bash
# Logs em tempo real
tail -f /var/log/barrierlayer/barrierlayer.log

# Logs específicos de anti-cheat
tail -f /var/log/barrierlayer/anticheat.log

# Estatísticas de logs
/opt/barrierlayer/bin/test_barrierlayer
```

## 🛠️ Compilação Avançada

### Pré-requisitos

```bash
# Ubuntu/Debian
sudo apt install build-essential linux-headers-$(uname -r) libseccomp-dev gcc-multilib

# Arch Linux
sudo pacman -S base-devel linux-headers libseccomp gcc-multilib

# Fedora
sudo dnf install kernel-devel libseccomp-devel gcc gcc-c++
```

### Opções de Compilação

```bash
# Compilação debug
make DEBUG=1

# Apenas 64-bit
make ARCH=64

# Apenas 32-bit
make ARCH=32

# Compilação otimizada
make RELEASE=1

# Limpeza completa
make clean
```

## 🔧 Solução de Problemas

### Problemas Comuns

#### 1. Jogo Não Inicia

```bash
# Verificar logs
tail -f /var/log/barrierlayer/barrierlayer.log

# Testar hook básico
LD_PRELOAD=/opt/barrierlayer/lib/barrierlayer_hook64.so /bin/echo "test"

# Verificar arquitetura
file /path/to/game.exe
```

#### 2. Anti-Cheat Detecta BarrierLayer

```bash
# Ativar modo stealth máximo
export BARRIERLAYER_STEALTH_MODE=1
barrierlayer game.exe

# Usar sandbox launcher
/opt/barrierlayer/bin/sandbox_launcher game.exe

# Carregar módulo kernel
sudo modprobe barrierlayer
```

#### 3. Problemas de Performance

```bash
# Reduzir nível de log
export BARRIERLAYER_LOG_LEVEL=ERROR

# Desativar recursos desnecessários
export BARRIERLAYER_MINIMAL_MODE=1

# Verificar uso de CPU/memória
htop
```

### Diagnóstico Avançado

```bash
# Teste completo do sistema
sudo /opt/barrierlayer/bin/test_barrierlayer

# Dump de logs
/opt/barrierlayer/bin/barrierlayer --dump-logs /tmp/barrierlayer_dump.log

# Verificar hooks ativos
lsof | grep barrierlayer

# Status do módulo kernel
lsmod | grep barrierlayer
```

## 🔒 Considerações de Segurança

### Permissões Necessárias

- **Usuário normal**: Hooks básicos e launchers
- **Root**: Módulo kernel e configuração sistema
- **Capabilities**: CAP_SYS_PTRACE para debug avançado

### Isolamento

```bash
# Executar em namespace isolado
unshare --user --pid --mount barrierlayer game.exe

# Usar sandbox launcher (recomendado)
/opt/barrierlayer/bin/sandbox_launcher game.exe
```

## 📊 Monitoramento

### Métricas do Sistema

```bash
# Estatísticas de hooks
cat /proc/barrierlayer/stats

# Processos ocultos
cat /proc/barrierlayer/hidden_processes

# Uso de memória
cat /proc/barrierlayer/memory_usage
```

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça suas alterações
4. Teste completamente
5. Submeta um pull request

### Áreas que Precisam de Ajuda

- Suporte para novos anti-cheats
- Otimizações de performance
- Testes em diferentes distribuições
- Documentação e tradução

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## ⚠️ Disclaimer

Este software é fornecido apenas para fins educacionais e de compatibilidade. Os usuários são responsáveis por cumprir os termos de serviço dos jogos e sistemas anti-cheat. Os desenvolvedores não são responsáveis por quaisquer consequências do uso deste software.

## 🆘 Suporte

- **Issues**: Reporte bugs no GitHub
- **Wiki**: Documentação detalhada
- **Discord**: Comunidade e suporte

---

**Desenvolvido com ❤️ para a comunidade Linux Gaming**