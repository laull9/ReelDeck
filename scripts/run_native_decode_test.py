"""运行解码压力测试；macOS 在 build 内准备可被测试进程加载的打包库。"""
import json
import os
import pathlib
import platform
import shutil
import subprocess
import urllib.parse

root = pathlib.Path(__file__).resolve().parent.parent
env = dict(os.environ)
if platform.system() == 'Darwin' and not env.get('REELDECK_LIBMPV'):
    config = root / '.dart_tool' / 'package_config.json'
    packages = json.loads(config.read_text())['packages']
    package = next(p for p in packages if p['name'] == 'media_kit_libs_macos_video')
    uri = urllib.parse.urljoin(config.as_uri(), package['rootUri'])
    source = pathlib.Path(urllib.parse.unquote(urllib.parse.urlparse(uri).path))
    target = root / 'build' / 'decode-stress' / 'frameworks'
    target.mkdir(parents=True, exist_ok=True)
    for framework in (source / 'macos' / 'Frameworks').glob(
        '*.xcframework/macos-arm64_x86_64/*.framework'
    ):
        copy = target / framework.name
        if copy.exists():
            shutil.rmtree(copy)
        shutil.copytree(framework, copy, symlinks=True)
        binary = copy / 'Versions' / 'A' / copy.stem
        # 整理旧版 universal 二进制的 LINKEDIT 后再修改加载路径。
        subprocess.run(
            ['codesign', '--force', '--sign', '-', str(copy)],
            check=True, capture_output=True,
        )
        # 仅修改 build 中的副本；Flutter 测试进程不继承 DYLD 搜索路径。
        subprocess.run(
            ['install_name_tool', '-add_rpath', str(target), str(binary)],
            check=True, capture_output=True,
        )
        subprocess.run(
            ['codesign', '--force', '--sign', '-', str(copy)],
            check=True, capture_output=True,
        )
    env['REELDECK_LIBMPV'] = str(target / 'Mpv.framework' / 'Versions' / 'A' / 'Mpv')

result = subprocess.run(
    ['flutter', 'test', '--no-pub', 'scripts/native_decode_test.dart'],
    cwd=root, env=env,
)
raise SystemExit(result.returncode)
