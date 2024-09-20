({
    initialize: function(component, event, helper) {
        if (!component.get("v.hasInitialized")) {
            component.set("v.hasInitialized", true);  // Empêche l'initialisation multiple
            helper.updateCompanyData(component);  // Appelle le helper pour exécuter l'action Apex
        }
    }
})