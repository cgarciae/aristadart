library fetch;

RegExp varRegExp = new RegExp(r':([^/]+)');
String singleVar = r'([^/]+)';

Iterable zipWith (Iterable ea, Iterable eb, dynamic f (dynamic a, dynamic b))
{
    var enuA = ea.iterator;
    var enuB = eb.iterator;
    
    List list = [];
    
    while (enuA.moveNext() && enuB.moveNext())
    {
        list.add(f (enuA.current, enuB.current));
    }
    
    return list;
}

class Fetch
{
    List<Route> fetchers;
}

class Route
{
    String path;
    Function request;
    Function onResponse;
    RegExp pathRegExp;
    
    Route (this.path)
    {
        pathRegExp = new RegExp (path.replaceAllMapped(varRegExp, (m) => singleVar));
    }
    
    
}
