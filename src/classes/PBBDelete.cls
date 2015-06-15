public with sharing class PBBDelete {
	
	@InvocableMethod(label='Delete a record')
	public static void DeleteRecord(list<string> recordIds) {

		list<string> objTypes = new list<string>();
		list<sObject> deleteUs = new list<sObject>();

		for (string recordId:recordIds){
			//for each recordId, find out what that thing is, then add it to our list of stuff to query
			Schema.sObjectType ot = id.valueOf(RecordId).getSObjectType();
			objTypes.add(string.valueOf(ot));
		}

		for (string objtype:objTypes){
			string query = 'select Id from ' + objtype + ' where id in: recordIds';
			list<sobject> slice = database.query(query);
			deleteUs.addAll(slice);
		}

		delete deleteUs;



		
	}
}