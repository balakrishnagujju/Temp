public with sharing class ListViewController {
    // Method to get all list view option available for the Account object 
    @AuraEnabled
    public static List<ListView> getListViews(){
        List<ListView> listviews = new List<ListView>();
        for(ListView lstObj : [SELECT Id, Name FROM ListView WHERE SobjectType = 'Contact' order by name ASC]){
        	listviews.add(lstObj);
        }
        return listviews; 
    }
    // Method to get the Account records based on the selected list view
    @AuraEnabled  
    public static List<Contact> getFilteredAccounts(String filterId,String recordId){
        
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl+'/services/data/v32.0/sobjects/Contact/listviews/'+filterId+'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
         
        String username = 'balakrishna.gujju@outlook.com.dev';
     	String password = 'balu91103385862018Dk2riN240xqXjFnUiVXs4mgQa ';
  
         Blob headerValue = Blob.valueOf(username + ':' + password);
         String authorizationHeader = 'BASIC ' +
         EncodingUtil.base64Encode(headerValue);
         //req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');

        req.setHeader('Authorization',  'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //String query = (String) tokenResponse.get('query');
        List<Contact> AccountList = new List<Contact>();
        for(Contact accountObj : [Select Name From Contact a where AccountId=:recordId order by name ASC]){
            AccountList.add(accountObj);
        }  

        return AccountList;        
    }
}