import argparse
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAGIC = {b'\xcf\xfa\xed\xfe', b'\xfe\xed\xfa\xcf', b'\xca\xfe\xba\xbe', b'\xbe\xba\xfe\xca'}


def package(app, arch, output):
    output.mkdir(parents=True, exist_ok=True)
    stage = output / app.name
    if stage.exists():
        shutil.rmtree(stage)
    shutil.copytree(app, stage, symlinks=True)
    expected = 'x86_64' if arch == 'x64' else 'arm64'
    binaries = []
    for file in stage.rglob('*'):
        if not file.is_file() or file.is_symlink():
            continue
        with file.open('rb') as handle:
            if handle.read(4) not in MAGIC:
                continue
        arches = subprocess.check_output(['lipo', '-archs', str(file)], text=True).strip().split()
        if expected not in arches:
            raise ValueError(f'{file} 缺少 {expected}')
        if len(arches) > 1:
            thin = file.with_name(file.name + '.thin')
            subprocess.run(['lipo', str(file), '-thin', expected, '-output', str(thin)], check=True)
            thin.replace(file)
        binaries.append(file)
    if not binaries:
        raise ValueError('macOS app 没有 Mach-O 文件')
    for file in binaries:
        subprocess.run(['codesign', '--force', '--sign', '-', str(file)], check=True)
    subprocess.run(['codesign', '--deep', '--force', '--sign', '-', '--entitlements',
                    str(ROOT / 'macos/Runner/Release.entitlements'), str(stage)], check=True)
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(stage)], check=True)
    for file in binaries:
        found = subprocess.check_output(['lipo', '-archs', str(file)], text=True).strip()
        if found != expected:
            raise ValueError(f'{file}: {found} 架构错误')
    archive = (output / f'ReelDeck-macos-{arch}.zip').resolve()
    subprocess.run(['ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', str(stage), str(archive)], check=True)
    shutil.rmtree(stage)
    print(f'{len(binaries)} 个 Mach-O 通过 {expected} 检查：{archive}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', type=Path, required=True)
    parser.add_argument('--arch', choices=['x64', 'arm64'], required=True)
    parser.add_argument('--output', type=Path, default=ROOT / 'dist')
    args = parser.parse_args()
    package(args.app, args.arch, args.output)
