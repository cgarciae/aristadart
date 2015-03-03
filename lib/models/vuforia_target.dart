part of aristadart.general;


class VuforiaTarget extends Ref
{
    @Field() String result_code;
    @Field() String get href => id != null ? "${localHost}public/objetounity/${id}" : null;
}