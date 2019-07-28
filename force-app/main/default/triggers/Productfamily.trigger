trigger Productfamily on Product__c (after insert) {


productfamily.afterInsert(trigger.new);

}