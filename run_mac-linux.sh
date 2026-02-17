#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="1.30.0"

CITIES=("PAR" "LYS" "MRS" "LIL" "TLS" "RNS")

# Copy city data files
for CODE in "${CITIES[@]}"; do
    TARGET="$SCRIPT_DIR/../../cities/data/$CODE"
    SOURCE="$SCRIPT_DIR/data/$CODE"
    
    if [ -d "$SOURCE" ]; then
        echo "[FrancePack] Copying data files for $CODE..."
        mkdir -p "$TARGET"
        cp -f "$SOURCE/"* "$TARGET/"
    else
        echo "[FrancePack] Warning: Source directory for $CODE not found."
    fi
done

echo "[FrancePack] All data files copied successfully."

# Check for pmtiles binary and download if missing
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
        EXTENSION="zip"
        
    elif [ "$OS" = "Linux" ]; then
        if [ "$ARCH" = "aarch64" ]; then
             URL="https://github.com/protomaps/go-pmtiles/releases/download/v${VERSION}/go-pmtiles_${VERSION}_Linux_arm64.tar.gz"
        else
             URL="https://github.com/protomaps/go-pmtiles/releases/download/v${VERSION}/go-pmtiles_${VERSION}_Linux_x86_64.tar.gz"
        fi
        EXTENSION="tar.gz"
    fi
    
    echo "Downloading from $URL..."
    
    if [ "$EXTENSION" = "zip" ]; then
        curl -L -f -o "$SCRIPT_DIR/pmtiles.zip" "$URL"
        unzip -j -o "$SCRIPT_DIR/pmtiles.zip" "pmtiles" -d "$SCRIPT_DIR"
        rm "$SCRIPT_DIR/pmtiles.zip"
    else
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
echo "[FrancePack] Keep this window open while playing!"
"$SCRIPT_DIR/pmtiles" serve "$SCRIPT_DIR" --port 8080 --cors=*