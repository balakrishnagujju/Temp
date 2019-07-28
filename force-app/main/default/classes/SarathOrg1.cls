public with sharing class SarathOrg1 {

    public SarathOrg1(ApexPages.StandardController controller) {

    }


    public SarathOrg1(SarathOrg controller) {

    }

    public void cmdSave(){
        insert new Product__c(Name='SarathOrg1');
        
    }
    public string getSave(){
        return 'SarathOrg1';
    }
    public SarathOrg1(){
    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String req='grant_type=password&client_id=3MVG9Y6d_Btp4xp7G84XWLED0hWaxBiAjaqL14t6RRovfMP4JfCjHhoOqMvg2PJNFdMk4sP12vyZJ3i2vHDJx&client_secret=8119762800598119371&username=Sarath16793@gmail.com&password=sarath@1';
        request.setEndpoint('https://sarath-tamada-dev-ed.my.salesforce.com/Services/doCycleTest');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(req);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()+' '+response.getBody());
        } else {
            System.debug(response.getBody());
        }
    
    }

}