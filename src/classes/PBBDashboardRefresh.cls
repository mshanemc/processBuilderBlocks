public with sharing class PBBDashboardRefresh {

	//pass it a dashboard Id.  It'll fail silently if the callout isn't working.
	//feel free to implement your own error logging stuff

	//test DB: 01Zj0000000GQFI

	@InvocableMethod(label='Refresh a dashboard')
	public static void RefreshDashboard(list<string> DashboardIds) {

		//we need something to batch the dashboard stuff.
		list<string> DBBatch = new list<string>();
		list<list<string>> Batches = new list<list<string>>();

		Integer Batchsize = Limits.GetLimitCallouts();

		for (string dashboardId:PBBUtilities.dedupe(DashboardIds)){
			//batch is full, put it in the batch list, blank it for new adds
			if (DBBatch.size()==Batchsize){
				Batches.add(DBBatch);
				DBBatch = new list<string>();
			} 				
			DBBatch.add(dashboardId);
		}

		//add the final batch in
		Batches.add(DBBatch);
		
		//send each batch to the callout method
		for (list<string> batch:batches){
			refreshSomeDashboards(batch, userInfo.getSessionId());
		}

	}

	//has to be handled as an @future transaction because of callout required to reporting REST API
	@future(callout=true)
	public static void refreshSomeDashboards (list<string> dashboardIds, string sessionId){
		
		for (string dbid:dashboardIds){
			String requestUrl = '/services/data/v31.0/analytics/dashboards/'+dbid;
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + requestUrl);
			req.setMethod('PUT');
			req.setHeader('Authorization', 'OAuth ' + sessionId);
			req.setBody('{}');
			system.debug(req);

			HTTPResponse res = http.send(req);
			String output = res.getBody();
			System.debug(output);


		}
	}

	

	
}