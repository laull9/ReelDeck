import io
from pathlib import Path
import struct
import sys
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from ci_version import resolve_version
from verify_arch import verify
from package_android import validate_apk
from generate_icons import same_image
from PIL import Image


def elf(machine):
    header = bytearray(64)
    header[:6] = b'\x7fELF\x02\x01'
    struct.pack_into('<H', header, 18, machine)
    return bytes(header)


def pe(machine):
    header = bytearray(128)
    header[:2] = b'MZ'
    struct.pack_into('<I', header, 60, 64)
    header[64:68] = b'PE\0\0'
    struct.pack_into('<H', header, 68, machine)
    return bytes(header)


class BuildValidationTest(unittest.TestCase):
    def test_png_compression_differences_preserve_pixels(self):
        image = Image.new('RGBA', (32, 32), (10, 200, 140, 255))
        first, second = io.BytesIO(), io.BytesIO()
        image.save(first, format='PNG', compress_level=0)
        image.save(second, format='PNG', compress_level=9)
        self.assertNotEqual(first.getvalue(), second.getvalue())
        self.assertTrue(same_image('icon.png', first.getvalue(), second.getvalue()))
        image.putpixel((10, 10), (255, 0, 0, 255))
        changed = io.BytesIO()
        image.save(changed, format='PNG')
        self.assertFalse(same_image('icon.png', first.getvalue(), changed.getvalue()))

    def test_release_cannot_use_wrong_or_missing_tag(self):
        self.assertEqual(resolve_version('version: 0.3.0+3\n', 'refs/tags/v0.3.0', '', True), ('0.3.0', 'v0.3.0'))
        for tag in ['', 'v0.2.0', 'v0.3.0\nmalicious=tag']:
            with self.assertRaises(ValueError):
                resolve_version('version: 0.3.0+3\n', 'refs/heads/main', tag, True)

    def test_mixed_windows_dll_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'app.exe').write_bytes(pe(0xAA64))
            (folder / 'libmpv.dll').write_bytes(pe(0xAA64))
            self.assertEqual(verify(folder, 'arm64'), 2)
            (folder / 'angle.dll').write_bytes(pe(0x8664))
            with self.assertRaises(ValueError):
                verify(folder, 'arm64')

    def test_elf_and_missing_binaries(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            with self.assertRaises(ValueError):
                verify(folder, 'arm64')
            (folder / 'app').write_bytes(elf(183))
            self.assertEqual(verify(folder, 'arm64'), 1)
            with self.assertRaises(ValueError):
                verify(folder, 'x64')

    def test_apk_requires_native_runtime_and_single_abi(self):
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / 'app.apk'
            with zipfile.ZipFile(apk, 'w') as archive:
                for name in ['libflutter.so', 'libapp.so', 'libmpv.so']:
                    archive.writestr('lib/arm64-v8a/' + name, elf(183))
            validate_apk(apk, 'arm64-v8a', 'arm64')
            with zipfile.ZipFile(apk, 'a') as archive:
                archive.writestr('lib/armeabi-v7a/libmpv.so', elf(40))
            with self.assertRaises(ValueError):
                validate_apk(apk, 'arm64-v8a', 'arm64')
            with zipfile.ZipFile(apk, 'w') as archive:
                archive.writestr('lib/arm64-v8a/libflutter.so', elf(183))
            with self.assertRaises(ValueError):
                validate_apk(apk, 'arm64-v8a', 'arm64')


if __name__ == '__main__':
    unittest.main()
