global class CallGenerateQuotePDF {
    
    @InvocableMethod(label='Generate Quote PDF' description='Generates a quote pdf using the specified quote and template ID')
    global static void invokeQuotePDF(list<GetPDFVariables> requests) {
         for(GetPDFVariables requestObj:requests){ 
        GenerateQuotePDF.GenerateQuoteDocument(requestObj.QuoteId, requestObj.TemplateId);
        }
    }


    //what Process Builder/Flow Builder can reference for the input variables
    global class GetPDFVariables {
    
        @InvocableVariable(required=true label='Quote Id')
        public Id QuoteId;

        @InvocableVariable(required=true label='Template Id')
        public Id TemplateId;
        
    }
}