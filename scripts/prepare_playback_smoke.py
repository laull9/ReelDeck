"""生成不含用户视频的原生播放验收入口，产物保存在 build/。"""
import base64
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parent.parent
output = root / 'build' / 'playback-smoke'
output.mkdir(parents=True, exist_ok=True)
entries = []
for name, encoder, size, color in [
    ('h264-long-gop', 'libx264', '320x180', 'red'),
    ('h264-4k', 'libx264', '3840x2160', 'lime'),
    ('hevc-4k', 'libx265', '3840x2160', 'blue'),
]:
    fixture = output / f'{name}.mp4'
    command = [
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi', '-i',
        f'color=c={color}:size={size}:rate=30', '-t', '30', '-c:v', encoder,
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

transition = output / 'transition.dart'
transition.write_text(
    "import 'dart:convert';\n"
    "import '../../scripts/playback_transition_smoke.dart' as smoke;\n"
    "void main() => smoke.runTransitionSmoke({\n" + '\n'.join(entries) + '\n});\n'
)
print(f'flutter run -d macos --release -t {transition.relative_to(root)}')

# 三秒短片，部分音轨比画面长，用于连续切换压力验收。
stress = []
for name, color, audio in [
    ('red-a', 'red', 0), ('green-a', 'lime', 3.6), ('blue-a', 'blue', 0),
    ('red-b', 'red', 3.6), ('green-b', 'lime', 0), ('blue-b', 'blue', 3.6),
]:
    fixture = output / f'{name}.mp4'
    command = [
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi', '-i',
        f'color=c={color}:size=320x180:rate=30:d=3',
    ]
    if audio:
        command += ['-f', 'lavfi', '-i', f'sine=frequency=440:duration={audio}', '-c:a', 'aac']
    command += ['-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-g', '30', '-preset', 'ultrafast']
    subprocess.run(command + ['-y', str(fixture)], check=True)
    encoded = base64.b64encode(fixture.read_bytes()).decode('ascii')
    stress.append(f"'{name}': base64Decode('{encoded}'),")
# 损坏样本：头部可读，后半截断或写入噪声，播放中途出错或解码停滞。
base = output / 'bad-base.mp4'
subprocess.run([
    'ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi', '-i',
    'testsrc2=size=640x360:rate=30:d=6', '-c:v', 'libx264', '-pix_fmt', 'yuv420p',
    '-g', '30', '-preset', 'ultrafast', '-movflags', '+faststart', '-y', str(base),
], check=True)
data = base.read_bytes()
noisy = bytearray(data)
for offset in range(len(data) // 3, len(data) * 2 // 3, 97):
    noisy[offset] ^= 0x5A
for name, payload in [('bad-trunc', data[: len(data) // 2]), ('bad-noise', bytes(noisy))]:
    encoded = base64.b64encode(payload).decode('ascii')
    stress.append(f"'{name}': base64Decode('{encoded}'),")
entry = output / 'stress.dart'
entry.write_text(
    "import 'dart:convert';\n"
    "import '../../scripts/playback_stress_smoke.dart' as smoke;\n"
    "void main() => smoke.runStressSmoke({\n" + '\n'.join(stress) + '\n});\n'
)
print(f'flutter run -d macos --release -t {entry.relative_to(root)}')
