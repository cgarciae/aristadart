import 'dart:io';
import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import 'package:redstone/server.dart' as app;

import 'package:restonetest/general/aristageneral.dart';

import 'package:gcloud/db.dart';
import 'package:appengine/appengine.dart';
import 'package:restonetest/server/aristaweb.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:di/di.dart' as di;
import 'package:fp/fp.dart';


DatastoreDB get db => context.services.db;

@app.Route('/random')
@Encode()
random ()
{

    var evento = new EventoDB.New
    (
        nombre : "Arista Demo Construccion",
        descripcion : "Descubre el poder de la Realidad Aumetada y Virtual en el sector inmobiliario.",
        imagenPreview : new TextureGUIDB.New
        (
            urlTextura: "HG/Materials/Splash2"
        ),
        experiencia : new ExperienciaDB.New
        (
            vistas : 
            [
                new ViewDB.ConstruccionRA
                    (
                        modelo: new ObjetoUnity.New
                        (
                            url_objeto: "HG/Prefabs/Plantillas/DemoConstruccion",
                            version: 3
                        ),
                        target: new AristaImageTarget.New
                        (
                            url: "AristaTest",
                            version: 0
                        ),
                        icon: new TextureGUIDB.New
                        (
                            urlTextura: "HG/Materials/App/Galeria",
                            texto: "Realidad Aumentada"
                        ),
                        muebles:
                        [
                            new ElementoConstruccionDB.New
                            (
                                nombre: "Zona Social",
                                titulo: "Zonas Social",
                                urlImagen: "HG/Materials/DemoConstruccion/zonaSocial",
                                texto: "Juegos infantiles, salon social, sauna, turco y gimnasio. Placa recreativa."
                            )
                        ]
                    )
            ]
        )
    );

    return Help.ClearAllOfKind(EventoDB)
        .then(evento.Put);


}

@app.Route('/evento/add', methods: const[app.POST])
@Encode()
addUser(@Decode() EventoDB evento) {

    return evento.Put();
}

@app.Route('/id/:id')
@Encode()
getId (int id)
{
    return Help
            .FindId(EventoDB, id)
            .then (Help.Build);
}

@app.Route('/all/ids')
@Encode()
AllIds ()
{
    return Help
            .All(EventoDB)
            .then((List<EventoDB> eventos) => 
                new ListInt()..list = eventos
                    .map ((Evento evento) => evento.id)
                    .toList()
             );
}


@app.Route('/test')
@Encode()
test ()
{
    
    var t = new TS ()..field = "TS";
    
    return t.Put();
}

main() 
{

    app.setShelfHandler
    (
        createStaticHandler
        (
            "build/web",
            defaultDocument: "index.html",
            serveFilesOutsidePath: true
        )
    );
    app.setupConsoleLog();
    app.addPlugin(getMapperPlugin());
    app.setUp();
    runAppEngine(app.handleRequest).then((_)
    {
        
        
    });
}