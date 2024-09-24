@isTest
public class CompanyDataUpdaterTest {

    @testSetup
    static void setupTestData() {
        // Création d'un enregistrement Account fictif avec un SIREN pour le test
        Account testAccount = new Account(
            Name = 'Test Account',
            txt_ent_siren__c = '123456789',  // Utilise un numéro SIREN valide pour ton test
            Forme_juridique__c = 'Test Forme juridique',
            Num_ro_de_TVA__c = 123456789,
            mtt_ent_capital_social__c = 1000000,
            txt_ent_code_naf__c = '6202A',
            txt_description_activite__c = 'Activité informatique'
        );
        insert testAccount;
    }

    @isTest
    static void testUpdateCompanyData() {
        // Récupérer l'enregistrement Account créé dans testSetup
        Account testAccount = [SELECT Id, txt_ent_siren__c FROM Account WHERE txt_ent_siren__c = '123456789' LIMIT 1];

        // Simuler un appel d'API réussi en mockant la réponse HTTP
        Test.startTest();

        // Créer une fausse réponse HTTP pour simuler un appel d'API réussi
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody(
            '{'
                + '"denomination": "Mock Company Name",'
                + '"forme_juridique": "SARL",'
                + '"numero_tva_intracommunautaire": "FR12345678901",'
                + '"capital": "100000",'
                + '"numero_rcs": "123456789",'
                + '"code_naf": "6201Z",'
                + '"libelle_code_naf": "Programmation informatique",'
                + '"domaine_activite": "Développement logiciel",'
                + '"prochaine_date_cloture_exercice": "2024-12-31",'
                + '"date_de_creation": "2010-05-15",'
                + '"objet_social": "Développement et vente de logiciels",'
                + '"effectif": "50",'
                + '"greffe": "Paris",'
                + '"siege": {'
                    + '"ville": "Paris",'
                    + '"pays": "France",'
                    + '"code_pays": "FR",'
                    + '"code_postal": "75001",'
                    + '"adresse_ligne_1": "123 Rue de Paris"'
                + '}'
            + '}'
        );


        // Créer un mock d'appel HTTP
        HttpRequest mockRequest = new HttpRequest();
        mockRequest.setEndpoint('https://api.pappers.fr/v2/entreprise?siren=' + testAccount.txt_ent_siren__c + '&api_key=YOUR_API_KEY');
        mockRequest.setMethod('GET');

        // Utilisation du mock pour simuler l'appel HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Appel de la méthode Apex à tester
        CompanyDataUpdater.updateCompanyData(testAccount.Id);

        // Requête pour vérifier que l'Account a bien été mis à jour
        // Requête pour vérifier que l'Account a bien été mis à jour avec tous les champs nécessaires
        Account updatedAccount = [SELECT Forme_juridique__c, Num_ro_de_TVA__c, mtt_ent_capital_social__c, txt_ent_code_naf__c, 
                                        txt_description_activite__c, Datecloture__c, dt_ent_creation__c, txt_ent_rcs__c, 
                                        txt_ent_objet_social__c, Effectif__c, Greffe__c, ShippingCity, ShippingCountry, 
                                        ShippingCountryCode, ShippingPostalCode, ShippingStreet
                                FROM Account WHERE Id = :testAccount.Id];

        Test.stopTest();

        // Vérifications (Assertions) pour valider que les champs ont été correctement mis à jour
        System.assertEquals('SARL', updatedAccount.Forme_juridique__c, 'Le champ Forme_juridique__c n\'a pas été mis à jour correctement');
        System.assertEquals(Decimal.valueOf('12345678901'), updatedAccount.Num_ro_de_TVA__c, 'Le numéro de TVA n\'a pas été mis à jour correctement');
        System.assertEquals(100000, updatedAccount.mtt_ent_capital_social__c, 'Le capital social n\'a pas été mis à jour correctement');
        System.assertEquals('6201Z', updatedAccount.txt_ent_code_naf__c, 'Le code NAF n\'a pas été mis à jour correctement');
        System.assertEquals('Développement logiciel', updatedAccount.txt_description_activite__c, 'La description de l\'activité n\'a pas été mise à jour correctement');
        System.assertEquals(Date.newInstance(2024, 12, 31), updatedAccount.Datecloture__c, 'La date de clôture n\'a pas été mise à jour correctement');
        System.assertEquals(Date.newInstance(2010, 5, 15), updatedAccount.dt_ent_creation__c, 'La date de création n\'a pas été mise à jour correctement');
        System.assertEquals('123456789', updatedAccount.txt_ent_rcs__c, 'Le numéro RCS n\'a pas été mis à jour correctement');
        System.assertEquals('Développement et vente de logiciels', updatedAccount.txt_ent_objet_social__c, 'L\'objet social n\'a pas été mis à jour correctement');
        System.assertEquals('50', updatedAccount.Effectif__c, 'L\'effectif n\'a pas été mis à jour correctement');
        System.assertEquals('Paris', updatedAccount.Greffe__c, 'Le greffe n\'a pas été mis à jour correctement');

        // Vérification des champs d'adresse
        System.assertEquals('Paris', updatedAccount.ShippingCity, 'La ville d\'expédition n\'a pas été mise à jour correctement');
        System.assertEquals('France', updatedAccount.ShippingCountry, 'Le pays d\'expédition n\'a pas été mis à jour correctement');
        System.assertEquals('FR', updatedAccount.ShippingCountryCode, 'Le code pays d\'expédition n\'a pas été mis à jour correctement');
        System.assertEquals('75001', updatedAccount.ShippingPostalCode, 'Le code postal d\'expédition n\'a pas été mis à jour correctement');
        System.assertEquals('123 Rue de Paris', updatedAccount.ShippingStreet, 'La rue d\'expédition n\'a pas été mise à jour correctement');
    }
}