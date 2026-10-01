#!/usr/bin/env python3
"""从用户提供的透明 PNG 生成各平台尺寸，母图不改写。"""
import argparse
import base64
import io
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def generate():
    original = Image.open(ROOT / 'assets/icon/reeldeck.png').convert('RGBA')
    # 输入图有极淡的导出噪点。只用可见轮廓计算留白，保留轮廓内部像素。
    bounds = original.getchannel('A').point(lambda value: 255 if value >= 16 else 0).getbbox()
    if bounds is None:
        raise ValueError('图标为空')
    artwork = original.crop(bounds)

    def square(size, proportion=0.86):
        scaled = artwork.copy()
        extent = max(1, round(size * proportion))
        scaled.thumbnail((extent, extent), Image.Resampling.LANCZOS)
        canvas = Image.new('RGBA', (size, size))
        canvas.alpha_composite(scaled, ((size - scaled.width) // 2, (size - scaled.height) // 2))
        return canvas

    files = {}

    def png(path, size, proportion=0.86):
        data = io.BytesIO()
        square(size, proportion).save(data, format='PNG')
        files[path] = data.getvalue()

    png('assets/icon/app_icon.png', 1024)
    for size in [16, 32, 64, 128, 256, 512, 1024]:
        png(f'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{size}.png', size, 0.82)
    ico = io.BytesIO()
    square(256).save(ico, format='ICO', sizes=[(n, n) for n in [16, 24, 32, 48, 64, 128, 256]])
    files['windows/runner/resources/app_icon.ico'] = ico.getvalue()
    for density, scale in [('mdpi', 1), ('hdpi', 1.5), ('xhdpi', 2), ('xxhdpi', 3), ('xxxhdpi', 4)]:
        png(f'android/app/src/main/res/mipmap-{density}/ic_launcher.png', round(48 * scale))
        png(f'android/app/src/main/res/drawable-{density}/ic_launcher_foreground.png', round(108 * scale), 0.59)
    for size in [16, 32, 48, 64, 128, 256, 512]:
        png(f'assets/icon/linux/{size}.png', size)
    encoded = base64.b64encode(files['assets/icon/app_icon.png']).decode('ascii')
    # SVG 容器保留同一张图；它没有把 PNG 冒充为可编辑的矢量路径。
    files['assets/icon/reeldeck.svg'] = (
        '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">'
        '<title>ReelDeck</title><image width="1024" height="1024" href="data:image/png;base64,'
        + encoded + '"/></svg>\n').encode()
    return files


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true', help='检查已提交图标与母图是否一致')
    args = parser.parse_args()
    files = generate()
    failures = []
    for name, data in files.items():
        path = ROOT / name
        if args.check:
            if not path.exists() or path.read_bytes() != data:
                failures.append(name)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    if failures:
        raise SystemExit('图标需要重新生成：\n' + '\n'.join(failures))
    print(f'{len(files)} 个图标文件已' + ('验证' if args.check else '生成'))


if __name__ == '__main__':
    main()
