public with sharing class PermChanges {
	
	public static void MainMethod(list<Permission_Change__c> PCs){	

		list<Permission_Change__c> Adds = new list<Permission_Change__c>();
		list<Permission_Change__c> Deletes = new list<Permission_Change__c>();

		//categorize into adds vs. deletes
		for (Permission_Change__c PC:PCs){
			if (PC.Action__c == 'Add Permission'){
				Adds.add(PC);
			} else if (PC.Action__c == 'Remove Permission'){
				Deletes.add(PC);
			}
		}

		system.debug('add size is ' + Adds.size());
		system.debug('delete size is ' + Deletes.size());

		ProcessAdd(Adds);
		ProcessDeletes(Deletes);
	}
	
	public static void ProcessAdd(list<Permission_Change__c> Adds){
		list<PermissionSetAssignment> AddPSAs = new list<PermissionSetAssignment>();
		//loop through the adds, creating new records to insert
		for (Permission_Change__c PC:Adds){
			AddPSAs.add(new PermissionSetAssignment(
				AssigneeId = PC.UserID__c,
				PermissionSetId = PC.Permission_Set_ID__c 
				)
			);
		}
		
		Database.SaveResult[] results = Database.insert(AddPSAs, false);
		//TODO: some errors are better than others.
	}

	public static void ProcessDeletes(list<Permission_Change__c> Deletes){
		list<PermissionSetAssignment> DeletePSAs = new list<PermissionSetAssignment>();
		//loop through the deletes, using an @future method to handle bulk
		for (Permission_Change__c PC:Deletes){
			futureDelete(PC.UserID__c, Pc.Permission_Set_ID__c);
		}
		
	}

	//future method for deletes
	@future
	public static void FutureDelete(string userId, string PermissionSetId){
		delete [select Id from PermissionSetAssignment 
			where AssigneeId =: userId and PermissionSetId=:PermissionSetId];
	}


}