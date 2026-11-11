"""只损坏第 3–3.5 秒的视频包，保留开头、容器索引和完整音轨。"""
import json
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parent.parent
output = root / 'build' / 'decode-stress'
output.mkdir(parents=True, exist_ok=True)
base = output / 'midstream-clean.mp4'
subprocess.run([
    'ffmpeg', '-hide_banner', '-loglevel', 'error',
    '-f', 'lavfi', '-i', 'testsrc2=size=640x360:rate=30:duration=10',
    '-f', 'lavfi', '-i', 'sine=frequency=440:duration=10',
    '-c:v', 'libx264', '-preset', 'ultrafast', '-g', '60',
    '-keyint_min', '60', '-sc_threshold', '0', '-c:a', 'aac',
    '-movflags', '+faststart', '-y', str(base),
], check=True)
packets = json.loads(subprocess.check_output([
    'ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_packets',
    '-show_entries', 'packet=pts_time,pos,size,flags', '-of', 'json', str(base),
], text=True))['packets']
data = bytearray(base.read_bytes())
damaged = 0
for packet in packets:
    if 3 <= float(packet['pts_time']) < 3.5 and 'K' not in packet['flags']:
        start, size = int(packet['pos']), int(packet['size'])
        # 保留包长和 NAL 起始信息，破坏 slice 负载，避免只测到容器打不开。
        data[start + 5:start + size] = b'\x00' * (size - 5)
        damaged += 1
assert damaged > 0
(output / 'midstream-corrupt.mp4').write_bytes(data)
print(f'Midstream fixture: damaged {damaged} video packets at 3–3.5 seconds')
