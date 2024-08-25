trigger ReservationTriggerOver on Reservation__c (before insert, before update) {
    // Call the handler method to validate reservation dates
    ReservationTriggerHandlerOverlap.validateReservationDates(Trigger.new);
}