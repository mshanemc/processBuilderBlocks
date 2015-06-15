Apex classes with invocable methods to allow Process Builder to do more broadly applicable stuff

<a href="https://githubsfdeploy.herokuapp.com?owner=mshanemc&repo=processBuilderBlocks">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Contents:
###Delete (PBBDelete)

**Why**: the thing you've always wanted to do from declarative workflow!

* pass it a record Id, and whatever that is gets deleted
* doesn't check for delete permissions or anything like that
* doesn't handle any errors that may occur
* use with caution.  Your process could have users deleting themselves and crazy stuff like that.

###"Manually" share records (PBBSharing)

**Why**: you have sharing rules that are more complex than what the declarative sharing rules provide for

 * pass it a record Id, a user/group id, and an optional access level and it creates the sharing
 * known to support custom objects and some permutations of account (there's lots of complexity on account and I haven't tested them all)
 * I didn't write a test for this one--there's not guarantee that an org will have any __c custom object that this stuff depends on.

###Assign Permission Sets to Users (PBBAddPermSet)

**Why**: You use permission sets, and assign them based on rules about the user/profile/etc.  Automate that!

 * pass it a permission set id and a user id, and it assigns that permission set to the user 
 * uses an @future method to avoid mixed DML issues
 * There is a test class for this one, because every org will have PermissionSets available. 
 * Because I did the testing, it's all nicely bulkified

###Refresh a Dashboard (PBBDashboardRefresh)

**Why** You want to refresh a dashboard when stuff happens, like refreshing your opportunity dashboard after someone edits an opportunity so that anyone who views it has the latest and greatest data

 * Requires a remote site setup for self-calls (ex: if you're na16.salesforce.com, then there's a remote site for that)
 * no error handling--fails silently if the call gets 401, 404, bad request, limits hit, etc
 * does handle bulk scenarios (built in batching)
 * no tests since I can't programmatically create a dashboard OR make callouts to get your actual dashboards from apex test

 ###Give a Thanks Badge (GiveWorksThanksAction) [credit to David Scruggs!]

 **Why** Give badges when people do something...for example, marking an opportunity closed/won that's above a certain $ amount or getting perfect scores on a customer satisfaction survey.

 * Requires that work.com thanks be enabled (it's free, just turn it on in the setup menu)
 * Specify the badge name, who it's from, the thanks message, and who it's to
 * this creates the thanks and posts it to chatter

