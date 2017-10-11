public class PBBChatterUnFollow {

    @InvocableMethod(label='Have a user unfollow a record')	
    public static void UnFollowRecord(list<ChatterFollow> CFs) {
        
        set<ID> followIds  = new set<Id>();
        set<ID> followerIds  = new set<Id>();
        set<string> crapList = new set<string>();
        
        for (ChatterFollow CF:dedupe(CFs)){
            followIds.add(CF.RecordId);
            followerIds.add(CF.UserId);
            crapList.add(string.valueOf(CF.RecordId) + string.valueof(CF.UserId));
        }
        
        list<EntitySubscription> ESs = [select id, parentId, SubscriberId from EntitySubscription where subscriberId in:followerIds and parentId in:followIds limit 5000];
		list<EntitySubscription> stuffToDelete = new list<EntitySubscription>();
        
        for (EntitySubscription ES:ESs){
            if (craplist.contains(string.valueOf(ES.parentId) + string.valueof(ES.SubscriberId))){
                stuffToDelete.add(ES);
            }
        }
        delete StuffToDelete;
    }
    
    public class ChatterFollow {

		@InvocableVariable(required=true label='Record Id')
		public Id RecordId;

		@InvocableVariable(required=true label='User Id')
		public Id UserId;

	}
    
    public static list<ChatterFollow> dedupe(list<ChatterFollow> input){
		set<ChatterFollow> temp = new set<ChatterFollow>(input);
		return new list<ChatterFollow>(temp);
	}

}