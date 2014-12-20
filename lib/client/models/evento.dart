part of aristaclient;


@ng.Component
(
    selector : "evento"
)
class EventoCL extends Evento
{

    String descripcion;
    //Override
    @Field () ExperienciaCL experiencia;
}