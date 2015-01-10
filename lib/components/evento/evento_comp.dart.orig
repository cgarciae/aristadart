part of aristaclient;


@ng.Component
(
    selector : "ccc",
    template: '{{text}} Text: <input type="text" ng-model="text"'
)
class CCC
{
    @ng.NgAttr('text')
    String text;
    
    CCC ();
}


@ng.Component
(
    selector : "bbb",
    template: '<ccc text="c.text"></bbb> {{c.text}}'
)
class BBB
{
    @ng.NgTwoWay('c')
    CCC c;
    
    BBB (this.c);
}

@ng.Component
(
    selector : "aaa",
    template: '{{b.c.text}} <bbb c="b.c"></bbb>'
)
class AAA
{
    

    BBB b;
    
    AAA ()
    {
        b = new BBB(new CCC()..text="Hola");
    }
    
    String text;
}



@ng.Component
(
    selector : "evento-comp",
    templateUrl: 'models/evento/evento.html'
)
class EventoComponent
{
    
    EventoCL evento = new EventoCL ();
    List<int> ids = [];
    
    EventoComponent ()
    {
        LoadIDs().then((ListInt listInt) => this.ids = listInt.list);
    }
    
    Future<ListInt> LoadIDs ()
    {
        var url = localHost + "/all/ids";
        
        return dom.HttpRequest.getString(url)
                .then ((String json) {
            print (json);
            return decodeJson(json, ListInt);
            });
    }

    void LoadData ()
    {
        
        var url = "http://localhost:8080/id/${evento.id}";

        dom.HttpRequest
            .getString(url)
            .then((String s) {
                print (s);
                EventoCL ev = decodeJson (s, EventoCL);
                evento = ev;
            });
    }
    
    void SaveData ()
    {
        
        var url = localHost + "/evento/add";

        dom.HttpRequest request = new dom.HttpRequest(); // create a new XHR
        
        
          
          // add an event handler that is called when the request finishes
          request.onReadyStateChange.listen((_) {
            if (request.readyState == dom.HttpRequest.DONE &&
                (request.status == 200 || request.status == 0)) {
              // data saved OK.
              print(request.responseText); // output the response from the server
            }
          });

          // POST the data to the server
          request.open("POST", url);
          
          request.setRequestHeader("Content-Type", "application/json");

          String jsonData =  encodeJson(evento);
          request.send(jsonData); // perform the async POST
    }
    
    void NuevaVista ()
    {
        evento.experiencia.vistas.add(new ViewCL());
    }
    
    void NuevaElemento (ViewCL vista)
    {
        vista.muebles.add(new ElementoConstruccion());
        
    }
    
}

