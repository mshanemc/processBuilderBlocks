public class PBBChatterAllUnfollow {

    @InvocableMethod(label='Have everyone unfollow a record')	
    public static void UnFollowRecord(list<Id> RecordId){
        delete [select Id from EntitySubscription where ParentId =: RecordId];
    }
}