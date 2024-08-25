public with sharing class LocationTriggerHandlerOverlap {
    public static void validateLocationDates(List<Location__c> newLocations) {
        // Collect contract IDs and vehicle IDs from new or updated Location records
        Set<Id> contractIds = new Set<Id>();
        Set<Id> vehiculeIds = new Set<Id>();

        for (Location__c loc : newLocations) {
            if (loc.Contract__c != null) {
                contractIds.add(loc.Contract__c);
            }
            if (loc.Vehicule__c != null) {
                vehiculeIds.add(loc.Vehicule__c);
            }
        }

        // Retrieve Contracts with their StartDate and EndDate
        Map<Id, Contract> contractsMap = new Map<Id, Contract>();
        if (!contractIds.isEmpty()) {
            List<Contract> contracts = [
                SELECT Id, StartDate, EndDate
                FROM Contract 
                WHERE Id IN :contractIds
            ];
            for (Contract c : contracts) {
                contractsMap.put(c.Id, c);
            }
        }

        // Retrieve existing Locations for these vehicles
        Map<Id, List<Location__c>> vehiculeToLocationsMap = new Map<Id, List<Location__c>>();
        List<Location__c> existingLocations = [
            SELECT Id, Vehicule__c, Contract__c, Start_Date__c, End_Date__c
            FROM Location__c
            WHERE Vehicule__c IN :vehiculeIds
        ];

        // Map to hold vehicle IDs and their associated locations
        for (Location__c loc : existingLocations) {
            if (!vehiculeToLocationsMap.containsKey(loc.Vehicule__c)) {
                vehiculeToLocationsMap.put(loc.Vehicule__c, new List<Location__c>());
            }
            vehiculeToLocationsMap.get(loc.Vehicule__c).add(loc);
        }

        // Validate date ranges for each new location
        for (Location__c newLoc : newLocations) {
            if (newLoc.Vehicule__c != null && newLoc.Contract__c != null) {
                Contract contract = contractsMap.get(newLoc.Contract__c);
                if (contract != null) {
                    Date contractStartDate = contract.StartDate;
                    Date contractEndDate = contract.EndDate;
                    Date newStartDate = newLoc.Start_Date__c;
                    Date newEndDate = newLoc.End_Date__c;
                    
                    // Check for overlapping dates across different contracts
                    List<Location__c> existingLocationsForVehicule = vehiculeToLocationsMap.get(newLoc.Vehicule__c);
                    if (existingLocationsForVehicule != null) {
                        for (Location__c existingLoc : existingLocationsForVehicule) {
                            Date existingStartDate = existingLoc.Start_Date__c;
                            Date existingEndDate = existingLoc.End_Date__c;
                            Id existingContractId = existingLoc.Contract__c;

                            // Check for overlapping dates
                            if (newStartDate != null && newEndDate != null &&
                                existingStartDate != null && existingEndDate != null &&
                                (newStartDate <= existingEndDate) && 
                                (newEndDate >= existingStartDate) &&
                                newLoc.Contract__c != existingContractId) {
                                newLoc.addError('The vehicle is already booked for the selected dates in another contract.');
                                break;
                            }
                        }
                    }

                    // Check for multiple bookings of the same vehicle in the same contract
                    List<Location__c> existingLocationsForContract = [
                        SELECT Id, Vehicule__c 
                        FROM Location__c
                        WHERE Contract__c = :newLoc.Contract__c AND Vehicule__c = :newLoc.Vehicule__c
                    ];
                    if (existingLocationsForContract.size() > 0) {
                        newLoc.addError('The vehicle is already booked in this contract.');
                    }
                }
            }
        }
    }
}
