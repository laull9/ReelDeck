# ReelDeck 图标

`reeldeck.png` 为用户提供的透明母图，保留原始像素与尺寸。各平台资源从它生成，采用正方形画布和平台留白。Android 自适应图标将图形置于安全区域内。

`reeldeck.svg` 用 SVG 容器嵌入同一张图，方便单文件展示；内部仍为 PNG，没有可编辑的矢量路径。

安装 `scripts/requirements.txt` 后运行 `python3 scripts/generate_icons.py` 重新生成；加 `--check` 核对已提交资源。颜色与形状沿用母图。
