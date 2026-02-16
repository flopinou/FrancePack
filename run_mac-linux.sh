#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_PAR="$SCRIPT_DIR/../../cities/data/PAR"
TARGET_LYS="$SCRIPT_DIR/../../cities/data/LYS"
VERSION="1.30.0"

# Copy data files for Paris
echo "[FrancePack] Copying data files for Paris (PAR)..."
mkdir -p "$TARGET_PAR"
cp -f "$SCRIPT_DIR/data/PAR/"* "$TARGET_PAR/"

# Copy data files for Lyon
echo "[FrancePack] Copying data files for Lyon (LYS)..."
mkdir -p "$TARGET_LYS"
cp -f "$SCRIPT_DIR/data/LYS/"* "$TARGET_LYS/"

echo "[FrancePack] All data files copied successfully."

# Check pmtiles binary
if [ ! -f "$SCRIPT_DIR/pmtiles" ]; then
    echo "[FrancePack] 'pmtiles' binary not found. Downloading..."
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    if [ "$OS" = "Darwin" ]; then
        if [ "$ARCH" = "arm64" ]; then
            URL="https://github.com/protomaps/go-pmtiles/releases/download/v${VERSION}/go-pmtiles-${VERSION}_Darwin_arm64.zip"
        else
            URL="https://github.com/protomaps/go-pmtiles/releases/download/v${VERSION}/go-pmtiles-${VERSION}_Darwin_x86_64.zip"
        fi
        echo "Downloading from $URL..."
        curl -L -f -o "$SCRIPT_DIR/pmtiles.zip" "$URL"
        unzip -j -o "$SCRIPT_DIR/pmtiles.zip" "pmtiles" -d "$SCRIPT_DIR"
        rm "$SCRIPT_DIR/pmtiles.zip"
        
    elif [ "$OS" = "Linux" ]; then
        if [ "$ARCH" = "aarch64" ]; then
             URL="https://github.com/protomaps/go-pmtiles/releases/download/v${VERSION}/go-pmtiles_${VERSION}_Linux_arm64.tar.gz"
        else
             URL="https://github.com/protomaps/go-pmtiles/releases/download/v${VERSION}/go-pmtiles_${VERSION}_Linux_x86_64.tar.gz"
        fi
        echo "Downloading from $URL..."
        curl -L -o "$SCRIPT_DIR/pmtiles.tar.gz" "$URL"
        tar -xzf "$SCRIPT_DIR/pmtiles.tar.gz" -C "$SCRIPT_DIR" pmtiles
        rm "$SCRIPT_DIR/pmtiles.tar.gz"
    fi
    
    if [ -f "$SCRIPT_DIR/pmtiles" ]; then
        chmod +x "$SCRIPT_DIR/pmtiles"
        echo "[FrancePack] pmtiles downloaded and executable."
    else
        echo "[FrancePack] Error: Failed to download pmtiles. Please download it manually."
        exit 1
    fi
fi

# Start tile server
echo "[FrancePack] Starting tile server on port 8080..."
"$SCRIPT_DIR/pmtiles" serve "$SCRIPT_DIR" --port 8080 --cors=*
