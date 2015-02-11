part of arista;

class CloudImageTarget
{
    @Id() String id;
    @ReferenceId() String imageId;
    @Field() String targetId;
}


