public with sharing class PBBUnlock {
	
	@InvocableMethod(label='UnLock a record')
	public static void UnLockRecord(list<string> recordIds) {
		Approval.unlock(PBBUtilities.dedupe(recordIds));
	}
}