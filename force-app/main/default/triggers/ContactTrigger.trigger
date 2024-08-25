
trigger ContactTrigger on Contact (after insert, after update) {

    
        if(Trigger.isAfter && (Trigger.isUpdate||Trigger.isInsert)){
           ContactTriggerHandler.validateContactCreation(trigger.newMap);
            }
    
        
 } 