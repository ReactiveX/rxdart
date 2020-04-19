/// @private
/// Helper method which find max value or min value in [values] list
T minMax<T>(List<T> values, bool findMin, Comparator<T> comparator) {
  comparator ??= () {
    if (values.first is Comparable) {
      return Comparable.compare as Comparator<T>;
    } else {
      throw Exception(
          'Please provide a comparator for type $T, because it is not comparable');
    }
  }();
  return values.reduce((acc, element) => findMin
      ? comparator(element, acc) < 0 ? element : acc
      : comparator(element, acc) > 0 ? element : acc);
}
