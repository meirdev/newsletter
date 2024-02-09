bring aws;

bring "@cdktf/provider-aws" as tfaws;

bring "./email-shared.w" as shared;

pub class EmailTfAws impl shared.IEmail {
  email: str;
  contactListName: str;

  new(props: shared.EmailProps) {
    this.email = props.email;
    this.contactListName = "Default";

    new tfaws.sesEmailIdentity.SesEmailIdentity(email: props.email);

    new tfaws.sesv2ContactList.Sesv2ContactList(
      contactListName: this.contactListName,
      topic: props.topics,
    );
  }

  pub onLift(host: std.IInflightHost, ops: Array<str>) {
    if let host = aws.Function.from(host) {
      host.addPolicyStatements({
        actions: ["ses:*"],
        resources: ["*"],
      });
    }
  }

  static extern "./email-tf-aws.js" inflight _createEmailIdentity(props: shared.CreateEmailIdentityProps): void;

  pub inflight createEmailIdentity(props: shared.CreateEmailIdentityProps) {
    EmailTfAws._createEmailIdentity(props);
  }

  static extern "./email-tf-aws.js" inflight _createContact(contactListName: str, props: shared.CreateContactProps): void;

  pub inflight createContact(props: shared.CreateContactProps) {
    EmailTfAws._createContact(this.contactListName, props);
  }

  static extern "./email-tf-aws.js" inflight _updateContact(contactListName: str, props: shared.UpdateContactProps): void;

  pub inflight updateContact(props: shared.UpdateContactProps) {
    EmailTfAws._updateContact(this.contactListName, props);
  }

  static extern "./email-tf-aws.js" inflight _deleteContact(contactListName: str, props: shared.DeleteContactProps): void;

  pub inflight deleteContact(props: shared.DeleteContactProps) {
    EmailTfAws._deleteContact(this.contactListName, props);
  }

  static extern "./email-tf-aws.js" inflight _listContacts(contactListName: str, props: shared.ListContactsProps): Array<Array<shared.Contact>>;

  pub inflight listContacts(props: shared.ListContactsProps): Array<Array<shared.Contact>> {
    return EmailTfAws._listContacts(this.contactListName, props);
  }

  static extern "./email-tf-aws.js" inflight _sendEmail(from: str, props: shared.SendEmailProps): void;

  pub inflight sendEmail(props: shared.SendEmailProps) {
    EmailTfAws._sendEmail(this.email, props);
  }
}
