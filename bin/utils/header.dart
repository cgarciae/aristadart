part of aristadart.server;

class Header {
  final String header;
  const Header ([this.header]);
}

const Header Authorization = const Header ("authorization");

headersPlugin(app.Manager manager) {
  manager.addParameterProvider(Header, (Header metadata, Type type, String handlerName, String paramName, app.Request req, injector) {
    var header = metadata.header != null? metadata.header: paramName;
    return req.headers[header];
  });
}