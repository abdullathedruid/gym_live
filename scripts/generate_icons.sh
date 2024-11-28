#!/bin/bash

# Create icons directory if it doesn't exist
mkdir -p priv/static/images/icons

# Array of required sizes for PWA icons
sizes=(72 96 128 144 152 192 384 512)

# Generate PWA icons for each size
for size in "${sizes[@]}"; do
  magick priv/static/images/logo.svg -resize ${size}x${size} priv/static/images/icons/icon-${size}x${size}.png
done

# Generate favicon.ico (16x16 and 32x32 combined)
magick priv/static/images/logo.svg -define icon:auto-resize=16,32 priv/static/favicon.ico

# Generate favicon.png (32x32 for modern browsers)
magick priv/static/images/logo.svg -resize 32x32 priv/static/favicon.png 