trigger ReservationTriggerCheck on Reservation__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Appel à la méthode de validation du prix de location
            ReservationTriggerHandlerCheck.validateRentalPrice(Trigger.new);
        }
    }
}