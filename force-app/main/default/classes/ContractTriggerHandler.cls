public with sharing class ContractTriggerHandler {
    /**
     * @description validateServiceContractCreation description
     * @param serviceMap description
     */
    public static void validateContractCreation(Map<Id,Contract> serviceMap){
        // Recuperer id du record type "consomateur"
        String consommateur = System.Label.ConsommateurRecordTypeId;
        ID consommateurRecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(consommateur).getRecordTypeId();
        //creer set pour id
        Set<Id> currentAccountIdSet=new Set<Id>();
        // recuperer les id des account insérés
        for(Contract cont : serviceMap.values()){
            if(cont.AccountId!=null){
                currentAccountIdSet.add(cont.AccountId);
            }
        }
            //existing list
           
            //crrer une liste de Contract en utilisant SOQL 
            List<Contract> existinglist = [SELECT AccountId,Id, StartDate,EndDate 
                                                 FROM Contract
                                                 WHERE AccountId IN :currentAccountIdSet AND Account.RecordTypeId = :consommateurRecordTypeId];

            // boucle for sur les valeurs ServiceMap
            for(Contract cs : serviceMap.values() ){
                // boucle for sur  existinglist 
                for(Contract sc1: existinglist){
                    //verifier les 3 possibilité du overlap
                    if(cs.AccountId == sc1.AccountId && cs.Id != sc1.Id && 
                    ((cs.StartDate<= sc1.EndDate && cs.EndDate >= sc1.EndDate) || 
                     (cs.EndDate>= sc1.StartDate && cs.StartDate <= sc1.StartDate)||
                      (cs.StartDate<= sc1.StartDate && cs.EndDate >= sc1.EndDate ))){
                        // addError dans les 3 cas la dessus
                        serviceMap.get(cs.Id).addError('This account already has a contract with overlapping dates.'); 
                        

                    }
                }
            }
}
    

	
}
