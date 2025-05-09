abstract class RouteFailures {}

class RemoteFailures extends RouteFailures {
  String errorMessage;

  RemoteFailures(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class LocalFailures extends RouteFailures {
  String errorMessage;

  LocalFailures(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}
