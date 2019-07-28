trigger lineItem on LineItem__c (before insert) {
	system.debug('lineItem__lineItem');
}