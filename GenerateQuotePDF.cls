public with sharing class GenerateQuotePDF 
{
    //private final Id QuoteId = (Id) ApexPages.currentPage().getParameters().get('quoteId');
    //private final Id QuotePDFTemplateId = (Id)Label.QuotePDFTemplate;

    //public PageReference GenerateQuotePDFAndRedirectToQuotePage()
    //{
    //    GenerateQuoteDocument(QuoteId);
    //    return new PageReference('/' + QuoteId);
    //}

    @future(callout=true) public static void GenerateQuoteDocument(Id quotesId, Id QuotePDFTemplateId)
    {
        String quoteURL = '/quote/quoteTemplateDataViewer.apexp?id=' + quotesId
                + '&headerHeight=190&footerHeight=188&summlid=' + QuotePDFTemplateId
                + '#toolbar=1&navpanes=0&zoom=90';
        PageReference pageReferenceForPDF = new PageReference(quoteURL);
        QuoteDocument newQuoteDocument = new QuoteDocument(); 
        Blob renderedPDF = pageReferenceForPDF.getContentAsPDF();
        newQuoteDocument.Document = renderedPDF;
        newQuoteDocument.QuoteId = quotesId;
        INSERT newQuoteDocument;
    }
    //@istest does not exist for this class because there is no way to query the quote templates directly in apex, 
    //so the Template ID must be hard coded which would cause deployment to fail
}