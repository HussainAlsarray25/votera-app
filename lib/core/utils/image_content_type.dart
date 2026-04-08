const Map<String, String> _imageMimeByExtension = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'avif': 'image/avif',
  'svg': 'image/svg+xml',
  'tif': 'image/tiff',
  'tiff': 'image/tiff',
};

String resolveImageContentType({String? fileName, String? filePath}) {
  final nameOrPath =
      (fileName != null && fileName.trim().isNotEmpty) ? fileName : filePath;
  if (nameOrPath == null) {
    return 'application/octet-stream';
  }

  final lastDot = nameOrPath.lastIndexOf('.');
  if (lastDot == -1 || lastDot == nameOrPath.length - 1) {
    return 'application/octet-stream';
  }

  final ext = nameOrPath.substring(lastDot + 1).toLowerCase();
  return _imageMimeByExtension[ext] ?? 'application/octet-stream';
}
