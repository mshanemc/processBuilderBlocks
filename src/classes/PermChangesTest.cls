@isTest
private class PermChangesTest {
	
	//TODO: test bad user, bad permissionSet Id, license mismatch issues

	@isTest static void testBatch(){
		//create a user
		user u = createUser('John', 'Doe');
		PermissionSet ps = createPermissionSet();

		insert new Permission_Change__c(
			Action__c = 'Add Permission',
			UserId__c = u.Id,
			Permission_Set_ID__c = ps.Id
		);

		insert new Permission_Change__c(
			Action__c = 'Add Permission',
			UserId__c = u.Id,
			Permission_Set_ID__c = ps.Id
		);

		list<PermissionSetAssignment> PSAs = [select Id, AssigneeId, PermissionSetId
			from PermissionSetAssignment
			where AssigneeId =: u.Id and PermissionSetId =: PS.Id];
		system.assertEquals(1, PSAs.size());

		Test.startTest();
		
		insert new Permission_Change__c(
			Action__c = 'Remove Permission',
			UserId__c = u.Id,
			Permission_Set_ID__c = ps.Id
		);
		
		Test.stopTest();

		//assert that permission set assignment for user u
		PSAs = [select Id, AssigneeId, PermissionSetId
			from PermissionSetAssignment
			where AssigneeId =: u.Id and PermissionSetId =: PS.Id];
		system.assertEquals(0, PSAs.size());

	}


	@isTest static void testAdd() {
		//create a user
		user u = createUser('John', 'Doe');
		PermissionSet ps = createPermissionSet();


		Permission_Change__c PC = new Permission_Change__c(
			Action__c = 'Add Permission',
			UserId__c = u.Id,
			Permission_Set_ID__c = ps.Id
		);

		list<Permission_Change__c> PCs = new list<Permission_Change__c>();
		PCs.add(PC);

		system.assertEquals(1, PCs.size());
		PermChanges.ProcessAdd(PCs);
		//assert that permission set assignment for user u
		list<PermissionSetAssignment> PSAs = [select Id, AssigneeId, PermissionSetId
			from PermissionSetAssignment
			where AssigneeId =: u.Id and PermissionSetId =: PS.Id];
		system.assertEquals(1, PSAs.size());


	}
	
	@isTest static void testRemove() {
		//create a user
		user u = createUser('John', 'Doe');
		PermissionSet ps = createPermissionSet();
		insert new PermissionSetAssignment(AssigneeId=u.Id, PermissionSetId=ps.Id);

		list<PermissionSetAssignment> PSAs = [select Id, AssigneeId, PermissionSetId
			from PermissionSetAssignment
			where AssigneeId =: u.Id and PermissionSetId =: PS.Id];
		system.assertEquals(1, PSAs.size());
		//verifty initial state: that we have one assignment

		Permission_Change__c PC = new Permission_Change__c(
			Action__c = 'Remove Permission',
			UserId__c = u.Id,
			Permission_Set_ID__c = ps.Id
		);

		list<Permission_Change__c> PCs = new list<Permission_Change__c>();
		PCs.add(PC);
		system.assertEquals(1, PCs.size());

		Test.startTest();
		PermChanges.ProcessDeletes(PCs);
		Test.stopTest();

		//assert that permission set assignment for user u
		PSAs = [select Id, AssigneeId, PermissionSetId
			from PermissionSetAssignment
			where AssigneeId =: u.Id and PermissionSetId =: PS.Id];
		system.assertEquals(0, PSAs.size());

	}
	
	public static user createUser(string First, string Last){

		profile p = [select Id from profile where Name = 'System Administrator'];

		//create a user
		string builtEmail = First + 'then'+Last+'@test.com';
		string nn = (First + Last).abbreviate(8);

		user u = new user(FirstName=First, LastName=Last, Username=builtEmail, 
			Email=builtEmail, CommunityNickname=nn, Alias=nn, Emailencodingkey = 'UTF-8',
			Localesidkey = 'en_US', Languagelocalekey = 'en_US', Timezonesidkey = 'America/Chicago', ProfileId=p.Id);
		insert u;
		system.debug(u);
		return u;
	}

	public static PermissionSet createPermissionSet(){
		PermissionSet p = new PermissionSet(
			Name = 'Test_PermSet',
			Label = 'Test PermSet',
			Description = 'Lorem Ipsum'
		);
		insert p;
		system.debug(p);
		return p;

	}
	
}