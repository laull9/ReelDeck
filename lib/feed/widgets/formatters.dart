String formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const kb = 1024;
  const mb = 1024 * kb;
  const gb = 1024 * mb;

  if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(2)} GB';
  } else if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  } else if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  } else {
    return '$bytes B';
  }
}
