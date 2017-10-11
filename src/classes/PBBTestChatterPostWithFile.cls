@isTest
public with sharing class PBBTestChatterPostWithFile {

	@IsTest(SeeAllData=true)
  public static void testChatterPost()
    {
        Integer recordCount = 1;
        List<Account> accts = new List<Account>();
        accts.add(new Account(Name = 'Test1'));
        upsert accts;
        System.assertEquals(recordCount, accts.size());

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        upsert contentVersion;
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument LIMIT 1];
        Id targetfileId = docs[0].Id;

        CollaborationGroup newGroup = new CollaborationGroup();
        newGroup.Name = 'Public Test Group';
        newGroup.CollaborationType = 'Public';
        upsert newGroup;

        List<PostToChatter.PostChatterWithFileRequest> reqs = new List<PostToChatter.PostChatterWithFileRequest>();

        for (Account acct : accts)
        {
            PostToChatter.PostChatterWithFileRequest req = new PostToChatter.PostChatterWithFileRequest();
            req.recordId = acct.id;
            req.fileId = targetfileId;
            req.groupId = newGroup.Id;
            req.message = 'Post in chatter with file';
            reqs.add(req);
        }

        List<PostToChatter.PostChatterWithFileResult> results = PostToChatter.postWithExistingFile(reqs);
        System.assert(results.size() > 0);
    }
}