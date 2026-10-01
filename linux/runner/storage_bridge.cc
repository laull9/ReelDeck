#include "storage_bridge.h"
#include <gio/gio.h>
#include <string>

namespace {
FlValue* describe(const char* path, const char* locator) {
  FlValue* value = fl_value_new_map();
  g_autofree char* name = g_path_get_basename(path);
  fl_value_set_string_take(value, "name", fl_value_new_string(name));
  fl_value_set_string_take(value, "path", fl_value_new_string(path));
  fl_value_set_string_take(value, "locator", fl_value_new_string(locator));
  return value;
}

std::string locator_for(const char* path) {
  g_autoptr(GFile) file = g_file_new_for_path(path);
  g_autoptr(GMount) mount = g_file_find_enclosing_mount(file, nullptr, nullptr);
  if (!mount) return path;
  g_autoptr(GVolume) volume = g_mount_get_volume(mount);
  g_autofree char* uuid = volume ? g_volume_get_uuid(volume) : nullptr;
  if (!uuid) return path;
  g_autoptr(GFile) root = g_mount_get_root(mount);
  g_autofree char* relative = g_file_get_relative_path(root, file);
  g_autofree char* encoded = g_uri_escape_string(relative ? relative : "", nullptr, TRUE);
  g_autofree char* original = g_uri_escape_string(path, nullptr, TRUE);
  return std::string("volume:") + uuid + ":" + encoded + ":" + original;
}

std::string resolve(const char* locator) {
  if (!g_str_has_prefix(locator, "volume:")) return locator;
  g_auto(GStrv) parts = g_strsplit(locator, ":", 4);
  if (g_strv_length(parts) != 4) return "";
  g_autofree char* relative = g_uri_unescape_string(parts[2], nullptr);
  g_autoptr(GVolumeMonitor) monitor = g_volume_monitor_get();
  GList* mounts = g_volume_monitor_get_mounts(monitor);
  std::string resolved;
  for (GList* item = mounts; item; item = item->next) {
    GMount* mount = G_MOUNT(item->data);
    g_autoptr(GVolume) volume = g_mount_get_volume(mount);
    g_autofree char* uuid = volume ? g_volume_get_uuid(volume) : nullptr;
    if (g_strcmp0(uuid, parts[1]) == 0) {
      g_autoptr(GFile) root = g_mount_get_root(mount);
      g_autoptr(GFile) target = g_file_resolve_relative_path(root, relative ? relative : "");
      g_autofree char* path = g_file_get_path(target);
      if (path) resolved = path;
      break;
    }
  }
  g_list_free_full(mounts, g_object_unref);
  // 同一卷未挂载时不使用旧挂载点，避免打开别的磁盘。
  return resolved;
}

void handle(FlMethodChannel*, FlMethodCall* call, gpointer data) {
  GtkWindow* window = GTK_WINDOW(data);
  const char* method = fl_method_call_get_name(call);
  if (g_strcmp0(method, "pick") == 0) {
    GtkWidget* dialog = gtk_file_chooser_dialog_new("选择媒体目录", window,
        GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER, "取消", GTK_RESPONSE_CANCEL,
        "选择", GTK_RESPONSE_ACCEPT, nullptr);
    g_autoptr(FlValue) description = nullptr;
    if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_ACCEPT) {
      g_autofree char* path = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
      if (path) description = describe(path, locator_for(path).c_str());
    }
    gtk_widget_destroy(dialog);
    fl_method_call_respond_success(call, description, nullptr);
    return;
  }
  FlValue* args = fl_method_call_get_args(call);
  FlValue* location = args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP
      ? fl_value_lookup_string(args, "locator") : nullptr;
  if (!location || fl_value_get_type(location) != FL_VALUE_TYPE_STRING) {
    fl_method_call_respond_error(call, "arguments", "缺少目录位置", nullptr, nullptr);
    return;
  }
  auto root = resolve(fl_value_get_string(location));
  if (root.empty() || !g_file_test(root.c_str(), G_FILE_TEST_IS_DIR)) {
    if (g_strcmp0(method, "resolve") == 0) fl_method_call_respond_success(call, nullptr, nullptr);
    else fl_method_call_respond_error(call, "storage", "目录已断开", nullptr, nullptr);
    return;
  }
  if (g_strcmp0(method, "resolve") == 0) {
    g_autoptr(FlValue) description = describe(root.c_str(), fl_value_get_string(location));
    fl_method_call_respond_success(call, description, nullptr);
    return;
  }
  FlValue* relative = fl_value_lookup_string(args, "path");
  if (!relative || fl_value_get_type(relative) != FL_VALUE_TYPE_STRING) {
    fl_method_call_respond_error(call, "arguments", "缺少文件位置", nullptr, nullptr);
    return;
  }
  g_autoptr(GFile) directory = g_file_new_for_path(root.c_str());
  g_autoptr(GFile) file = g_file_resolve_relative_path(directory, fl_value_get_string(relative));
  g_autoptr(GError) error = nullptr;
  if (g_strcmp0(method, "trash") == 0) {
    g_file_trash(file, nullptr, &error);
  } else if (g_strcmp0(method, "reveal") == 0) {
    g_autofree char* uri = g_file_get_uri(file);
    const char* uris[] = {uri, nullptr};
    g_autoptr(GDBusConnection) bus = g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, nullptr);
    g_autoptr(GVariant) response = bus ? g_dbus_connection_call_sync(bus,
        "org.freedesktop.FileManager1", "/org/freedesktop/FileManager1",
        "org.freedesktop.FileManager1", "ShowItems", g_variant_new("(^ass)", uris, ""),
        nullptr, G_DBUS_CALL_FLAGS_NONE, 2000, nullptr, nullptr) : nullptr;
    if (!response) {
      g_autoptr(GFile) parent = g_file_get_parent(file);
      g_autofree char* parent_uri = g_file_get_uri(parent);
      g_app_info_launch_default_for_uri(parent_uri, nullptr, &error);
    }
  } else {
    fl_method_call_respond_not_implemented(call, nullptr);
    return;
  }
  if (error) fl_method_call_respond_error(call, "file", error->message, nullptr, nullptr);
  else fl_method_call_respond_success(call, nullptr, nullptr);
}
}

void register_storage_bridge(FlBinaryMessenger* messenger, GtkWindow* window) {
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(messenger,
      "reeldeck/storage", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, handle,
      g_object_ref(window), g_object_unref);
}
