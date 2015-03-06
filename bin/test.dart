library tests;

import 'packages/unittest/unittest.dart';


import 'packages/redstone/server.dart' as app;
import 'packages/redstone/mocks.dart';
import 'arista_server.dart';


main() {

  //load handlers in 'services' library
  setUp(() => app.setUp([#aristadart.server]));

  //remove all loaded handlers
  tearDown(() => app.tearDown());

  test("hello service", () 
  {
    //create a mock request
    var req = new MockRequest
    (
        "/testQuery",
        queryParams: 
        {
            'algo' : 'algo',
            'mas' : 'mas'
        }
    );
    
    
    //dispatch the request
    return app.dispatch(req).then((resp) 
    {
      //verify the response
      expect(resp.statusCode, equals(200));
      expect(resp.mockContent, equals("algo mas"));
      
    });
  });

}