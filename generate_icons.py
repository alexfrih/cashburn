#!/usr/bin/env python3
"""
Generate macOS app icons from a source image.
Requires: pip install pillow
Usage: python3 generate_icons.py source_icon.png
"""

import sys
import os
from PIL import Image

# macOS icon sizes needed
SIZES = [
    (16, "icon-16.png"),
    (32, "icon-32.png"),
    (64, "icon-64.png"),
    (128, "icon-128.png"),
    (256, "icon-256.png"),
    (512, "icon-512.png"),
    (1024, "icon-1024.png"),
    (32, "icon-32@2x.png"),   # 16x16@2x
    (256, "icon-256@2x.png"),  # 128x128@2x
    (512, "icon-512@2x.png"),  # 256x256@2x
]

def generate_icons(source_path, output_dir):
    """Generate all icon sizes from source image"""
    print(f"Loading source image: {source_path}")

    try:
        source = Image.open(source_path)
    except Exception as e:
        print(f"Error loading image: {e}")
        return False

    # Convert to RGBA if needed
    if source.mode != 'RGBA':
        source = source.convert('RGBA')

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    print(f"Generating icons in: {output_dir}")

    for size, filename in SIZES:
        output_path = os.path.join(output_dir, filename)

        # Resize with high-quality resampling
        resized = source.resize((size, size), Image.Resampling.LANCZOS)

        # Save as PNG
        resized.save(output_path, 'PNG')
        print(f"  ✓ Generated {filename} ({size}x{size})")

    print("\n✅ All icons generated successfully!")
    print(f"\nNext steps:")
    print(f"1. Open Xcode")
    print(f"2. Navigate to Cashburn/Assets.xcassets/AppIcon.appiconset/")
    print(f"3. Drag the generated icons into the AppIcon set")

    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 generate_icons.py <source_icon.png>")
        print("Example: python3 generate_icons.py cashburn_icon_1024.png")
        sys.exit(1)

    source_file = sys.argv[1]

    if not os.path.exists(source_file):
        print(f"Error: Source file '{source_file}' not found")
        sys.exit(1)

    # Output to AppIcon.appiconset directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, "Assets.xcassets", "AppIcon.appiconset")

    success = generate_icons(source_file, output_dir)
    sys.exit(0 if success else 1)
