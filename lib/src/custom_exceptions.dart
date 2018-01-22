class QueryException implements Exception {
  String status;
  String error;
  dynamic properties;
  String message;

  QueryException(this.status, this.error, this.properties) {
    message =
        "Error $status while querying. '$error' with search terms: \n$properties";
  }
}