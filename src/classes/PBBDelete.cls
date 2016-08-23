public with sharing class PBBDelete {
	
	@InvocableMethod(label='Delete a record')
	public static void DeleteRecord(list<string> recordIds) {
		
		list<sObject> deleteUs = new list<sObject>();

		for (string recordId:PBBUtilities.dedupe(recordIds)){
			Id rId = id.valueOf(recordId);
			sObject so = rid.getSObjectType().newSObject(rid);
			deleteUs.add(so);
		}

		delete deleteUs;
		
	}
}