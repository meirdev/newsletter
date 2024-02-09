// email-shared.w

pub struct Topic {
  topicName: str;
  displayName: str;
  defaultSubscriptionStatus: str; // "OPT_IN" || "OPT_OUT"
  description: str?;
}

pub struct EmailProps {
  email: str;
  topics: Array<Topic>?;
}

pub struct CreateEmailIdentityProps {
  emailIdentity: str;
}

pub struct TopicPreferences {
  topicName: str;
  subscriptionStatus: str; // "OPT_IN" || "OPT_OUT"
}

pub struct Contact {
  emailAddress: str;
  topicPreferences: Array<TopicPreferences>?;
  unsubscribeAll: bool?;
  attributesData: str?;
}

pub struct CreateContactProps extends Contact {
}

pub struct UpdateContactProps extends Contact {
}

pub struct DeleteContactProps {
  emailAddress: str;
}

pub struct ListContactsProps {
  topicName: str?;
  pageSize: num?;
}

pub struct SendEmailProps {
  to: Array<str>;
  subject: str;
  body: str;
  topicName: str?;
}

pub interface IEmail {
  inflight createEmailIdentity(props: CreateEmailIdentityProps): void;
  inflight createContact(props: CreateContactProps): void;
  inflight updateContact(props: UpdateContactProps): void;
  inflight deleteContact(props: DeleteContactProps): void;
  inflight listContacts(props: ListContactsProps): Array<Array<Contact>>;
  inflight sendEmail(props: SendEmailProps): void;
}
