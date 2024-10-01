/**
 * @description       :
 * @author            : Etienne Gaudry
 * @group             :
 * @last modified on  : 09-09-2024
 * @last modified by  : Etienne Gaudry
 **/
import { LightningElement, api, track } from "lwc";

export default class CommentInputFlow extends LightningElement {
  @track commentValue = "";
  @api commentOutput;

  @api
  get commentInput() {
    return this.commentValue;
  }
  set commentInput(value) {
    this.commentValue = value;
    this.commentOutput = this.commentValue;
  }

  

  handleInputChange(event) {
    this.commentValue = event.target.value;
    this.commentOutput = this.commentValue;
  }
}