/*
deals with accounts and custom objects
Try not to put this on objects are public read-write! (no sharing table, so error!) :)
Also doesn't handle sharing reasons--they'll all show up as manual.  Feel free to add it if you like.

test sharing to 005j000000CL0tY

*/
public with sharing class PBBSharing {
	

	@InvocableMethod(label='Share Record with User')
	public static void ShareRecordWithUser(list<ShareRecordRequest> requests) {

		list<sObject> shares = new list<sObject>();

		for (ShareRecordRequest SRR:dedupe(requests)){
			if (srr.AccessLevel==null){Srr.AccessLevel = 'Edit'; } //defaulting optional level

			//what are we dealing with here?
			Schema.sObjectType ot = SRR.RecordId.getSObjectType();
			
			//gets a sharing table object from any record
			sobject share = getShareTable(ot).newSObject();

			share.put(whatsTheAccessFieldCalled(ot),  srr.AccessLevel);							
			share.put(whatsTheIdFieldCalled(ot), srr.RecordId);
			share.put('UserOrGroupId', srr.UserId);

			if (string.valueOf(ot)=='Account'){
				share = dealWithAccounts(share, SRR);
			}
			system.debug(share);
			shares.add(share);
		}
		insert shares;		
	}

	public static sobject dealWithAccounts(sobject share, ShareRecordRequest SRR){
		if (srr.AccessLevel!=null){
			//share.put('ContactAccessLevel',  srr.AccessLevel);	
			share.put('OpportunityAccessLevel',  srr.AccessLevel);									
		} else {
			//share.put('ContactAccessLevel',  'Edit');	
			share.put('OpportunityAccessLevel',  'Edit');	
		}
		return share;
	}

	public static string whatsTheAccessFieldCalled(Schema.sObjectType ot){
		if ( string.valueOf(ot).contains('__c') ){
			return 'AccessLevel';
		} else {
			return string.valueOf(ot) + 'AccessLevel';
		}
	}

	public static string whatsTheIdFieldCalled(Schema.sObjectType ot){
		if ( string.valueOf(ot).contains('__c') ){
			return 'ParentID';
		} else {
			return string.valueOf(ot) + 'Id';
		}
	}

	//returns the schema for the sharing table for whatever object you send it
	public static Schema.SObjectType getShareTable(Schema.sObjectType ot){
		system.debug(ot);

		string shareTableName;

		if (string.valueOf(ot).contains('__c')){
			system.debug('custom object');
		 	shareTableName = string.valueOf(ot).removeEnd('c')+'Share';

		} else {
			system.debug('standard object');	
			shareTableName = string.valueOf(ot)+'Share';
		}
		system.debug(shareTableName);
		Schema.SObjectType result = Schema.getGlobalDescribe().get(shareTableName);
		system.debug(string.valueOf(result));

		return result;

	}
	

	public class ShareRecordRequest {
		@InvocableVariable(required=true label='Record Id')
		public Id RecordId;

		@InvocableVariable(required=true label='User or Group Id')
		public Id UserId;

		@InvocableVariable(required=false label='Access Level')
		public string AccessLevel;
	}


	public static list<ShareRecordRequest> dedupe(list<ShareRecordRequest> input){
		set<ShareRecordRequest> temp = new set<ShareRecordRequest>(input);
		return new list<ShareRecordRequest>(temp);
	}
}