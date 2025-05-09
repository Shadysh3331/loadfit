abstract class RouteExceptions {}

class RemoteException extends RouteExceptions {
  String errorMessage;

  RemoteException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class LocalException extends RouteExceptions {
  String errorMessage;

  LocalException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}
