trigger ContractTrigger on Contract (after insert, after update) {

    if(Trigger.isAfter && (Trigger.isUpdate||Trigger.isInsert)){
        ContractTriggerHandler.validateContractCreation(trigger.newMap);
    }
}
