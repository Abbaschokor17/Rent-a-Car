public class ContractEmailSender {
    public static void sendContractEmail(Id contractId, String subject, String body) {
        // Query Contract and related Contact
        Contract contract = [SELECT Id, ContractNumber, StartDate, EndDATE__c, Account.Name,
                                CustomerSignedId
                             FROM Contract
                             WHERE Id = :contractId];
        
        if (contract.CustomerSignedId != null) {
            Contact contact = [SELECT Id, Name, Email
                               FROM Contact
                               WHERE Id = :contract.CustomerSignedId];
            
            if (contact != null && contact.Email != null) {
                // Generate PDF
                PageReference pdfPage = Page.SendContractReport; // Visualforce page name
                pdfPage.getParameters().put('id', contractId);
                Blob pdfBlob;
                try {
                    pdfBlob = pdfPage.getContentAsPDF();
                } catch (Exception e) {
                    System.debug('Error generating PDF: ' + e.getMessage());
                    return;
                }
                
                // Create Email Message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { contact.Email });
                email.setSubject(subject);
                email.setPlainTextBody(body);
                
                // Create the email attachment
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('ContractReport.pdf');
                attachment.setBody(pdfBlob);
                
                // Attach the PDF to the email
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

                // Send Email
                try {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                } catch (Exception e) {
                    System.debug('Error sending email: ' + e.getMessage());
                }
            }
        }
    }
}
