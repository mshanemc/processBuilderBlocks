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

	@isTest static void testPBBThunder(){
		list<Id> leadIds = getIds(createLeads(5));

		map<string, string> headers = new map<string, string>();
		headers.put('Content-Type', 'application/json');
		//'Content-Type', 'application/json'
		Test.setMock(HttpCalloutMock.class, new PBBCalloutMocks(200, 'OK', '{"foo":"bar"}', headers));


		PBBThunder.ThunderPostRequest TPR = new PBBThunder.ThunderPostRequest();
		tpr.fields = 'Id';
		tpr.recordId = leadIds[0];
		tpr.token = 'fakeToken';
		tpr.endpoint = 'https://www.salesforce.com/fakeendpoint';

		list<PBBThunder.ThunderPostRequest> TPRs = new list<PBBThunder.ThunderPostRequest>();
		TPRs.add(TPR);

		test.StartTest();

		PBBThunder.SendToThunder(TPRs);
		test.stopTest();

	}

	@isTest static void testChatterFollow() {
		list<user> users = createUsers(2);
		system.assertEquals(2, users.size());

		list<PBBChatterFollow.ChatterFollow> CFs = new list<PBBChatterFollow.ChatterFollow>();
		list<PBBChatterUnFollow.ChatterFollow> CFUs = new list<PBBChatterUnFollow.ChatterFollow>();

		user admin = createAdmin();

		system.runAs(admin){
			list<id> acctIds = getIds(createAccts(2));
			system.assertEquals(2, acctIds.size());

			for (user u:users){
				system.debug('user is ' + u.Id);
				for (id acctId:acctIds){
					system.debug('acct is ' + acctId);

					PBBChatterFollow.ChatterFollow CF = new PBBChatterFollow.ChatterFollow();
                    PBBChatterUnFollow.ChatterFollow CFU = new PBBChatterUnFollow.ChatterFollow();
					CF.UserId = u.Id;
					CF.RecordId = acctId;
					CFs.add(CF);

                    CFU.UserId = u.Id;
                    CFU.RecordId = acctId;
                    CFUs.add(CFU);
				}
			}

			list<account> accountList = [select Id from Account];
			system.assertEquals(2, accountList.size());

			test.startTest();
			PBBChatterFollow.FollowRecord(CFs);
			test.stopTest();

			list<EntitySubscription> ESs = [select Id from EntitySubscription where parentId in: acctIds];
			if (Schema.SObjectType.Account.isFeedEnabled() ){
				system.assertEquals(4, ESs.size());
                //check unfollow behavior
                PBBChatterUnFollow.UnFollowRecord(CFUs);
                list<EntitySubscription> ESs2 = [select Id from EntitySubscription where parentId in: acctIds];
                system.assertEquals(0, ESs2.size());
                //refollow so we can check the all unfollow behavior
                PBBChatterFollow.FollowRecord(CFs);
                list<EntitySubscription> ESs3 = [select Id from EntitySubscription where parentId in: acctIds];
                system.assertEquals(4, ESs3.size());
                //allUnfollow
                list<id> unfollowAllList = new list<id>();
                for (account a:accountList){
                    unfollowAllList.add(a.Id);
                }
                PBBChatterAllUnFollow.UnFollowRecord(unfollowAllList);
                list<EntitySubscription> ESs4 = [select Id from EntitySubscription where parentId in: acctIds];
                system.assertEquals(0, ESs4.size());

            } else {
				system.assertEquals(0, ESs.size());
			}
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

	@isTest static void testPBBSharing(){

		//not goint to actually insert a share because I don't know what sharing a destination org may have on/off
		//horrible test method just to get packageable coverage on the helper methods
		list<lead> leads = createLeads(5);
		list<user> users = createUsers(2);

		PBBSharing.ShareRecordRequest srr = new PBBSharing.ShareRecordRequest();
		srr.RecordId = leads[0].Id;
		srr.UserId = users[0].Id;
		srr.AccessLevel = 'Edit';

		list<PBBSharing.ShareRecordRequest> shares = new list<PBBSharing.ShareRecordRequest>();
		shares.add(srr);

		user admin = createAdmin();

		test.StartTest();
		system.runAs(admin){
			PBBSharing.dedupe(shares);

			Schema.sObjectType ot = SRR.RecordId.getSObjectType();

			PBBSharing.whatsTheAccessFieldCalled(ot);
			PBBSharing.whatsTheIdFieldCalled(ot);
			PBBSharing.getShareTable(ot);


		}
		test.StopTest();

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
        u.Email = 'test'+system.now().getTime()+'@test.com';
        u.Username = 'astest'+system.now().getTime()+'@test.com';
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