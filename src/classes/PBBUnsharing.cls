/**
 * @name PBBUnsharing
 * @description ProcessBuilderBlock class to offer the unsharing functionality
 * @revision
 * Tobotron 26-01-2017 Created class
 */
public with sharing class PBBUnsharing {

	@InvocableMethod(label = 'Unshare record from User or Group')
	public static void unshareRecordFromUserOrGroup(List<UnshareRecordRequest> requests) {

		Map<String, ShareTableHelper> shareTableHelperMap = new Map<String, ShareTableHelper>();

		ShareTableHelper tShareTableHelper = null;
		Schema.sObjectType tObjectType = null;
		String tShareTableName = null;

		for (UnshareRecordRequest aReq : requests) {

			tObjectType = aReq.recordId.getSObjectType();
			tShareTableName = getShareTableName(tObjectType);

			if (shareTableHelperMap.containsKey(tShareTableName)) {
				tShareTableHelper = shareTableHelperMap.get(tShareTableName);
				tShareTableHelper.recordSet.add(aReq);
			} else {
				tShareTableHelper = new ShareTableHelper(tShareTableName, getIdFieldName(tObjectType), new Set<UnshareRecordRequest> {aReq});
				shareTableHelperMap.put(tShareTableName, tShareTableHelper);
			}
		}
		System.debug(LoggingLevel.DEBUG, 'PBBUnsharing.unshareRecordFromUserOrGroup; shareTableHelperMap is: ' + shareTableHelperMap);

		List<sObject> listToDelete = new List<sObject>();

		String tQuery = null;
		ShareTableHelper tShareTableHelperX = null;
		List<sObject> singleObjectList = null;
		Set<UnshareRecordRequest> tRecordSet = null;

		for (String aShareTableName : shareTableHelperMap.keySet()) {

			tShareTableHelperX = shareTableHelperMap.get(aShareTableName);
			System.debug(LoggingLevel.DEBUG, 'PBBUnsharing.unshareRecordFromUserOrGroup; tShareTableHelperX is: ' + tShareTableHelperX);
			
			tQuery = 'SELECT Id FROM ' + aShareTableName + ' WHERE RowCause = \'Manual\'' + generateWhereClause(tShareTableHelperX);
			System.debug(LoggingLevel.DEBUG, 'PBBUnsharing.unshareRecordFromUserOrGroup; tQuery is: ' + tQuery);

			singleObjectList = Database.query(tQuery);
			System.debug(LoggingLevel.DEBUG, 'PBBUnsharing.unshareRecordFromUserOrGroup; singleObjectList is: ' + singleObjectList);
			
			if (!singleObjectList.isEmpty()) {
				listToDelete.addAll(singleObjectList);
			}
		}

		System.debug(LoggingLevel.DEBUG, 'PBBUnsharing.unshareRecordFromUserOrGroup; listToDelete is: ' + listToDelete);
		if (!listToDelete.isEmpty()) {
			Database.Delete(listToDelete, false);
		}
	}

	private static String getIdFieldName(Schema.sObjectType pObjectType) {
		if (String.valueOf(pObjectType).contains('__c')) {
			return 'ParentID';
		} else {
			return String.valueOf(pObjectType) + 'Id';
		}
	}

	private static String getShareTableName(Schema.sObjectType pObjectType) {

		String shareTableName = null;

		if (String.valueOf(pObjectType).contains('__c')) {
			shareTableName = String.valueOf(pObjectType).removeEnd('c') + 'Share';
		} else {
			shareTableName = String.valueOf(pObjectType) + 'Share';
		}

		return shareTableName;
	}

    private static String generateWhereClause(ShareTableHelper helper) {
    	String tResult = ' AND (';

    	for (UnshareRecordRequest aReq : helper.recordSet) {
    		tResult += ' ( ' + helper.idFieldName + ' = \'' + aReq.recordId + '\' AND  UserOrGroupId = \'' + aReq.userOrGroupId + '\' )';
    		tResult += ' OR ';
    	}
    	// remove last OR
    	tResult = tResult.substring(0, tResult.length() - 4);
    	tResult += ')';

    	return tResult;
    }

	public class UnshareRecordRequest {
		
		@InvocableVariable(required = true label = 'Record Id')
		public Id recordId;

		@InvocableVariable(required = true label = 'User or Group Id')
		public Id userOrGroupId;
	}

	public class ShareTableHelper {
		public String shareTableName;
		public String idFieldName;
		public Set<UnshareRecordRequest> recordSet;

		public ShareTableHelper(String pShareTableName, String pIdFieldName, Set<UnshareRecordRequest> pRecordSet) {
			this.shareTableName = pShareTableName;
			this.idFieldName = pIdFieldName;
			this.recordSet = pRecordSet;
		}
	}
}
