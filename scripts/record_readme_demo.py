"""录制 README 演示 GIF：下载开放电影片段，在 macOS 应用内逐帧截图，输出各语言 GIF。

素材来自 Blender Foundation 开放电影（CC BY），只截取几秒并裁成竖屏。
需要 FFmpeg；录制使用内存数据库，不改动用户的 ReelDeck 数据。

    python3 scripts/record_readme_demo.py            # 下载、录制并输出 GIF
    python3 scripts/record_readme_demo.py --keep     # 保留沙盒中的原始帧
    python3 scripts/record_readme_demo.py --encode-only  # 只用保留的原始帧重新编码
"""
import pathlib
import shutil
import subprocess
import sys
import urllib.request
import zipfile

root = pathlib.Path(__file__).resolve().parent.parent
work = root / 'build' / 'readme-demo'
clips = work / 'clips'
output = root / 'docs' / 'media'
sandbox = pathlib.Path.home() / 'Library/Containers/com.reeldeck.reelDeck/Data/tmp/reeldeck-demo'
locales = ['en', 'zh', 'ja', 'es', 'fr']
# GIF 体积控制在约 3 MiB：8 帧/秒、240 像素宽、64 色。
gif_fps = 8

# (片名, 下载地址, 起点秒, 时长秒, 9:16 裁剪)
sources = [
    ('Big Buck Bunny',
     'https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_640x360.m4v.zip',
     133, 4, 'crop=ih*9/16:ih'),
    ('Sintel', 'https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4',
     32.5, 3.5, 'crop=459:816:730:132'),
    ('Tears of Steel', 'https://download.blender.org/demo/movies/ToS/tears_of_steel_720p.mov',
     284.5, 5, 'crop=297:528:491:4'),
]


def ffmpeg(*args, **kwargs):
    subprocess.run(['ffmpeg', '-nostdin', '-hide_banner', '-loglevel', 'error', *args],
                   check=True, **kwargs)


def prepare_clips():
    clips.mkdir(parents=True, exist_ok=True)
    for name, url, start, length, crop in sources:
        clip = clips / f'{name}.mp4'
        if clip.exists():
            continue
        original = work / pathlib.Path(url).name
        if not original.exists():
            print(f'下载 {url}')
            urllib.request.urlretrieve(url, original)
        if original.suffix == '.zip':
            # Blender 站点的正片以 zip 打包，只含一个视频文件。
            with zipfile.ZipFile(original) as archive:
                member = archive.namelist()[0]
                if not (work / member).exists():
                    archive.extract(member, work)
            original = work / member
        ffmpeg('-ss', str(start), '-t', str(length), '-i', str(original),
               '-vf', f'{crop},scale=540:960,setsar=1', '-c:v', 'libx264', '-crf', '23',
               '-preset', 'slow', '-pix_fmt', 'yuv420p', '-c:a', 'aac', '-b:a', '96k',
               '-movflags', '+faststart', '-y', str(clip))


def record():
    shutil.rmtree(sandbox, ignore_errors=True)
    shutil.copytree(clips, sandbox / 'Open Movies')
    subprocess.run(['flutter', 'build', 'macos', '--release',
                    '-t', 'scripts/readme_demo.dart'], cwd=root, check=True)
    # 通过 open 启动才会激活窗口并持续出帧；录完五种语言后应用自行退出。
    app = root / 'build/macos/Build/Products/Release/ReelDeck.app'
    subprocess.run(['open', '-W', '-n', str(app)], check=True, timeout=900)


def encode(locale):
    folder = sandbox / locale
    lines = (folder / 'frames.txt').read_text().split()
    width, height = map(int, lines[0].split('x'))
    times = list(map(int, lines[1:]))
    size = width * height * 4
    raw = (folder / 'frames.rgba').read_bytes()
    # 截图间隔不均匀，按时间戳重采样到固定帧率。
    picked, index = [], 0
    for tick in range(0, times[-1] + 1, 1000 // gif_fps):
        while index + 1 < len(times) and times[index + 1] <= tick:
            index += 1
        picked.append(raw[index * size:(index + 1) * size])
    output.mkdir(parents=True, exist_ok=True)
    target = output / f'demo-{locale}.gif'
    ffmpeg('-f', 'rawvideo', '-pix_fmt', 'rgba', '-s', f'{width}x{height}', '-r', str(gif_fps),
           '-i', '-', '-vf',
           'scale=240:-2:flags=lanczos,split[a][b];[a]palettegen=max_colors=64:stats_mode=full[p];'
           '[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle',
           '-loop', '0', '-y', str(target), input=b''.join(picked))
    print(f'{target.relative_to(root)} {target.stat().st_size // 1024} KiB')


if __name__ == '__main__':
    if '--encode-only' not in sys.argv:
        prepare_clips()
        record()
        print('录制结束后执行 flutter build macos --release 恢复正常应用入口')
    for locale in locales:
        encode(locale)
    if '--keep' not in sys.argv and '--encode-only' not in sys.argv:
        shutil.rmtree(sandbox, ignore_errors=True)
