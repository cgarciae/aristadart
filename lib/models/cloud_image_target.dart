part of aristadart.general;

class CloudTarget2 extends Ref
{
    @Field() String get href => localHost + 'cloudTarget/$id';
    @Field() FileDb image;
    @Field() DbObj target;
}

class CloudImageTarget
{
    @Id() String id;
    @ReferenceId() String imageId;
    @Field() String targetId;
}


