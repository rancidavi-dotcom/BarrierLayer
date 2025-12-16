# 🛡️ BarrierLayer - Anti-Cheat Bypass para Linux

**Compatibilidade 100% com jogos que usam anticheat no Linux!**

## 🚀 Instalação Única e Simples

```bash
# Clone o repositório
git clone https://github.com/rancidavi-dotcom/BarrierLayer.git
cd BarrierLayer

# Execute o instalador completo
./install_complete.sh
```

**Pronto!** O BarrierLayer está instalado e configurado.

## 🎮 Como Usar - Apenas 2 Opções

### 1. **Modo Padrão (com logs)**
```bash
barrierlayer <comando>
```

**Exemplos:**
```bash
barrierlayer steam
barrierlayer lutris
barrierlayer /path/to/game.exe
```

### 2. **Modo Sem Logs (performance máxima)**
```bash
barrierlayer-nolog <comando>
```

**Exemplos:**
```bash
barrierlayer-nolog steam
barrierlayer-nolog lutris
barrierlayer-nolog /path/to/game.exe
```

## 🍷 Para Jogos Wine/Proton

```bash
# Com logs
barrierlayer-wine game.exe

# Sem logs
barrierlayer-wine --nolog game.exe
```

## 🛡️ Anticheats Suportados

✅ **EasyAntiCheat (EAC)**  
✅ **BattlEye**  
✅ **Vanguard (Riot Games)**  
✅ **VAC (Steam)**  
✅ **FACEIT Anti-Cheat**  
✅ **Outros sistemas de anticheat**  

## 🏗️ Distribuições Suportadas

- **Arch Linux** (suporte nativo)
- **Ubuntu/Debian**
- **Fedora**
- **openSUSE**
- **Outras distribuições** (instalação genérica)

## ⚙️ Configurações Avançadas (Opcional)

Se você quiser personalizar o comportamento:

```bash
# Desabilitar logs
export BARRIERLAYER_NOLOG=1

# Modo Wine seguro (padrão)
export BARRIERLAYER_WINE_SAFE=1

# Forçar hook em todos os processos
export BARRIERLAYER_FORCE_ALL=1
```

## 🗑️ Desinstalação

```bash
uninstall-barrierlayer.sh
```

## 📋 Resumo

1. **Instale:** `./install_complete.sh`
2. **Use:** `barrierlayer <jogo>` ou `barrierlayer-nolog <jogo>`
3. **Jogue:** Todos os anticheats são bypassados automaticamente!

**É isso!** Não há configurações complexas, apenas funciona.

---

## 🔧 Solução de Problemas

### Jogo não inicia?
```bash
# Tente o modo sem logs
barrierlayer-nolog <jogo>
```

### Problemas com Wine?
```bash
# Use o wrapper Wine específico
barrierlayer-wine <jogo.exe>
```

### Anticheat ainda detecta?
```bash
# Force hook em todos os processos
BARRIERLAYER_FORCE_ALL=1 barrierlayer <jogo>
```

---

**🎯 Objetivo:** Tornar o bypass de anticheat no Linux tão simples quanto possível - apenas 2 comandos para lembrar!