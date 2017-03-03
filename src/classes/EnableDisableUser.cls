/*
Enables or Disables a user.
*/
public with sharing class EnableDisableUser {
    
    @InvocableMethod(label='Toggle A User')
    public static void DisableUsers(list<DisableRequest> requests) {

        list<string> output = new list<string>();

        for (DisableRequest request:dedupe(requests)){
            //system.debug(request);
            //future methods can only accept primitives, so we serialize to a list of string
            output.add(JSON.serialize(request));
        }

        DisableLater(output);

    }

    //Give Process Builder/Flow Builder something to reference for input variables
    public class DisableRequest {
        @InvocableVariable(required=true label='User Id')
        public Id UserId;
        @InvocableVariable(required=true label='User Is Active')
        public boolean IsActive;

    }

    public static list<DisableRequest> dedupe(list<DisableRequest> input){
        set<DisableRequest> temp = new set<DisableRequest>(input);
        return new list<DisableRequest>(temp);
    }

    //has to be handled as an @future transaction because the mixed DML issue!
    @future
    public static void DisableLater (list<string> requests){
    list<User> uids = new list<User>();
            for (string request:requests){
            //turn it back into the request object as required for annotated methods
            //https://developer.salesforce.com/blogs/developer-relations/2013/06/passing-objects-to-future-annotated-methods.html
            DisableRequest uid = (DisableRequest)JSON.deserialize(request, DisableRequest.class);

            User u = new User();
            u.Id = uid.UserId;
            u.IsActive = uid.IsActive;

            uids.add(u);            
            }
        update uids;
    }
}