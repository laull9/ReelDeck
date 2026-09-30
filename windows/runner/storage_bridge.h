#ifndef REELDECK_STORAGE_BRIDGE_H_
#define REELDECK_STORAGE_BRIDGE_H_
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <shobjidl.h>
#include <string>

namespace storage {
inline std::string Utf8(const std::wstring& text) {
  if (text.empty()) return {};
  int length = WideCharToMultiByte(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), nullptr, 0, nullptr, nullptr);
  std::string output(length, '\0');
  WideCharToMultiByte(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), output.data(), length, nullptr, nullptr);
  return output;
}
inline std::wstring Wide(const std::string& text) {
  int length = MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), nullptr, 0);
  std::wstring output(length, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), output.data(), length);
  return output;
}
inline flutter::EncodableValue Description(const std::wstring& path, const std::wstring& locator) {
  auto end = path.find_last_not_of(L"\\/");
  auto start = path.find_last_of(L"\\/", end);
  auto name = path.substr(start == std::wstring::npos ? 0 : start + 1, end - start);
  return flutter::EncodableValue(flutter::EncodableMap{
    {flutter::EncodableValue("path"), flutter::EncodableValue(Utf8(path))},
    {flutter::EncodableValue("locator"), flutter::EncodableValue(Utf8(locator))},
    {flutter::EncodableValue("name"), flutter::EncodableValue(Utf8(name))}});
}
inline void Register(flutter::BinaryMessenger* messenger, HWND window) {
  flutter::MethodChannel<flutter::EncodableValue> channel(messenger, "reeldeck/storage", &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler([window](const auto& call, auto result) {
    if (call.method_name() == "pick") {
      IFileOpenDialog* dialog = nullptr;
      if (FAILED(CoCreateInstance(CLSID_FileOpenDialog, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog)))) {
        result->Error("picker", "无法打开目录选择器"); return;
      }
      DWORD options = 0;
      dialog->GetOptions(&options);
      dialog->SetOptions(options | FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM);
      if (SUCCEEDED(dialog->Show(window))) {
        IShellItem* item = nullptr;
        if (SUCCEEDED(dialog->GetResult(&item))) {
          PWSTR selected = nullptr;
          if (SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &selected))) {
            std::wstring path(selected), locator(path);
            wchar_t root[MAX_PATH], volume[MAX_PATH];
            if (GetVolumePathNameW(selected, root, MAX_PATH) && GetVolumeNameForVolumeMountPointW(root, volume, MAX_PATH)) {
              locator = std::wstring(volume) + path.substr(wcslen(root));
            }
            result->Success(Description(path, locator));
            CoTaskMemFree(selected); item->Release(); dialog->Release(); return;
          }
          item->Release();
        }
      }
      dialog->Release(); result->Success(); return;
    }
    if (call.method_name() == "resolve") {
      const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
      if (!args) { result->Error("arguments", "缺少目录信息"); return; }
      auto value = args->find(flutter::EncodableValue("locator"));
      if (value == args->end() || !std::holds_alternative<std::string>(value->second)) { result->Error("arguments", "目录信息无效"); return; }
      auto locator = Wide(std::get<std::string>(value->second));
      std::wstring path(locator);
      if (locator.rfind(L"\\\\?\\Volume{", 0) == 0) {
        auto boundary = locator.find(L"}\\");
        if (boundary != std::wstring::npos) {
          auto volume = locator.substr(0, boundary + 2);
          DWORD required = 0;
          GetVolumePathNamesForVolumeNameW(volume.c_str(), nullptr, 0, &required);
          if (required > 0) {
            std::wstring mounts(required, L'\0');
            if (GetVolumePathNamesForVolumeNameW(volume.c_str(), mounts.data(), required, &required) && mounts[0]) {
              path = std::wstring(mounts.c_str()) + locator.substr(boundary + 2);
            }
          }
        }
      }
      auto attributes = GetFileAttributesW(path.c_str());
      if (attributes == INVALID_FILE_ATTRIBUTES || !(attributes & FILE_ATTRIBUTE_DIRECTORY)) { result->Success(); return; }
      result->Success(Description(path, locator)); return;
    }
    result->NotImplemented();
  });
}
}
#endif
