trigger LocationTriggerOverlap on Location__c (before insert, before update) {
    if (Trigger.isBefore) {
        LocationTriggerHandlerOverlap.validateLocationDates(Trigger.new);
    }
}