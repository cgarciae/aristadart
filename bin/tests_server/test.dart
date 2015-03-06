library tests;

import 'package:unittest/unittest.dart';


import 'package:redstone/server.dart' as app;
import 'package:redstone/mocks.dart';
import 'package:aristadart/arista.dart';


main() {

  //load handlers in 'services' library
  setUp(() => app.setUp([#arista.server]));

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