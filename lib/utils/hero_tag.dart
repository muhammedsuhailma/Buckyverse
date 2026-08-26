String heroTag({
  required String category,
  required dynamic id,
  String prefix = "",
}) {
  if (prefix.isNotEmpty) {
    return "${prefix}_${category}_$id";
  }
  return "${category}_$id";
}