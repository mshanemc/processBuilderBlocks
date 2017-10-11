/*
* Patterned after: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableVariable.htm
* Chatter with file: https://salesforce.stackexchange.com/questions/117659/upload-a-file-to-a-chatter-feed-in-apex-api-36
*/
global class PostToChatter {

    @InvocableMethod(label='Post to Chatter with an Existing File')
    public static List<PostChatterWithFileResult> postWithExistingFile(List<PostChatterWithFileRequest> requests)
    {
        List<PostChatterWithFileResult> results = new List<PostChatterWithFileResult>();
        for (PostChatterWithFileRequest request : requests)
        {
            // Insert a simple post
            String communityId = null;

            //feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;

            // grab the ContentVersion Ids to attach to post
            List<String> fileIdsList = new List<String>();
            List<ContentDocument> versions = [SELECT Id
                                             FROM ContentDocument
                                             WHERE Id = :request.fileId
                                             LIMIT 1];
            for (ContentDocument version : versions)
            {
                fileIdsList.add(version.Id);
            }
            String fileIds = String.join(fileIdsList, ',');

            ConnectApi.FeedElement feedElement = ConnectApiHelper.postFeedItemWithFiles(communityId, request.recordId, request.message, fileIds);

            String feedElementId = feedElement.Id;

            if (request.groupId != null)
            {
                List<CollaborationGroup> grps = [SELECT Id, Name FROM CollaborationGroup WHERE Id = :request.groupId];
                for (CollaborationGroup grp : grps)
                {
                    String groupMention = '{' + grp.Id + '}';

                    ConnectApi.Comment commentRep = ConnectApiHelper.postCommentWithMentions(communityId, feedElementId, groupMention);
                }
            }

            PostChatterWithFileResult result = new PostChatterWithFileResult();
            result.postId = feedElementId;
            result.success = true;
            results.add(result);

        }
        return results;
    }

    global class PostChatterWithFileRequest {
        @InvocableVariable(required=true)
        global ID recordId;

        @InvocableVariable(required=true)
        global ID fileId;

        @InvocableVariable(required=true)
        global ID groupId;

        @InvocableVariable(required=true)
        global String message;
    }

    global class PostChatterWithFileResult {
        @InvocableVariable
        global ID postId;

        @InvocableVariable
        global Boolean success;
    }

    class PostChatterWithFileException extends Exception {}
}