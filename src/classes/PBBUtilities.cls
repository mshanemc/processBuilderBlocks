public with sharing class PBBUtilities {
	
	public static list<string> dedupe(list<string> input){
		set<string> temp = new set<string>(input);
		return new list<string>(temp);
	}

	
}