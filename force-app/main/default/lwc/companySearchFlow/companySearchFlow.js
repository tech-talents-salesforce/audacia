/**
 * @description       :
 * @author            : Etienne Gaudry
 * @group             :
 * @last modified on  : 09-09-2024
 * @last modified by  : Etienne Gaudry
 **/
import { LightningElement, track, api } from "lwc";
import findAccounts from "@salesforce/apex/LeadController.findAccounts";

export default class CompanySearchFlow extends LightningElement {
  @track accounts = [];
  @track selectedAccountId = null;
  @track companyName = "";

  // Variables d'entrée et de sortie pour le Flow
  @api companyInput;
  @api selectedAccountInput;
  @api selectedAccountOutput;
  @api companyNameOutput;

  connectedCallback() {
    if (this.companyInput) {
      this.companyName = this.companyInput;
      this.companyNameOutput = this.companyName;
    }
    if (this.selectedAccountInput) {
      this.selectedAccountOutput = this.selectedAccountInput;
    }
  }

  handleInputChange(event) {
    this.companyName = event.target.value;

    if (this.companyName.length > 2) {
      findAccounts({ companyName: this.companyName })
        .then((result) => {
          this.accounts = result;
          this.handleValidation();
          // if (this.accounts.length === 0) {
          //   this.handleValidation();
          // }
        })
        .catch((error) => {
          this.accounts = [];
          console.error("Erreur:", error);
        });
    } else {
      this.accounts = [];
    }
  }

  get accountOptions() {
    return this.accounts.map((account) => {
      return { label: account.Name, value: account.Id };
    });
  }

  handleAccountSelection(event) {
    this.selectedAccountId = event.detail.value;
    this.handleValidation();
  }

  handleValidation() {
    if (this.selectedAccountId) {
      this.selectedAccountOutput = this.selectedAccountId;
      this.companyNameOutput = null;
      console.log("this.selectedAccountOutput = " + this.selectedAccountOutput);
    } else {
      this.companyNameOutput = this.companyName;
      if (this.companyNameOutput == null && this.selectedAccountInput != null) {
        this.selectedAccountOutput = this.selectedAccountInput;
      } else {
        this.selectedAccountOutput = null;
      }
      console.log("this.companyNameOutput = " + this.companyNameOutput);
    }
  }
}