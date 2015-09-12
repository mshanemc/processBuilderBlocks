public class PBBApexDebug {

    @InvocableMethod(label='Add a debug statement')
	public static void AddDebug(list<string> comments) {

		for (string comment:comments){
			system.debug(comment);	
		}		
	}
}