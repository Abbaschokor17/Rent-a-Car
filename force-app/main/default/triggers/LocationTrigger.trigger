trigger LocationTrigger on Location__c (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        LocationTriggerHandler.validateRentalPrice(Trigger.new);
    }
}