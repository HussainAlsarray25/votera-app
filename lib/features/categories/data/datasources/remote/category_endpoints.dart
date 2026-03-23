/// Centralized endpoint paths for the categories feature.
/// All paths are relative (no leading slash, no version prefix).
class CategoryEndpoints {
  const CategoryEndpoints._();

  static const String categories = 'categories';

  static String categoryById(String id) => 'categories/$id';
}
