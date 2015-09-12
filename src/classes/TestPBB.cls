/*
If this class is giving you problems, the most likely cause is your org-specific settings.  

Check validation rules and required fields for account and user, the objects that are used for testing.
If needed, modify the last two methods here (for test data creation) to follow your org's rules


*/

@isTest
private class TestPBB {
	
	//tests the class across a whole bunch of permissions being added.
	@isTest static void testBulkPermSet() {
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

    @isTest static void testDebug(){
    	list<string> comments = new list<string>();
        comments.add('hello');
        comments.add('world');
        system.debug(comments);
        
        test.startTest();
        PBBApexDebug.AddDebug(comments);
        test.stopTest();
    }
    
	@isTest static void testPBBDelete() {		
		list<account> accts = createAccts(5);
		list<id> acctIds = new list<id>();
		for (account a:accts){
			acctIds.add(a.id);
		}

		//there should be 5 accounts created
		list<account> queriedAccts = [select Id from Account];
		system.assertEquals(5, queriedAccts.size());

		PBBDelete.DeleteRecord(acctIds);
		
		//there should be 0 accounts...all deleted
		queriedAccts = [select Id from Account];
		system.assertEquals(0, queriedAccts.size());

	}

	private static PermissionSet createPermSet(){
		PermissionSet PS = new PermissionSet();
		PS.Label = 'perm set label';
		PS.Name = 'PermSetName';
		PS.Description = 'blah';
		insert PS;
		return PS;

	}

	public static list<account> createAccts(integer numberOfAccounts){
		list<account> output = new list<account>();

		for (integer i=0; i<numberOfAccounts; i++){
			account a = new Account(Name = 'Account' + string.valueof(i));
			output.add(a);
		}

		insert output;
		return output;
	}

	public static list<user> createUsers(integer numberOfUsers){
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