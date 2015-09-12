global without sharing class GiveWorkThanksAction {

	@InvocableMethod(label='Give a Thanks Badge')
	global static void giveWorkBadgeActionsBatch(List<GiveWorkThanksRequest> requests) {
		for(GiveWorkThanksRequest request: requests){
			giveWorkBadgeAction(request);
		}
	}

	public static void giveWorkBadgeAction(GiveWorkThanksRequest request) {
		WorkThanks newWorkThanks = new WorkThanks();

				newWorkThanks.GiverId = request.giverId;
				newWorkThanks.Message = request.thanksMessage;
				newWorkThanks.OwnerId = request.giverId;

		insert newWorkThanks;


		WorkBadge newWorkBadge = new WorkBadge();

				// newWorkBadge.DefinitionId should be set to the ID for the Competitor Badge within this Org
				WorkBadgeDefinition workBadgeDef = [SELECT Id,Name FROM WorkBadgeDefinition WHERE Name = :request.badgeName Limit 1];

				newWorkBadge.DefinitionId = workBadgeDef.Id;
				newWorkBadge.RecipientId = request.receiverId;
				newWorkBadge.SourceId = newWorkThanks.Id ;
				//newWorkBadge.GiverId = request.giverId;

		insert newWorkBadge;

		WorkThanksShare newWorkThanksShare = new WorkThanksShare();

				newWorkThanksShare.ParentId = newWorkThanks.Id ;
				newWorkThanksShare.UserOrGroupId = request.receiverId;

				newWorkThanksShare.AccessLevel = 'Edit';
				insert newWorkThanksShare;

		FeedItem post = new FeedItem();

				post.ParentId = request.receiverId;
				post.CreatedById = request.giverId;
				post.Body = request.thanksMessage;
				post.RelatedRecordId = newWorkThanks.Id ;
				post.Type = 'RypplePost';

		insert post;

	}

	global class GiveWorkThanksRequest {
		@InvocableVariable(label='Giver Id' required=true)
		global Id giverId;

		@InvocableVariable(label='Receiver Id' required=true)
		global Id receiverId;

		@InvocableVariable(label='Thanks Message' required=true)
		global String thanksMessage;

		@InvocableVariable(label='Badge Name' required=true)
		global String badgeName;
	}
}