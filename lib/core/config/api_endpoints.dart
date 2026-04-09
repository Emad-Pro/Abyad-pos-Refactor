
class ApiEndPoints {
  static const SecretKey =
      'Basic MzA2OTo4YTA2M2M3ZS01M2U3LTQ3YmYtOWUxYS00OTY2ZmUyZjhhYWY=';
  static const BASE_URL = "https://dev.abyad.sa/api/pos/";
// "https://mana.net/wp-json/";

  static String login = BASE_URL + "login";
  static String requestUserData = "request-user-data";
  static String createOrder = BASE_URL + "create-order";
  static String addCustomers = BASE_URL + "customers";
  static String updateLaundary = BASE_URL + "update-laundry";
  static String changePassword = BASE_URL + "change-password";
  static String logout = BASE_URL + "logout";
  static String updateOrderStatus = BASE_URL + "order/update-status/";
  static String paymentType = BASE_URL + "order/payment-type";
  static String splitPayment = BASE_URL + "order/split-payment-type";
  static String paymentBill = BASE_URL + "customer/payment-bill";
  static String itemsBill = BASE_URL + "customer/items-bill";

  static String walletTopUp = BASE_URL + "wallet/topup";
  static const String payLoan = "loans/pay";
  static String getConfigurations = BASE_URL + "configurations";

}
