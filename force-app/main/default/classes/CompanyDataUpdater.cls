public with sharing class CompanyDataUpdater {
    
    @AuraEnabled
    public static void updateCompanyData(String accountId) {
        Account account = [SELECT Id, txt_ent_siren__c FROM Account WHERE Id = :accountId LIMIT 1];
        String sirenNumber = account.txt_ent_siren__c;
        
        if (sirenNumber == null) {
            throw new AuraHandledException('Erreur lors de la mise à jour des données : Numéro de SIREN non renseigné');
        }

        try {
            sirenNumber = sirenNumber.replaceAll('\\s+', '');

            // Appel à l'API Pappers
            String apiUrl = 'https://api.pappers.fr/v2/entreprise?siren=' + sirenNumber + '&api_token=c8250d8757e3bff282a3d74061eb93c911493eac4979f162';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                // Récupération des informations de champs directement accessibles dans le JSON
                String denomination = (String) results.get('denomination');

                // Si une Personne Morale existe déjà avec ce nom, une exception est levée avec un message clair
                List<Account> accountsWithSameName = [SELECT Id, Name FROM Account WHERE Name = :denomination AND Id != :accountId];
                if (accountsWithSameName.size() > 0) {
                    throw new UnexpectedException('Une Personne Morale existe avec le nom ' + denomination);
                }

                String formeJuridique = (String) results.get('forme_juridique');
                String numeroTva = (String) results.get('numero_tva_intracommunautaire');
                String capitalSocial = String.valueOf(results.get('capital'));
                String codeRcs = (String) results.get('numero_rcs');
                String codeNaf = (String) results.get('code_naf');
                String libellecodenaf = (String) results.get('libelle_code_naf');
                String activitePrincipale = (String) results.get('domaine_activite');
                String dateClotureStr = (String) results.get('prochaine_date_cloture_exercice');
                String dateDeCreation = (String) results.get('date_de_creation');
                String objetSocial = (String) results.get('objet_social');
                String effectif = (String) results.get('effectif');
                String greffe = (String) results.get('greffe');

                //#region Utilisation des informations pouvant être utilisées directement pour mettre à jour le Compte
                account.Name = denomination;
                account.Forme_juridique__c = formeJuridique;
                account.txt_ent_rcs__c = codeRcs;
                account.txt_ent_code_naf__c = codeNaf;
                
                account.Libell_Code_NAF__c = libellecodenaf;
                account.txt_description_activite__c = activitePrincipale;

                account.txt_ent_objet_social__c = objetSocial;
                account.Effectif__c = effectif;
                account.Greffe__c = greffe;
                //#endregion

                //#region Récupération et utilisation des informations du siège social pour remplir les champs d'adresse du Compte
                Map<String, Object> siegeMap = (Map<String, Object>) results.get('siege');

                if (siegeMap != null) {
                    String ville = (String) siegeMap.get('ville');
                    String pays = (String) siegeMap.get('pays');
                    String codepays = (String) siegeMap.get('code_pays');
                    String postalcode = (String) siegeMap.get('code_postal');
                    String rue = (String) siegeMap.get('adresse_ligne_1');

                    account.ShippingCity = ville != null ? ville : null ;
                    account.ShippingCountry = pays != null ? pays : null ;
                    account.ShippingCountryCode = codepays != null ? codepays : null ;
                    account.ShippingPostalCode = postalcode != null ? postalcode : null ;
                    account.ShippingStreet = rue != null ? rue : null ;
                }                
                // #endregion

                //#region Traitement des informations nécessitant une conversion de type
                
                if (capitalSocial != null) {
                    Decimal capitalSocialDecimal = Decimal.valueOf(capitalSocial);                    
                    account.mtt_ent_capital_social__c = capitalSocialDecimal;
                }

                if (numeroTva != null) {
                    Decimal numeroTvaDecimal = Decimal.valueOf(numeroTva.replaceAll('[^0-9]', ''));
                    account.Num_ro_de_TVA__c = numeroTvaDecimal;
                }

                if (dateClotureStr != null) {
                    Date dateCloture = Date.valueOf(dateClotureStr);
                    account.Datecloture__c = dateCloture;
                }

                if (dateDeCreation != null) {
                    Date datecrea = Date.valueOf(dateDeCreation);
                    account.dt_ent_creation__c = datecrea;
                }   
                
                // #endregion
                
                update account;

            } else {
                throw new AuraHandledException('Erreur lors de l’appel à l’API : ' + res.getStatusCode());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erreur lors de la mise à jour des données : ' + e.getMessage());
        }
    }

    
}