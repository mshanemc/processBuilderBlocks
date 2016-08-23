/*
Callout security rules still apply...add a remote site setting or it won't work.

*/


public with sharing class PBBThunder {
	
	@InvocableMethod(label='Send record(s) to Thunder / IoT Cloud')
	public static void SendToThunder(list<ThunderPostRequest> requests) {

		list<sObject> AllResults = new list<sObject>();
		system.debug('record count is ' + requests.size());

		set<id> recordIds = new set<id>();

		for (ThunderPostRequest tpr:dedupe(requests)){
			recordIds.add(tpr.recordId);
			system.debug(recordIds);
		}


		//build SOQL
		string q = 'select ' + requests[0].fields + ' from ' + requests[0].recordId.getSObjectType().getDescribe().getName() + ' where Id in ' + inClausify(recordIds); 
		system.debug('the soql: ' + q);
		//do the soql

		list<sObject> stuff = database.query(q);
		system.debug(stuff);

		//json serialize
		string serializedStuff = json.serialize(stuff);
		system.debug(serializedStuff);
		

		//http post
		postToThunder(requests[0].endpoint, requests[0].token, serializedStuff);
		

	}

	public static String inClausify(Set<Id> ids) {
	    String inClause = String.format( '(\'\'{0}\'\')', 
	                         new List<String> { String.join( new List<Id>(ids) , '\',\'') });
	    return inClause;
	}

	@future(callout=true)
	public static void postToThunder (string endpoint, string token, string payload){
		
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(endpoint);
			req.setMethod('POST');
			req.setHeader('Authorization', 'Bearer ' + token);
			req.setHeader('Content-Type', 'application/json');
			req.setBody(payload);
			system.debug(req);

			HTTPResponse res = http.send(req);
			String output = res.getBody();
			System.debug(output);

	}


	public class ThunderPostRequest {
		@InvocableVariable(required=true label='fields' description='comma separated list of fields')
		public string fields;

		@InvocableVariable(required=true label='recordId' description='id of the object you want to send')
		public id recordId;		

		@InvocableVariable(required=true label='authorization token')
		public string token;

		@InvocableVariable(required=true label='endpoint' description='full url beginning with https://')
		public string endpoint;

	}

	public static list<ThunderPostRequest> dedupe(list<ThunderPostRequest> input){
		set<ThunderPostRequest> temp = new set<ThunderPostRequest>(input);
		return new list<ThunderPostRequest>(temp);
	}

}