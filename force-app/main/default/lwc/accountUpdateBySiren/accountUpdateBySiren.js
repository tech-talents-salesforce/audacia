import { LightningElement, api, track } from 'lwc';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCompanyData from '@salesforce/apex/CompanyDataUpdater.updateCompanyData';

export default class AccountUpdateBySiren extends LightningElement {

    @api recordId;
    @track notifVisibility = false;

    @api async invoke() {
        this.handleAccountUpdateBySiren();
    }

    handleAccountUpdateBySiren() {
        console.log("update begin");
        this.showCustomToastNotification();

        // Vérifier si recordId est disponible
        if (!this.recordId) {
            setTimeout(() => {
                this.hideCustomToastNotification();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: 'Record ID is undefined.',
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
                return;
            }, 1000);            
        }

        updateCompanyData({ accountId: this.recordId })
            .then(() => {
                setTimeout(() => {
                    this.hideCustomToastNotification();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Succès',
                            message: 'Les informations du compte ont été mises à jour',
                            variant: 'success',
                        })
                    );
                    // délai avant de recharger la page pour laisser l'utilisateur lire le toast
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                }, 1000);              
                
            })
            .catch(error => {
                this.hideCustomToastNotification();
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: 'Échec de la mise à jour du compte : ' + error.body.message,
                        variant: 'error',                        
                        mode: 'sticky',
                    })
                );
            });
    }

    showCustomToastNotification() {
        this.notifVisibility = true;
    }

    hideCustomToastNotification() {
        this.notifVisibility = false;
    }
}
