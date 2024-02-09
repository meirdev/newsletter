// email.w

bring util;

bring "./email-shared.w" as shared;
bring "./email-sim.w" as sim;
bring "./email-tf-aws.w" as tfaws;

pub class Email impl shared.IEmail {
  platform: shared.IEmail;

  new(props: shared.EmailProps) {
    if util.env("WING_TARGET") == "tf-aws" {
      this.platform = new tfaws.EmailTfAws(props);
    }
    elif util.env("WING_TARGET") == "sim" {
      this.platform = new sim.EmailSim(props);
    }
    else {
      throw "unknown platform";
    }
  }

  pub inflight createEmailIdentity(props: shared.CreateEmailIdentityProps) {
    this.platform.createEmailIdentity(props);
  }

  pub inflight createContact(props: shared.CreateContactProps) {
    this.platform.createContact(props);
  }

  pub inflight updateContact(props: shared.UpdateContactProps) {
    this.platform.updateContact(props);
  }

  pub inflight deleteContact(props: shared.DeleteContactProps) {
    this.platform.deleteContact(props);
  }

  pub inflight listContacts(props: shared.ListContactsProps): Array<Array<shared.Contact>> {
    return this.platform.listContacts(props);
  }

  pub inflight sendEmail(props: shared.SendEmailProps) {
    this.platform.sendEmail(props);
  }
}
