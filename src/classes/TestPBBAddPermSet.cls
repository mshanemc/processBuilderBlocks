@isTest
private class TestPBBAddPermSet {
	
	//tests the class across a whole bunch of permissions being added.
	@isTest static void testBulk() {
		integer userCount=200;
		//create users
		list<user> users = createUsers(userCount);
		//create a permission set
		PermissionSet PS = createPermSet();
		//create the inner class object and add to list
		list<PBBAddPermSet.AddPermSetRequest> PSRs = new list<PBBAddPermSet.AddPermSetRequest>();
		for (user u:users){
			PBBAddPermSet.AddPermSetRequest PSR = new PBBAddPermSet.AddPermSetRequest();
			PSR.UserId = u.id;
			PSR.PermissionSetId = PS.id;
			PSRS.add(PSR);
		}

		//call the invocable method
		test.startTest();
		PBBAddPermSet.AddPermSet(PSRs);
		test.stopTest();

		//asserts--check the users and verify that they have the permission that you think they do
		list<PermissionSetAssignment> PSAs = [select Id, AssigneeId, PermissionSetId 
			from PermissionSetAssignment
			where AssigneeId in: users and PermissionSetId =: PS.Id];

		system.assertEquals(userCount, PSAs.size()); 
		
	}

	private static PermissionSet createPermSet(){
		PermissionSet PS = new PermissionSet();
		PS.Label = 'perm set label';
		PS.Name = 'PermSetName';
		PS.Description = 'blah';
		insert PS;
		return PS;

	}

	private static list<user> createUsers(integer numberOfUsers){
		list<user> users = new list<user>();

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

		
		for (integer i=0; i<numberOfUsers; i++){
			string x = string.valueOf(i);
			User u = new User(Alias = 't'+x, Email='standarduser'+x+'@testPBBPermSet.msm', 
            EmailEncodingKey='UTF-8', LastName='Testing' + x, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+x+'@testPBBPermSet.msm');
			users.add(u);
		}

		insert users;
		return users;
	}

}