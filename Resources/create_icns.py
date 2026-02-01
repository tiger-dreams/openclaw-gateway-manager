#!/usr/bin/env python3
import struct
import sys

def create_icns():
    # macOS.icns file structure
    # Resources
    # PNG data
    # Resource directory

    # Simple icns creation
    print("Creating icns file...")
    with open('AppIcon.icns', 'wb') as f:
        # Header: "icns" magic + size (64-bit)
        f.write(b'icns')
        f.write(struct.pack('>Q', 0))  # Size placeholder

        # Create resource directory
        entries = [
            (b'ic04', 1024, '1024.png'),
            (b'ic09', 512, '512.png'),
            (b'ic10', 256, '256.png'),
            (b'ic11', 128, '128.png'),
            (b'ic12', 64, '64.png'),
            (b'ic13', 32, '32.png'),
            (b'ic14', 16, '16.png'),
        ]

        offsets = []
        for name, size, filename in entries:
            with open(filename, 'rb') as img:
                data = img.read()
                # Write data
                offset = 8 + sum(len(e[2].encode()) + 12 for e in offsets)
                offsets.append((name, size, filename, offset, len(data)))
                f.write(data)

        # Write resource directory
        f.write(b'icns')
        f.write(struct.pack('>Q', 8 + sum(len(e[2].encode()) + 12 for e in offsets)))
        for name, size, filename, offset, length in offsets:
            f.write(name)
            f.write(struct.pack('>IIII', size, length, 0, offset))

    print("icns file created successfully!")

if __name__ == '__main__':
    create_icns()
