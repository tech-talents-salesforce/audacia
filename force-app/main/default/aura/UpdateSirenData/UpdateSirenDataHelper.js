({
    updateCompanyData: function(component) {
        var action = component.get("c.updateCompanyData");  // Appel de la méthode Apex
        action.setParams({
            accountId: component.get("v.recordId")  // Transmettre l'ID du compte au serveur
        });

        // Afficher un spinner pendant le traitement
        component.set("v.isLoading", true);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoading", false);  // Cacher le spinner après succès
                $A.get("e.force:closeQuickAction").fire();  // Fermer l'action rapide
                $A.get('e.force:refreshView').fire();  // Rafraîchir la vue après la mise à jour
            } else {
                component.set("v.isLoading", false);  // Cacher le spinner en cas d'erreur
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Erreur lors de la mise à jour des données: " + errors[0].message);
                }
            }
        });

        $A.enqueueAction(action);  // Exécuter l'action
    }
})