public with sharing class Blueprint {
	
	//Properties
	public String Output {get; set;}
	public final String Tab = '&#9'; 
	public final String Lbreak = + '<br/>';
	public final String qTriggers = 'select Name, TableEnumOrId from ApexTrigger';
	public final String qValRules = 'select Name, TableEnumOrId from ValidationRule';
	public ToolingApi TApi {get; set;}
	
	public Blueprint() {
		Output = ''; 
		TApi = new ToolingApi();
		bpInit();
	}

	public void bpInit() {
		List<Schema.DescribeSObjectResult> sObjects = new List<Schema.DescribeSObjectResult>();
		List<String> listSObjects = new List<String>();
		listSObjects.addAll(Schema.getGlobalDescribe().keySet());
		sObjects = Schema.describeSObjects(listSObjects); 

		//Trigger container
		Map<String, ToolingAPIWSDL.sObject_x> mapSObjs = new Map<String, ToolingAPIWSDL.sObject_x>();
		ToolingAPIWSDL.QueryResult qrTrgs = TApi.query(qTriggers);

		//Validation Rule container
		Map<String, ToolingAPIWSDL.sObject_x> mapValRules = new Map<String, ToolingAPIWSDL.sObject_x>();
		ToolingAPIWSDL.QueryResult qrVRs = TApi.query(qValRules);

		
		//Gather all triggers
		if (qrTrgs.records != null) {
		
			for (ToolingAPIWSDL.sObject_x qrTrg : qrTrgs.records) {
				mapSObjs.put(qrTrg.Name, qrTrg);
			}
		}

		//Main loop
		for (Schema.DescribeSObjectResult sObj : sObjects) {

			String sObjName = sObj.getName();

			if (sObjName.isWhitespace())
				continue;

			Out(0, sObj.getName());

			//Fields
			Out(1, 'Fields:');
			for (Schema.SObjectField sf : sObj.fields.getMap().values()) {
				Out(2, sf.getDescribe().getName());
			}

			//RecordTypes
			Out(1, 'RecordTypes:');
			for (Schema.RecordTypeInfo rt : sObj.getRecordTypeInfos()) {
				Out(2, rt.getName());
			}

			//Triggers
			Out(1, 'Triggers:');
			for (ToolingAPIWSDL.sObject_x qrTrg : mapSObjs.values()) {
				if (qrTrg.TableEnumOrId == sObjName) {
					Out(2, qrTrg.Name); 
				}
			}

			//End sObj
			Out(0, '');
		}	
	} 

	//Tools
	public void Out(integer tabLevels, string text) {
		
		String tabs = '';

		for(Integer i = 0; i < tabLevels; i++) {
			tabs += Tab;
		}
		
		Output += tabs + text + Lbreak;
	}
}
