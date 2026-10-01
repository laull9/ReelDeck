from pathlib import Path
import shutil
import tempfile
import zipfile

from verify_arch import verify


def validate_apk(apk, abi, arch):
    with zipfile.ZipFile(apk) as archive:
        libraries = [name for name in archive.namelist() if name.startswith('lib/') and name.endswith('.so')]
        if {name.split('/')[1] for name in libraries} != {abi}:
            raise ValueError('APK 中的 ABI 与文件名不符')
        for required in ['libflutter.so', 'libapp.so', 'libmpv.so']:
            if f'lib/{abi}/{required}' not in libraries:
                raise ValueError(f'APK 缺少 {required}')
        with tempfile.TemporaryDirectory() as directory:
            for name in libraries:
                archive.extract(name, directory)
            verify(Path(directory), arch)


if __name__ == '__main__':
    output = Path('dist')
    output.mkdir(exist_ok=True)
    suffix = '' if Path('android/key.properties').exists() else '-test-signed'
    for abi, arch in [('arm64-v8a', 'arm64'), ('armeabi-v7a', 'armv7')]:
        apk = Path(f'build/app/outputs/flutter-apk/app-{abi}-release.apk')
        validate_apk(apk, abi, arch)
        shutil.copyfile(apk, output / f'ReelDeck-android-{arch}{suffix}.apk')
        print(f'{abi} APK 验证通过')
