public class ReservationTriggerHandlerCheck {
    /**
     * Validates that the Rental_Price__c in Reservation__c is greater than or equal to the Minimum_Rental_Price__c in Vehicle__c
     * @param reservations List of Reservation__c records being processed
     */
    public static void validateRentalPrice(List<Reservation__c> reservations) {
        Set<Id> vehicleIds = new Set<Id>();
        
        // Collect Vehicle IDs from Reservation records
        for (Reservation__c res : reservations) {
            if (res.Vehicule__c != null) {
                vehicleIds.add(res.Vehicule__c);
            }
        }
        
        // Retrieve Vehicle records with their Minimum_Rental_Price__c
        Map<Id, Vehicule__c> vehicleMap = new Map<Id, Vehicule__c>([
            SELECT Id, Minimum_Rental_Price__c 
            FROM Vehicule__c 
            WHERE Id IN :vehicleIds
        ]);
        
        // Validate Rental_Price__c against Minimum_Rental_Price__c
        for (Reservation__c res : reservations) {
            if (res.Vehicule__c != null && vehicleMap.containsKey(res.Vehicule__c)) {
                Vehicule__c vehicle = vehicleMap.get(res.Vehicule__c);
                if (res.Reservation_Price__c < vehicle.Minimum_Rental_Price__c) {
                    res.addError('The rental price must be greater than or equal to the minimum rental price of ' +
                                 vehicle.Minimum_Rental_Price__c + ' for this vehicle.');
                }
            }
        }
    }
}
