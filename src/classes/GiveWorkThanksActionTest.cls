@isTest
private class GiveWorkThanksActionTest {

	@isTest(SeeAllData = true) static void testBadgeCreation() {
		// Implement test code
		List<GiveWorkThanksAction.GiveWorkThanksRequest> requests = new List<GiveWorkThanksAction.GiveWorkThanksRequest>();
		List<User> users = [SELECT Id, Name, IsActive, UserType from User WHERE IsActive = true AND UserType='Standard' LIMIT 2];
		User firstUser = users[0];
		User secondUser = users[1];
		WorkBadgeDefinition workBadgeDef = [SELECT Id, Name FROM WorkBadgeDefinition  LIMIT 1];
		String workBadgeName = workBadgeDef.Name;
		String testMessage1 = 'Test Message 1: Thank You';
		String testMessage2 = 'Test Message 2: You\'re Welcome';

		GiveWorkThanksAction.GiveWorkThanksRequest thankYou = new GiveWorkThanksAction.GiveWorkThanksRequest();
		thankYou.giverId = firstUser.Id;
		thankYou.receiverId = secondUser.Id;
		thankYou.badgeName = workBadgeName;
		thankYou.thanksMessage = testMessage1;
		requests.add(thankYou);

		GiveWorkThanksAction.GiveWorkThanksRequest youreWelcome = new GiveWorkThanksAction.GiveWorkThanksRequest();
		youreWelcome.receiverId = firstUser.Id;
		youreWelcome.giverId = secondUser.Id;
		youreWelcome.badgeName = workBadgeName;
		youreWelcome.thanksMessage = testMessage2;
		requests.add(youreWelcome);

		GiveWorkThanksAction.giveWorkBadgeActionsBatch(requests);

		Integer result1 = [SELECT Count() From FeedItem where Type = 'RypplePost' and ParentId = :firstUser.Id];
		System.AssertNotEquals(result1, 0);

		Integer result2 = [SELECT Count() From FeedItem where Type = 'RypplePost' and ParentId = :secondUser.Id];
		System.AssertNotEquals(result2, 0);

	}


}