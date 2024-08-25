public class ContractPDFController {
    public Contract contract { get; set; }
    public Contact contact { get; set; }
    public String emailSubject { get; set; }
    public String emailBody { get; set; }
    public String formattedStartDate { get; set; }
    public String formattedEndDate { get; set; }
    public String FCuSD { get; set; }
    public String FCoSD { get; set; }
    public String companySignedName { get; set; }
    public List<Location__c> locations { get; set; }
   
    public ContractPDFController() {
        Id contractId = ApexPages.currentPage().getParameters().get('id');
        
        // Check if the contractId is provided
        if (contractId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No contract ID provided.'));
            return; // or handle appropriately (redirect to error page, etc.)
        }

        // Query Contract
        List<Contract> contracts = [SELECT Id, ContractNumber, StartDate, EndDATE__c, Account.Name, 
                                         CustomerSignedId, Nombre_de_Vehicules__c, Total_Contract_Period_Price__c, 
                                         CustomerSignedDate, CompanySignedId, CompanySignedDate
                                     FROM Contract
                                     WHERE Id = :contractId];

        if (contracts.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No contract found for the provided ID.'));
            return; // or handle appropriately
        }

        contract = contracts[0];

        // Format dates
        if (contract.StartDate != null) {
            formattedStartDate = contract.StartDate.format();
        }
        if (contract.EndDATE__c != null) {
            formattedEndDate = contract.EndDATE__c.format();
        }
        if (contract.CustomerSignedDate != null) {
            FCuSD = contract.CustomerSignedDate.format();
        }
        if (contract.CompanySignedDate != null) {
            FCoSD = contract.CompanySignedDate.format();
        }

        // Query for the company signatory's name
        if (contract.CompanySignedId != null) {
            List<User> signatories = [SELECT Name FROM User WHERE Id = :contract.CompanySignedId];
            if (!signatories.isEmpty()) {
                companySignedName = signatories[0].Name;
            }
        }

        // Query Contact
        if (contract.CustomerSignedId != null) {
            List<Contact> contacts = [SELECT Id, Name, Email
                                      FROM Contact
                                      WHERE Id = :contract.CustomerSignedId];
            if (!contacts.isEmpty()) {
                contact = contacts[0];
            }
        }

        // Query Locations and related Vehicle details
        locations = [SELECT Id, Name, Contract__c, Contract_number_of_vehicles__c, Contract_type__c, 
                            Rental_price__c, Vehicule__c,
                            Vehicule__r.Name, Vehicule__r.Color__c, Vehicule__r.Capacity__c, 
                            Vehicule__r.Model_year__c, Vehicule__r.Number_of_persons__c, 
                            Vehicule__r.Type__c
                     FROM Location__c
                     WHERE Contract__c = :contractId];
    }

    public PageReference sendEmail() {
        if (String.isBlank(emailSubject) || String.isBlank(emailBody)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subject and Body are required.'));
            return null;
        }

        // Send the email
        ContractEmailSender.sendContractEmail(contract.Id, emailSubject, emailBody);
        
        // Redirect back to the contract record page
        return new PageReference('/' + contract.Id);
    }

    public PageReference cancel() {
        return new PageReference('/' + contract.Id);
    }
}
