# VoiSlate

An app designed to solve **paperless sound report** during production.

This project aims to simplify the management of sound logs and metadata processing during production by integrating technologies like speech recognition and quick metadata writing. Through the mobile app and PC software, users can manage logs quickly on set, write metadata to audio files, and export recordings, making it easier for sound post-production and directors to find key audio entries.

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/3e1df6a2-428f-46b9-8aed-846ac84d2a80" alt="Recording Page" style="max-height: 300px; display: block; margin: 0 auto;">
</div>

## Main Features

<details>
  <summary>VoiSlate Recording Log </summary>

### Log Recording Page Features
* Easily switch between scenes, shots, and takes for each recording;
* Combine speech recognition to complete the sound log for each recording;
* Separate log content into fixed “ shot content” and corresponding “ recording content” to reduce the frequency of operations during recording;
* Rate the current recording, making it easier for sound post-production and directors to find approved entries;
* A dedicated re-recording mode where re-recorded items are marked separately after the shot.

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/3e1df6a2-428f-46b9-8aed-846ac84d2a80" alt="Recording Page" style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlate Shooting Plan</summary>

### Shooting Plan Page Features
* Set up the scenes, shots, and other related information to be filmed before the shot.

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/e78a2f03-d618-431d-8f44-f252c1bfbf4f" alt="Shooting Plan Page" style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlate Log Review and Edit</summary>

### Log Review and Edit Page Features
* Review or modify logs by scene and shot, or by date;
* Export logs in JSON format for use with VoiSlaui/VoiSlateParser.

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/73a7ac30-2aa5-4a71-b8e2-bde3ff2c6214" alt="Log Review Page" style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlateParser PC Metadata Writing</summary>

### VoiSlateParser (PC Metadata Writing) Features
* VoiSlateParser is a WPF-based tool for converting sound logs into metadata;
* Quickly review/edit log information, write metadata to audio files, and generate ALE files.

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/6a5a9b65-6472-4a79-9ec4-5d6a55a8ebdf" alt="PC Metadata Writing" style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

<details>
  <summary>VoiSlaui Android Metadata Writing</summary>

### VoiSlaui (Android Metadata Writing) Features
* VoiSlaui is a MAUI-based app for converting sound logs into metadata;
* Designed to quickly write log data to audio files on set.

<div style="text-align:center;">
  <img src="https://github.com/drunkenQCat/voislate_public/assets/39608175/44203b13-b3c1-4d9e-baa5-3f88abb9d5a9" alt="Android Metadata Writing" style="max-height: 300px; display: block; margin: 0 auto;">
</div>

</details>

## User Guide

* VoiSlate recommends using volume buttons for some operations.
* VoiSlaui requires an OTA-compatible SD reader for use.

## Development Guide

VoiSlate uses iFly's speech recognition API. In `src/lib/data`, there is a `ifly_key_example.dart` file as a sample for configuring the speech recognition API. Create your own file, fill in the necessary information, and reference it in `recorder_joystick.dart`. Detailed development documentation is available in the sub-repositories:

* [VoiSlate](https://github.com/drunkenQCat/voislate)
* [VoiSlaui](https://github.com/drunkenQCat/VoiSlaui)
* [VoiSlateParser](https://github.com/drunkenQCat/VoiSlateParser)