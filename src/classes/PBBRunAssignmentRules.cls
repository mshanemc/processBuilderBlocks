public with sharing class PBBRunAssignmentRules {
	

	@InvocableMethod(label='Re-run Assignment Rules on Lead')
	public static void ReRunAssignmentRules(list<string> recordIds) {
		
		set<id> LeadIds = new set<id>();

		for (string recordId:recordIds){
			id rid=id.valueOf(recordId);

			Schema.SObjectType sot=  rid.getSObjectType();
			if (sot == Lead.sObjectType){
				LeadIds.add(rid);
			} 
		}

		if (!LeadIds.isempty()){
			//ID jobID = System.enqueueJob(new PBBLeadReassignQueueable(LeadIds));
			if (system.isFuture()) {
				system.debug('running in future already; exiting!');
				return;
			} else {
				system.debug('starting future call');
				futureLeadReassign(LeadIds);
				
			}
		}				
	}

	@future
	public static void futureLeadReassign(Set<ID> ReassignSet) { 

		system.debug('in the future, doing lead reassignment');

		List<Lead> UpdList = [SELECT Id FROM Lead WHERE Id IN: ReassignSet];

		for (Lead l:UpdList) {
			Database.DMLOptions dmo = new Database.DMLOptions();
        	dmo.assignmentRuleHeader.useDefaultRule = true;                                         // use leadAssignment rules when updating
        	l.setOptions(dmo);
  	  	}

  	  	system.debug(UpdList);
 
    	update(UpdList);
	}

	

}