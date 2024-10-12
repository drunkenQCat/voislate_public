# VoiSlate

<div align="center">

[English README](./README-EN.md)

</div>

用于解决 **声音场记** 无纸化而设计的 App

本项目旨在通过结合语音识别、快速元数据写入等技术，简化拍摄过程中声音场记的管理和元数据处理。通过手机 App 和 PC 端软件，用户可以在拍摄现场快速管理场记、向录音文件写入元数据并导出录音，方便声音后期和导演查找关键录音条目。

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/3e1df6a2-428f-46b9-8aed-846ac84d2a80" alt=" 记录页面 " style="max-height: 300px; display: block; margin: 0 auto;">
</div>

## 主要功能

<details>
  <summary>VoiSlate 场记记录 </summary>

### 录音记录页面功能
* 可以通过简单的操作切换下一条录音对应的场、镜、次；
* 结合语音识别，做好每一条录音的声音场记；
* 场记内容分为不变的“镜头内容”和对应每一条的“录音内容”，尽量减少录音过程中操作的频率；
* 可以评价当前录音，方便声音后期和导演快速找到“过”或“保”的条目；
* 单独的补录模式，在拍摄后补录条目会单独做标记。

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/3e1df6a2-428f-46b9-8aed-846ac84d2a80" alt=" 记录页面 " style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlate 拍摄计划 </summary>

### 拍摄计划页面功能
* 拍摄前可以设置好接下来要拍摄的场、镜，以及其他相关信息。

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/e78a2f03-d618-431d-8f44-f252c1bfbf4f" alt=" 计划页面 " style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlate 场记查改 </summary>

### 场记查改页面功能
* 按日期，分场、镜查看 / 修改所有场记；
* 可以将场记以 JSON 文件的格式输出，以供 VoiSlaui/VoiSlateParser 使用。

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/73a7ac30-2aa5-4a71-b8e2-bde3ff2c6214" alt=" 场记页面 " style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlateParser PC 端写入元数据 </summary>

### VoiSlateParser (PC 端写入元数据 ) 功能
* VoiSlateParser 是基于 WPF 编写的声音场记转声音元数据软件；
* 可以快速查看 / 修改场记信息，向录音文件写入元数据，并生成 ALE 文件。

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/6a5a9b65-6472-4a79-9ec4-5d6a55a8ebdf" alt="PC 端写入元数据 " style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlaui 安卓端写入元数据 </summary>

### VoiSlaui ( 安卓端写入元数据 ) 功能
* VoiSlaui 是基于 MAUI 编写的声音场记转声音元数据的 App；
* 满足现场快速向录音文件写入场记数据的需求。

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/44203b13-b3c1-4d9e-baa5-3f88abb9d5a9" alt=" 安卓端写入元数据 " style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>


## 使用说明

* VoiSlate 推荐使用音量键来进行某些操作
* VoiSlaui 需自行配备带 OTA 功能的读卡器。

## 开发须知

VoiSlate 使用了讯飞的语音识别 API，在 src/lib/data 中有 `ifly_key_example.dart` 文件作为语音识别 API 信息的样例。自行创建文件，填入信息，并在 `recorder_joystick.dart` 中引用。详细开发说明请参见各子仓库 Readme：

* [VoiSlate](https://github.com/drunkenQCat/voislate)
* [VoiSlaui](https://github.com/drunkenQCat/VoiSlaui)
* [VoiSlateParser](https://github.com/drunkenQCat/VoiSlateParser)
