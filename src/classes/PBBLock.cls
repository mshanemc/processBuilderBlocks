public with sharing class PBBLock {
	
	@InvocableMethod(label='Lock a record')
	public static void LockRecord(list<string> recordIds) {
		Approval.lock(PBBUtilities.dedupe(recordIds));
	}
}