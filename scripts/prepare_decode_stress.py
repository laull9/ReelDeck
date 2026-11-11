"""生成真实运动画面的 4K60 解码压力及损坏文件；不读取用户媒体。"""
import pathlib
import subprocess
import sys

root = pathlib.Path(__file__).resolve().parent.parent
output = root / 'build' / 'decode-stress'
output.mkdir(parents=True, exist_ok=True)
for name, codec, pix_fmt in [
    ('h264-4k60', 'libx264', 'yuv420p'),
    ('hevc-4k60-10bit', 'libx265', 'yuv420p10le'),
]:
    command = [
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi', '-i',
        'testsrc2=size=3840x2160:rate=60:duration=8',
        '-f', 'lavfi', '-i', 'sine=frequency=440:duration=8',
        '-c:v', codec, '-pix_fmt', pix_fmt, '-preset', 'ultrafast',
        '-crf', '20', '-g', '120', '-threads', '4', '-c:a', 'aac',
        '-movflags', '+faststart',
    ]
    if codec == 'libx265':
        command += ['-x265-params', 'pools=4:frame-threads=2:log-level=error']
    subprocess.run(command + ['-y', str(output / f'{name}.mp4')], check=True)

data = (output / 'h264-4k60.mp4').read_bytes()
(output / 'truncated.mp4').write_bytes(data[:len(data) // 2])
damaged = bytearray(data)
for offset in range(len(data) // 3, len(data) * 2 // 3, 97):
    damaged[offset] ^= 0x5A
(output / 'damaged-frames.mp4').write_bytes(damaged)
(output / 'invalid.mp4').write_bytes(b'not a media container')
subprocess.run([sys.executable, str(root / 'scripts' / 'prepare_midstream_damage.py')], check=True)
print(f'Generated decode fixtures: {output}')
