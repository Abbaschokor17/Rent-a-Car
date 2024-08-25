trigger OpportunityTrigger on Opportunity (after update) {
    List<Contract> contractsToCreate = new List<Contract>();

    for (Opportunity opp : Trigger.new) {
        // Vérifier si l'Opportunité est actuellement à "Closed Won"
        if (opp.StageName == 'Closed Won') {
            // Créer un nouveau Contrat
            Contract newContract = new Contract();
            newContract.Opportunity__c = opp.Id; // Lien vers l'Opportunité
            newContract.AccountId = opp.AccountId; // Lien vers le Compte
            newContract.StartDate = opp.FromDate__c; // Copier la date de début
            newContract.EndDATE__c = opp.ToDate__c; // Exemple d'autre champ à copier

            newContract.Status = 'Draft'; // Statut initial du contrat
            
            // Ajoutez ici les autres champs que vous voulez copier
            newContract.Description = opp.Description; // Copier la description

            // Ajouter le Contrat à la liste des contrats à créer
            contractsToCreate.add(newContract);
        }
    }

    // Créer les contrats
    if (!contractsToCreate.isEmpty()) {
        insert contractsToCreate;

        // Appel de la méthode pour créer les Rents
        ContractHelper.createRents(contractsToCreate);
    }
}
