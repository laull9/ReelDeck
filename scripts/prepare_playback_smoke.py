"""生成不含用户视频的原生播放验收入口，产物保存在 build/。"""
import base64
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parent.parent
output = root / 'build' / 'playback-smoke'
output.mkdir(parents=True, exist_ok=True)
entries = []
for name, encoder, size in [
    ('h264-long-gop', 'libx264', '320x180'),
    ('h264-4k', 'libx264', '3840x2160'),
    ('hevc-4k', 'libx265', '3840x2160'),
]:
    fixture = output / f'{name}.mp4'
    command = [
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi', '-i',
        f'color=c=red:size={size}:rate=30', '-t', '30', '-c:v', encoder,
        '-pix_fmt', 'yuv420p', '-g', '300', '-preset', 'ultrafast', '-an',
    ]
    if encoder == 'libx264':
        command += ['-keyint_min', '300', '-sc_threshold', '0']
    else:
        command += ['-x265-params', 'keyint=300:min-keyint=300:scenecut=0:log-level=error:pools=4']
    subprocess.run(command + ['-y', str(fixture)], check=True)
    encoded = base64.b64encode(fixture.read_bytes()).decode('ascii')
    entries.append(f"'{name}': base64Decode('{encoded}'),")
entry = output / 'main.dart'
entry.write_text(
    "import 'dart:convert';\n"
    "import '../../scripts/playback_smoke.dart' as smoke;\n"
    "void main() => smoke.runPlaybackSmoke({\n" + '\n'.join(entries) + '\n});\n'
)
print(f'flutter run -d macos --release -t {entry.relative_to(root)}')
