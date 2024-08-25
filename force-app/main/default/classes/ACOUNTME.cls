public with sharing class ACOUNTME {
    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name FROM Account];
    }
}