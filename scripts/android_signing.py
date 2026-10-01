import base64
import os
from pathlib import Path


def escape_property(value):
    return (value.replace('\\', '\\\\').replace('\n', '\\n').replace('\r', '\\r')
            .replace('=', '\\=').replace(':', '\\:').replace(' ', '\\ '))


if __name__ == '__main__':
    keys = ['KEYSTORE', 'STORE_PASSWORD', 'KEY_PASSWORD', 'KEY_ALIAS']
    values = {key: os.environ.get(key, '') for key in keys}
    if any(values.values()) and not all(values.values()):
        raise SystemExit('Android 签名 secrets 不完整')
    if not values['KEYSTORE']:
        print('未配置正式签名；APK 文件名将标记 test-signed')
    else:
        Path('android/release.keystore').write_bytes(base64.b64decode(values['KEYSTORE'], validate=True))
        properties = {
            'storeFile': 'release.keystore', 'storePassword': values['STORE_PASSWORD'],
            'keyPassword': values['KEY_PASSWORD'], 'keyAlias': values['KEY_ALIAS'],
        }
        text = '\n'.join(f'{key}={escape_property(value)}' for key, value in properties.items()) + '\n'
        # Java Properties(InputStream) 按 Latin-1 读取；非 ASCII 字符必须转义。
        text = ''.join(char if ord(char) < 128 else
                       ''.join(f'\\u{int.from_bytes(pair, "big"):04x}'
                               for pair in [char.encode('utf-16-be')[i:i+2]
                                            for i in range(0, len(char.encode('utf-16-be')), 2)])
                       for char in text)
        Path('android/key.properties').write_text(text, encoding='ascii')
        print('已配置 Android 发布签名')
