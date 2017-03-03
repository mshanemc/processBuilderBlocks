/*
Testing for user disablement
If this worked properly it would create 20 users, mark them as inactive and then check that they are actually inactive
Passing the created test users to the apex class to disable them is the hangup
*/
@isTest
Private class TestDisablingUsers {
    
@isTest static void testDisableUser() {
        integer userCount=20;
        //create users
        list<user> users = createUsers(userCount);
        //create the inner class object and add to list
        list<EnableDisableUser.DisableRequest> uids = new list<EnableDisableUser.DisableRequest>();
        for (user u:users){
        EnableDisableUser.DisableRequest uid = new EnableDisableUser.DisableRequest();
        //create group of users to disable or maybe just go ahead and disable them 1 by 1
        //uid = u;
        //uid.Id = u.UserId;
        uid.UserId = u.Id;
        uid.IsActive = false;
        uids.add(uid);
        //DisableUser.DisableUsers(uid);
        }

        //call the invocable method
        test.startTest();
        //.....or possibly disable all users here
        EnableDisableUser.DisableUsers(uids);
        test.stopTest();

        //asserts--check the user count and make sure it is correct (this needs to be improved to only cound
        list<User> TUs = [select Id 
            from User
            where IsActive=false AND Email Like '%testDisableUser%'];
            
        system.assertEquals(userCount, TUs.size()); 
        
    }

    //test helper
    public static list<user> createUsers(integer numberOfUsers){
        list<user> users = new list<user>();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        
        for (integer i=0; i<numberOfUsers; i++){
            string x = string.valueOf(i);
            User u = new User(Alias = 't'+x, Email='standarduser'+x+'@testDisableUser.msm', 
            EmailEncodingKey='UTF-8', LastName='Testing' + x, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+x+'@testDisableUser.msm');
            users.add(u);
        }

        insert users;
        return users;
    }

}