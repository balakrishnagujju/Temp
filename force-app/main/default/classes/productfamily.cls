public class productfamily{

@future
public static void destroyAndCreate(){
    
    TempStore__c ts=TempStore__c.getOrgDefaults();
    ts.length__c= String.valueof( integer.valueof(ts.length__c)+1);
    UPDATE TS;
    DELETE [SELECT ID FROM Product__c];
    Product__c P=NEW Product__c();
    INSERT P;
}

public static void afterInsert(List<Product__c> PP){

    
    
    destroyAndCreate();
    

}

}