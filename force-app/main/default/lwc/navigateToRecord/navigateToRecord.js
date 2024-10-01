import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigateToRecord extends NavigationMixin(LightningElement) {

    @api recordId;

    connectedCallback() {
        if(this.recordId) {
            window.location.href = '/' + this.recordId;
        } else {
            console.error('Record ID is undefined');
        }
    }
}