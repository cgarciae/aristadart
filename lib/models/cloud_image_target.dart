part of aristadart.general;

class CloudTarget extends Ref
{
    @Field() String get href => localHost + '${Col.cloudTarget}/$id';
    @Field() FileDb image;
    @Field() VuforiaTargetRecord target;
}


