class LoanModel {
  final String message;
  final LoanData data;

  LoanModel({required this.message, required this.data});

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      message: json['message'],
      data: LoanData.fromJson(json['data']),
    );
  }
}

class LoanData {
  List<Customer> customers;
  Pagination pagination;

  LoanData({required this.customers, required this.pagination});

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      customers: (json['customers'] as List)
          .map((e) => Customer.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String phone;

  final String? totalOrders;
  final String? totalAmountSpent;
  final String? loanAmount;

  bool discountEnabled;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalOrders,
    required this.totalAmountSpent,
    required this.loanAmount,
    this.discountEnabled = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? "",
      phone: json['phone']?.toString() ?? "",
      totalOrders: json['total_orders']?.toString(),
      totalAmountSpent: json['total_amount_spent']?.toString(),
      loanAmount: json['loan_amount']?.toString(),
      discountEnabled: false,
    );
  }
}



class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
    );
  }
}
