public with sharing class PBBAddPermSet {
	
	@InvocableMethod(label='Add Permission Set to User')
	public static void AddPermSet(list<AddPermSetRequest> requests) {

		list<string> output = new list<string>();

		for (AddPermSetRequest request:dedupe(requests)){
			//system.debug(request);
			//future methods can only accept primitives, so we serialize to a list of string
			output.add(JSON.serialize(request));
		}

		AddPermsLater(output);

	}

	//what Process Builder/Flow Builder can reference for the input variables
	public class AddPermSetRequest {
		@InvocableVariable(required=true label='Permission Set Id')
		public Id PermissionSetId;

		@InvocableVariable(required=true label='User Id')
		public Id UserId;
	}

	public static list<AddPermSetRequest> dedupe(list<AddPermSetRequest> input){
		set<AddPermSetRequest> temp = new set<AddPermSetRequest>(input);
		return new list<AddPermSetRequest>(temp);
	}

	//has to be handled as an @future transaction because the mixed DML issue!
	@future
	public static void AddPermsLater (list<string> requests){
		list<PermissionSetAssignment> PSAs = new list<PermissionSetAssignment>();

		for (string request:requests){
			//turn it back into the request object per Quinton Wall
			//https://developer.salesforce.com/blogs/developer-relations/2013/06/passing-objects-to-future-annotated-methods.html
			AddPermSetRequest APSR = (AddPermSetRequest)JSON.deserialize(request, AddPermSetRequest.class);
			
			PermissionSetAssignment PSA = new PermissionSetAssignment();
			PSA.AssigneeId = APSR.UserId;
			PSA.PermissionSetId = APSR.PermissionSetId;

			PSAs.add(PSA);			
		}

		insert PSAs;
	}

}