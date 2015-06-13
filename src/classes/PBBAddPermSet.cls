public with sharing class PBBAddPermSet {
	
	@InvocableMethod(label='Add Permission Set to User')
	public static void AddPermSet(list<AddPermSetRequest> requests) {

		list<PermissionSetAssignment> output = new list<PermissionSetAssignment>();

		for (AddPermSetRequest request:requests){
			system.debug(request);
			AddPermLater(request.UserId, request.PermissionSetId);			
		}
	}

	public class AddPermSetRequest {
		@InvocableVariable(required=true label='Permission Set Id')
		public Id PermissionSetId;

		@InvocableVariable(required=true label='User Id')
		public Id UserId;
	}

	//has to be handled as an @future transaction because the mixed DML issue!
	@future
	public static void AddPermLater (string userid, string permId){
		PermissionSetAssignment PSA = new PermissionSetAssignment();
		PSA.AssigneeId = userid;
		PSA.PermissionSetId = permId;

		insert PSA;
	}

}

