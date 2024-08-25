public class ContractHelper {
    public static void createRents(List<Contract> contracts) {
        List<Location__c> rentsToCreate = new List<Location__c>();

        for (Contract contract : contracts) {
            // Récupérer les réservations liées à l'Opportunité du Contrat
            List<Reservation__c> reservations = [SELECT Id, Vehicule__c	 FROM Reservation__c WHERE Opportunity__c = :contract.Opportunity__c];

            for (Reservation__c reservation : reservations) {
                // Créer un nouvel enregistrement de Rent
                Location__c newRent = new Location__c();
                newRent.Contract__c = contract.Id; // Lien vers le Contrat
                newRent.Vehicule__c = reservation.Vehicule__c; // Lien vers le Véhicule
                // Ajoutez ici les autres champs nécessaires pour Rent

                // Ajouter le Rent à la liste des enregistrements à créer
                rentsToCreate.add(newRent);
            }
        }

        // Créer les enregistrements de Rent
        if (!rentsToCreate.isEmpty()) {
            insert rentsToCreate;
        }
    }
}
