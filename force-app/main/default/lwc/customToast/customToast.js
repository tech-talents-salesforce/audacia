import { api, track, LightningElement } from 'lwc'


export default class CustomToast extends LightningElement {

    @track rendered = false;

    @api isVisible = false;
    @api title = "titre";
    @api details = "";
    @api toastType = "error";

    iconName = "";
    classNames = "";

    renderedCallback() {
        if (this.rendered == false) {
            this.iconName = "utility:" + this.toastType; 
            this.classNames = `slds-theme--${this.toastType} slds-notify--toast slds-notify slds-notify--toast forceToastMessage`;
            "slds-theme--" + this.toastType;
            console.log(this.iconName);
            this.rendered = true;
        }
    }

    // Méthode pour déclencher l'événement de fermeture
    handleClose() {
        this.dispatchEvent(new CustomEvent("close"));
    }


}