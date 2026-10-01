#!/usr/bin/env python3
"""为 Flutter bundle 生成 deb / rpm 并验证安装布局。"""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(*args):
    subprocess.run(args, check=True)


def package(bundle, arch, version, output):
    deb_arch = {'x64': 'amd64', 'arm64': 'arm64'}[arch]
    rpm_arch = {'x64': 'x86_64', 'arm64': 'aarch64'}[arch]
    output.mkdir(parents=True, exist_ok=True)
    output = output.resolve()
    with tempfile.TemporaryDirectory(prefix='reeldeck-package-') as temporary:
        stage = Path(temporary) / 'root'
        app = stage / 'usr/lib/reeldeck'
        shutil.copytree(bundle, app)
        if not (app / 'reel_deck').is_file() or not (app / 'data/flutter_assets').is_dir():
            raise ValueError('Flutter bundle 缺少可执行文件或资源')
        desktop = stage / 'usr/share/applications/com.reeldeck.reel_deck.desktop'
        desktop.parent.mkdir(parents=True)
        desktop.write_text('[Desktop Entry]\nType=Application\nName=ReelDeck\n'
                           'Comment=本地媒体随机播放器\nExec=/usr/lib/reeldeck/reel_deck\n'
                           'Icon=com.reeldeck.reel_deck\nTerminal=false\nCategories=AudioVideo;Player;\n')
        for size in [16, 32, 48, 64, 128, 256, 512]:
            icon = stage / f'usr/share/icons/hicolor/{size}x{size}/apps/com.reeldeck.reel_deck.png'
            icon.parent.mkdir(parents=True)
            shutil.copyfile(ROOT / f'assets/icon/linux/{size}.png', icon)
        control = stage / 'DEBIAN/control'
        control.parent.mkdir()
        control.write_text(f'Package: reeldeck\nVersion: {version}\nArchitecture: {deb_arch}\n'
                           'Maintainer: laull9 <laull9@users.noreply.github.com>\n'
                           'Section: video\nPriority: optional\n'
                           'Depends: libgtk-3-0, libmpv2, libepoxy0, libstdc++6, libc6 (>= 2.39)\n'
                           'Description: Local media shuffle feed player\n'
                           ' Play videos and images directly from your folders.\n')
        deb = output / f'ReelDeck-linux-{arch}.deb'
        run('dpkg-deb', '--build', '--root-owner-group', str(stage), str(deb))
        run('dpkg-deb', '--info', str(deb))
        shutil.rmtree(stage / 'DEBIAN')
        top = Path(temporary) / 'rpm'
        (top / 'SPECS').mkdir(parents=True)
        spec = top / 'SPECS/reeldeck.spec'
        spec.write_text(f'''Name: reeldeck
Version: {version}
Release: 1
Summary: Local media shuffle feed player
License: LicenseRef-ReelDeck
URL: https://github.com/laull9/ReelDeck
BuildArch: {rpm_arch}
Requires: gtk3, mpv-libs, libepoxy
AutoReqProv: yes
%global _build_id_links none
%global debug_package %{{nil}}
%description
Play videos and images directly from your folders.
%install
mkdir -p %{{buildroot}}
cp -a {stage}/usr %{{buildroot}}/
%files
/usr/lib/reeldeck
/usr/share/applications/com.reeldeck.reel_deck.desktop
/usr/share/icons/hicolor/*/apps/com.reeldeck.reel_deck.png
''')
        run('rpmbuild', '--define', f'_topdir {top}', '--define', '__os_install_post %{nil}',
            '--target', rpm_arch, '-bb', str(spec))
        rpms = list((top / 'RPMS').rglob('*.rpm'))
        if len(rpms) != 1:
            raise ValueError('RPM 输出数量异常')
        rpm = output / f'ReelDeck-linux-{arch}.rpm'
        shutil.copyfile(rpms[0], rpm)
        run('rpm', '-qip', str(rpm))
        run('desktop-file-validate', str(desktop))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--bundle', type=Path, required=True)
    parser.add_argument('--arch', choices=['x64', 'arm64'], required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--output', type=Path, default=ROOT / 'dist')
    args = parser.parse_args()
    package(args.bundle, args.arch, args.version, args.output)
