public with Sharing class  PBBChatterFollow {
	
	@InvocableMethod(label='Have a user follow a record')	
	public static void FollowRecord(list<ChatterFollow> CFs) {

		//the following two lines fail silently if the request is nonsense.
		//check that chatter is on
		if ( ! Schema.SObjectType.User.isFeedEnabled() ) {
			system.debug('user does not have chatter');
			return;
		}
		//check that the object in question has a feed
		if ( ! CFs[0].RecordId.getSobjectType().getDescribe().isFeedEnabled() ) {
			system.debug('object does not have chatter');
			system.debug(CFs[0].RecordId);			
			return;
		}


		list<EntitySubscription> ESs = new list<EntitySubscription>();

		for (ChatterFollow CF:dedupe(CFs)){
			EntitySubscription ES = new EntitySubscription();
			ES.subscriberId = CF.UserId;
			ES.parentId = CF.RecordId;			
			ESs.add(ES);
		}

		insert ESs;

	
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