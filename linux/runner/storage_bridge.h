#pragma once
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

void register_storage_bridge(FlBinaryMessenger* messenger, GtkWindow* window);
