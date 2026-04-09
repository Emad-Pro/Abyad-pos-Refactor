import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';

class OrderRepository {
  OrderRepository({required this.apiClient});
  final ApiClient apiClient;

  Future<Map<String, dynamic>> requestBalancing() async {
    return await apiClient.request(
      url: ApiEndPoints.BASE_URL + 'payment-request',
      method: 'POST',
    );
  }

  Future<Map<String, dynamic>> fetchOrders(
      {required int pageSize, required int pageNumber, required String status}) async {
    return await apiClient.request(
      url: "${ApiEndPoints.BASE_URL}get-orders?page_size=$pageSize&page=$pageNumber&status=$status",
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> searchOrders({required String urlString}) async {
    return await apiClient.request(url: urlString, method: 'GET');
  }

  Future<Map<String, dynamic>> fetchOrderById(String id) async {
    return await apiClient.request(
      url: ApiEndPoints.BASE_URL + "get-order/${id}",
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> fetchClothes() async {
    return await apiClient.request(
      url: ApiEndPoints.BASE_URL + "get-clothes",
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> fetchAllClothesActiveAndInactive() async {
    return await apiClient.request(
      url: ApiEndPoints.BASE_URL + "get-all-clothes",
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> fetchLoans(
      {required int pageNumber, required bool onlyWithLoan, String? search}) async {
    String url =
        "${ApiEndPoints.BASE_URL}customers/loans?page=$pageNumber&only_with_loan=$onlyWithLoan";

    if (search != null && search.isNotEmpty) {
      url += "&search=$search";
    }

    return await apiClient.request(
      url: url,
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> updateClothes(List<Cloth> clothes) async {
    final body = {
      "clothes": clothes
          .map((cloth) => {
                "laundry_cloth_id": cloth.id,
                "is_active": cloth.is_active,
                "sort_order": cloth.sort_order,
                "prices": {
                  "price_cleaning": cloth.prices.priceCleaning ?? 0,
                  "price_fast_cleaning": cloth.prices.priceFastCleaning ?? 0,
                  "price_ironing": cloth.prices.priceIroning ?? 0,
                  "price_cleaning_and_ironing": cloth.prices.priceCleaningAndIroning ?? 0,
                  "price_fast_ironing": cloth.prices.priceFastIroning ?? 0,
                  "price_fast_cleaning_and_ironing": cloth.prices.priceFastCleaningAndIroning ?? 0,
                }
              })
          .toList()
    };
    return await apiClient.request(
      url: ApiEndPoints.BASE_URL + "update-clothes",
      method: 'POST',
      body: body,
    );
  }

  Future<Map<String, dynamic>> createOrder(dynamic body) async {
    return await apiClient.request(
      url: ApiEndPoints.createOrder,
      method: 'POST',
      body: body,
    );
  }

  Future<Map<String, dynamic>> addCustomer(String name, String phone) async {
    final body = {"name": name, "phone": "+966$phone"};
    return await apiClient.request(
      url: ApiEndPoints.addCustomers,
      method: 'POST',
      body: body,
    );
  }

  Future<Map<String, dynamic>> fetchCollectionInvoices(
      String endpoint, Map<String, dynamic> body) async {
    return await apiClient.request(
      url: endpoint,
      method: 'POST',
      body: body,
    );
  }

  Future<Map<String, dynamic>> fetchOrderStatus(String orderId) async {
    return await apiClient.request(
      url: ApiEndPoints.BASE_URL + "order/statuses/$orderId",
      method: 'GET',
    );
  }

  Future<Map<String, dynamic>> updateOrderStatus(dynamic body) async {
    return await apiClient.requestMultiRequest(
      url: ApiEndPoints.updateOrderStatus,
      method: 'POST',
      body: body,
    );
  }

  Future<Map<String, dynamic>> fetchPosStats(String urlString) async {
    return await apiClient.request(url: urlString, method: 'GET');
  }
}
