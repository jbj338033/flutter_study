class PageResponse<T> {
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final List<T> content;
  final int number;
  final Sort sort;
  final int numberOfElements;
  final Pageable pageable;
  final bool empty;

  PageResponse({
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.content,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.pageable,
    required this.empty,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    var contentList = json['content'] as List? ?? [];
    List<T> content = contentList
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();

    return PageResponse<T>(
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? false,
      size: json['size'] as int? ?? 0,
      content: content,
      number: json['number'] as int? ?? 0,
      sort: Sort.fromJson(json['sort']),
      numberOfElements: json['numberOfElements'] as int? ?? 0,
      pageable:
          Pageable.fromJson(json['pageable'] as Map<String, dynamic>? ?? {}),
      empty: json['empty'] as bool? ?? true,
    );
  }
}

class Sort {
  final bool empty;
  final bool sorted;
  final bool unsorted;

  Sort({required this.empty, required this.sorted, required this.unsorted});

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
        empty: json['empty'] as bool,
        sorted: json['sorted'] as bool,
        unsorted: json['unsorted'] as bool);
  }
}

class Pageable {
  final int offset;
  final Sort sort;
  final int pageSize;
  final bool paged;
  final int pageNumber;
  final bool unpaged;

  Pageable({
    required this.offset,
    required this.sort,
    required this.pageSize,
    required this.paged,
    required this.pageNumber,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      offset: json['offset'] as int? ?? 0,
      sort: Sort.fromJson(json['sort']),
      pageSize: json['pageSize'] as int? ?? 20,
      paged: json['paged'] as bool? ?? true,
      pageNumber: json['pageNumber'] as int? ?? 0,
      unpaged: json['unpaged'] as bool? ?? false,
    );
  }
}
