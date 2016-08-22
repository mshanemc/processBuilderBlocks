/*
If this class is giving you problems, the most likely cause is your org-specific settings.  

Check validation rules and required fields for account and user, the objects that are used for testing.
If needed, modify the last two methods here (for test data creation) to follow your org's rules


*/

@isTest
private class TestPBB {
	
	@isTest static void testLeadReassign(){
		list<Id> leadIds = getIds(createLeads(5));

		test.startTest();
		PBBRunAssignmentRules.ReRunAssignmentRules(leadIds);
		test.StopTest();

		
	}


	@isTest static void testChatterFollow() {
		list<user> users = createUsers(2);


		list<PBBChatterFollow.ChatterFollow> CFs = new list<PBBChatterFollow.ChatterFollow>();	

		user admin = createAdmin();

		system.runAs(admin){
			list<id> acctIds = getIds(createAccts(2));

		

			
			for (user u:users){
				for (id acctId:acctIds){
					PBBChatterFollow.ChatterFollow CF = new PBBChatterFollow.ChatterFollow();
					CF.UserId = u.Id;
					CF.RecordId = acctId;
					CFs.add(CF);
				}
			}	

			test.startTest();	
			PBBChatterFollow.FollowRecord(CFs);
			test.stopTest();
		
			list<EntitySubscription> ESs = [select Id from EntitySubscription where parentId in: acctIds];
			system.assertEquals(4, ESs.size());
		}


	}

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
    
    @isTest static void testLock(){
		list<id> acctIds = getIds(createAccts(5));
		system.debug(acctIds);
		PBBLock.LockRecord(acctIds);
    }

    @isTest static void testUnLock(){
		list<id> acctIds = getIds(createAccts(5));
		PBBUnLock.UnLockRecord(acctIds);
    }

	@isTest static void testPBBDelete() {				
		list<id> acctIds = getIds(createAccts(5));
		//there should be 5 accounts created
		list<account> queriedAccts = [select Id from Account];
		system.assertEquals(5, queriedAccts.size());

		PBBDelete.DeleteRecord(acctIds);
		
		//there should be 0 accounts...all deleted
		queriedAccts = [select Id from Account];
		system.assertEquals(0, queriedAccts.size());

	}

	@isTest static void testPBBDBReresh(){
		map<string, string> headers = new map<string, string>(); 
		headers.put('Content-Type', 'application/json');
		//'Content-Type', 'application/json'
		Test.setMock(HttpCalloutMock.class, new PBBCalloutMocks(200, 'OK', '{"foo":"bar"}', headers));

		list<string> fakeDBs = fakeDBGenerator(300);

		test.startTest();
		PBBDashboardRefresh.RefreshDashboard(fakeDBs);
		test.stopTest();
	}

	//test helpers below

	public static list<string> fakeDBGenerator(integer recordCount){
		
		list<string> output = new list<string>();
		for (integer i=0; i<recordCount; i++){
			output.add('ADF0000000'+string.valueOf(i));
		}
		return output;
	}
	

	private static PermissionSet createPermSet(){
		PermissionSet PS = new PermissionSet();
		PS.Label = 'perm set label';
		PS.Name = 'PermSetName';
		PS.Description = 'blah';
		insert PS;
		return PS;

	}

	public static list<id> getIds (list<sobject> sobjects){
		list<id> output = new list<id>();
		for (sobject SO:sobjects){
			output.add((id)So.get('Id'));
		}
		return output;
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

	public static list<lead> createLeads(integer numberOfLeads){
		list<lead> output = new list<lead>();

		for (integer i=0; i<numberOfLeads; i++){
			lead L = new lead(LastName = 'LeadName' + string.valueof(i), Company='Company'+string.valueof(i));
			output.add(L);
		}

		insert output;
		return output;
	}

	public static user createAdmin(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

		// create User
        User u = new User();

        u.FirstName = 'A';
        u.LastName = 'S';
        u.Email = 'test@test.com';
        u.Username = 'astest@test.com';
        u.Alias = 'astest';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';

        insert u;
        system.debug('u contains ' + u);
        return u;
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