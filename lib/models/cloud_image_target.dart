part of aristadart.general;

class CloudImageTargetDb extends Ref
{
    @ReferenceId() String imageId;
    @Field() String targetId;
}

class CloudImageTarget
{
    @Id() String id;
    @ReferenceId() String imageId;
    @Field() String targetId;
}


