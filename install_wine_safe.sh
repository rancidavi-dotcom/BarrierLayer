#!/bin/bash
# BarrierLayer Wine-Safe Installation Script

set -e

echo "🍷 Installing BarrierLayer with Wine-Safe Mode..."

# Install main BarrierLayer
sudo make install

# Install Wine-safe wrapper
echo "📦 Installing Wine-safe wrapper..."
sudo cp barrierlayer-wine /usr/local/bin/
sudo chmod +x /usr/local/bin/barrierlayer-wine

# Create symlink for easy access
sudo ln -sf /usr/local/bin/barrierlayer-wine /usr/local/bin/barrierlayer-wine-safe

echo "✅ Installation complete!"
echo ""
echo "🎯 Usage:"
echo "  For regular applications: barrierlayer <app>"
echo "  For Wine applications:    barrierlayer-wine wine <app.exe>"
echo "  Wine-safe mode:          barrierlayer-wine-safe wine <app.exe>"
echo ""
echo "🔧 Environment Variables:"
echo "  BARRIERLAYER_WINE_SAFE=1     - Enable Wine-safe mode (default in wine wrappers)"
echo "  BARRIERLAYER_FORCE_ALL=1     - Force hook all processes (override Wine-safe)"
echo "  BARRIERLAYER_LOG_LEVEL=DEBUG - Enable debug logging"
echo ""
echo "🎮 Example:"
echo "  cd ~/Downloads"
echo "  barrierlayer-wine wine AutoClicker.exe"