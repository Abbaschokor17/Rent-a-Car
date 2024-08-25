public with sharing class ReservationTriggerHandlerOverlap {
    public static void validateReservationDates(List<Reservation__c> newReservations) {
        // Collect contract IDs and vehicle IDs from new or updated Reservation records
        Set<Id> OpportunityIds = new Set<Id>();
        Set<Id> vehiculeIds = new Set<Id>();

        for (Reservation__c res : newReservations) {
            if (res.Opportunity__c != null) {
                OpportunityIds.add(res.Opportunity__c);
            }
            if (res.Vehicule__c != null) {
                vehiculeIds.add(res.Vehicule__c);
            }
        }

        // Retrieve Contracts with their StartDate and EndDate
        Map<Id, Opportunity> OpportunitiesMap = new Map<Id, Opportunity>();
        if (!OpportunityIds.isEmpty()) {
            List<Opportunity> Opportunities = [
                SELECT Id, FromDate__c, ToDate__c
                FROM Opportunity 
                WHERE Id IN :OpportunityIds
            ];
            for (Opportunity o : Opportunities) {
                OpportunitiesMap.put(o.Id, o);
            }
        }

        // Retrieve existing Reservations for these vehicles
        Map<Id, List<Reservation__c>> vehiculeToReservationsMap = new Map<Id, List<Reservation__c>>();
        List<Reservation__c> existingReservations = [
            SELECT Id, Vehicule__c,Opportunity__c , From__c, To__c
            FROM Reservation__c
            WHERE Vehicule__c IN :vehiculeIds
        ];

        // Map to hold vehicle IDs and their associated reservations
        for (Reservation__c res : existingReservations) {
            if (!vehiculeToReservationsMap.containsKey(res.Vehicule__c)) {
                vehiculeToReservationsMap.put(res.Vehicule__c, new List<Reservation__c>());
            }
            vehiculeToReservationsMap.get(res.Vehicule__c).add(res);
        }

        // Validate date ranges for each new reservation
        for (Reservation__c newRes : newReservations) {
            if (newRes.Vehicule__c != null && newRes.Opportunity__c != null) {
                Opportunity opportunity = OpportunitiesMap.get(newRes.Opportunity__c);
                if (opportunity != null) {
                    Date opportunityStartDate = opportunity.FromDate__c;
                    Date opportunityEndDate = opportunity.ToDate__c;
                    Date newStartDate = newRes.From__c;
                    Date newEndDate = newRes.To__c;
                    
                    // Check for overlapping dates across different opportunities
                    List<Reservation__c> existingReservationsForVehicule = vehiculeToReservationsMap.get(newRes.Vehicule__c);
                    if (existingReservationsForVehicule != null) {
                        for (Reservation__c existingRes : existingReservationsForVehicule) {
                            Date existingStartDate = existingRes.From__c;
                            Date existingEndDate = existingRes.To__c;
                            Id existingOpportunityId = existingRes.Opportunity__c;

                            // Check for overlapping dates
                            if (newStartDate != null && newEndDate != null &&
                                existingStartDate != null && existingEndDate != null &&
                                (newStartDate <= existingEndDate) && 
                                (newEndDate >= existingStartDate) &&
                                newRes.Opportunity__c != existingOpportunityId) {
                                newRes.addError('The vehicle is already reserved for the selected dates in another Opportunity.');
                                break;
                            }
                        }
                    }

                    // Check for multiple bookings of the same vehicle in the same opportunity
                    List<Reservation__c> existingReservationsForOpportunity = [
                        SELECT Id, Vehicule__c 
                        FROM Reservation__c
                        WHERE Opportunity__c = :newRes.Opportunity__c AND Vehicule__c = :newRes.Vehicule__c
                    ];
                    if (existingReservationsForOpportunity.size() > 0) {
                        newRes.addError('The vehicle is already reserved in this opportunity.');
                    }
                }
            }
        }
    }
}