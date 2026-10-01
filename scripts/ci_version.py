import os
from pathlib import Path
import re
import subprocess


def resolve_version(pubspec, ref, requested, publish):
    match = re.search(r'^version:\s*(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?)(?:\+\d+)?\s*$', pubspec, re.MULTILINE)
    if not match:
        raise ValueError('pubspec.yaml 版本格式错误')
    version = match.group(1)
    tag = ref.removeprefix('refs/tags/') if ref.startswith('refs/tags/') else requested
    if publish or ref.startswith('refs/tags/'):
        if tag != f'v{version}':
            raise ValueError('发布标签必须与 pubspec.yaml 版本一致')
    return version, tag


if __name__ == '__main__':
    publish = os.environ.get('PUBLISH') == 'true'
    ref = os.environ.get('GITHUB_REF', '')
    version, tag = resolve_version(Path('pubspec.yaml').read_text(), ref,
                                  os.environ.get('REQUESTED_TAG', ''), publish)
    if publish or ref.startswith('refs/tags/'):
        tagged = subprocess.check_output(['git', 'rev-parse', f'refs/tags/{tag}^{{commit}}'], text=True).strip()
        current = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
        if tagged != current:
            raise SystemExit('发布标签没有指向本次构建提交')
    if os.environ.get('GITHUB_OUTPUT'):
        with open(os.environ['GITHUB_OUTPUT'], 'a') as output:
            output.write(f'version={version}\ntag={tag}\n')
    print(f'构建版本 {version}' + (f'，标签 {tag}' if tag else '，仅构建 artifacts'))
