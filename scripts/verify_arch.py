#!/usr/bin/env python3
"""验证打包目录中的 PE / ELF 架构，防止跨架构混装。"""
import argparse
from pathlib import Path
import struct


def architecture(path):
    with path.open('rb') as handle:
        header = handle.read(64)
        if header[:2] == b'MZ':
            handle.seek(struct.unpack_from('<I', header, 60)[0])
            signature = handle.read(6)
            if signature[:4] != b'PE\0\0':
                raise ValueError(f'PE 头损坏：{path}')
            return {0x8664: 'x64', 0xAA64: 'arm64'}.get(struct.unpack_from('<H', signature, 4)[0], 'unknown')
        if header[:4] == b'\x7fELF':
            endian = '<' if header[5] == 1 else '>'
            return {62: 'x64', 183: 'arm64', 40: 'armv7'}.get(struct.unpack_from(endian + 'H', header, 18)[0], 'unknown')
    return None


def verify(folder, expected):
    count = 0
    for path in folder.rglob('*'):
        if not path.is_file():
            continue
        found = architecture(path)
        if found is None:
            continue
        if found != expected:
            raise ValueError(f'架构不符：{path} = {found}，需要 {expected}')
        count += 1
    if count == 0:
        raise ValueError('包中没有可验证的二进制文件')
    return count


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('folder', type=Path)
    parser.add_argument('arch', choices=['x64', 'arm64', 'armv7'])
    args = parser.parse_args()
    print(f'{verify(args.folder, args.arch)} 个二进制通过 {args.arch} 检查')
