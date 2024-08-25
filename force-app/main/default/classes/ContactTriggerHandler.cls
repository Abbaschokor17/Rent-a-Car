public with sharing class ContactTriggerHandler {
    public static void validateContactCreation(Map<Id,Contact> contactMap){
        // recuperer le recordtypeId du consommateur
        String consommateur = System.Label.ConsommateurRecordTypeId;
        ID consommateurRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(consommateur).getRecordTypeId();
        // creation set of id
        Set<Id> currentAccountIdSet=new Set<Id>();
        // Recuperer les Id des accounts  des contacts inserés
        for(Contact c : contactMap.values()){
            if(c.AccountId!=null){
                // ajouter dans la newset l id du contact
                currentAccountIdSet.add(c.AccountId);
            }    
        }
        // Recupere les comptes et la liste des contacts reliées a ces comptes (avec id consommateur )
        String error = System.Label.ContactError;
        List<Account> accountList = [SELECT Id, (SELECT Id FROM Contacts) 
                                        FROM Account 
                                        WHERE Id IN :currentAccountIdSet AND RecordTypeId = :consommateurRecordTypeId];
        //filtrer si le comptes a plus d'un object et que le contact inséré  est relié a ce compte 
        for(Account acc : accountList){
            //verifier si le compte a min deux contacts
            if(acc.Contacts!=null && acc.Contacts.size()>1){
                for(Contact c : acc.Contacts){
                    if(contactMap.get(c.Id)!=null){
                        //ajouter un message d erreru dur le customlabel
                        contactMap.get(c.Id).addError(error);
                    }
                }
                
                
            }
        }

        
    }
}