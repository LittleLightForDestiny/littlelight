//@dart=2.12

class DownloadProgress {
  final int downloadedBytes;
  final int totalBytes;
  final bool downloaded;
  final bool unzipped;

  DownloadProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    this.downloaded = false,
    this.unzipped = false,
  });
}
