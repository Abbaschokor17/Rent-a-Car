public class LocationTriggerHandler {
    /**
     * Validates that the Rental_Price__c in Location__c is greater than or equal to the Minimum_Rental_Price__c in Vehicule__c
     * @param locations List of Location__c records being processed
     */
    public static void validateRentalPrice(List<Location__c> locations) {
        Set<Id> vehiculeIds = new Set<Id>();
        
        // Collect Vehicle IDs from Location records
        for (Location__c loc : locations) {
            if (loc.Vehicule__c != null) {
                vehiculeIds.add(loc.Vehicule__c);
            }
        }
        
        // Retrieve Vehicule records with their Minimum_Rental_Price__c
        Map<Id, Vehicule__c> vehiculeMap = new Map<Id, Vehicule__c>([
            SELECT Id, Minimum_Rental_Price__c 
            FROM Vehicule__c 
            WHERE Id IN :vehiculeIds
        ]);
        
        // Validate Rental_Price__c against Minimum_Rental_Price__c
        for (Location__c loc : locations) {
            if (loc.Vehicule__c != null && vehiculeMap.containsKey(loc.Vehicule__c)) {
                Vehicule__c vehicule = vehiculeMap.get(loc.Vehicule__c);
                if (loc.Rental_Price__c < vehicule.Minimum_Rental_Price__c) {
                    loc.addError('The rental price must be greater than or equal to the minimum rental price of the vehicule.');
                }
            }
        }
    }
}