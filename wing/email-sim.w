// email-sim.w

bring cloud;
bring fs;
bring util;

bring "./email-shared.w" as shared;
bring "./json-db.w" as jsonDb;

pub class EmailSim impl shared.IEmail {
  api: cloud.Api;

  props: shared.EmailProps;

  contacts: jsonDb.JsonDb;

  static extern "./email-sim.js" inflight _runMailDev(): inflight (): void;

  new(props: shared.EmailProps) {
    this.props = props;

    this.contacts = new jsonDb.JsonDb("../contact-list.json", {});

    this.api = new cloud.Api();

    this.api.get("/unsubscribe/:key", inflight (req) => {
      let key = req.vars.get("key");

      try {
        let contact = this.contacts.data().get(key);

        contact.set("unsubscribeAll", true);

        this.contacts.update((data) => { data.set(key, contact); });
      } catch {
        return {
          status: 404,
        };
      }

      return {
        status: 200,
        headers: {
          "Content-Type": "text/html; charset=utf-8",
        },
        body: "Goodbye, you will not receive any more emails from us",
      };
    });

    new cloud.Service(inflight () => {
      return EmailSim._runMailDev();
    });
  }

  inflight hash(emailAddress: str): str {
    return util.sha256(emailAddress);
  }

  pub inflight createEmailIdentity(props: shared.CreateEmailIdentityProps) {
  }

  pub inflight createContact(props: shared.CreateContactProps) {
    let key = this.hash(props.emailAddress);

    if Json.has(this.contacts.data(), key) {
      throw "{props.emailAddress} already exists";
    }

    this.contacts.update((data) => { data.set(key, props); });
  }

  pub inflight updateContact(props: shared.UpdateContactProps) {
    let key = this.hash(props.emailAddress);

    if !Json.has(this.contacts.data(), key) {
      throw "{props.emailAddress} not found";
    }

    this.contacts.update((data) => { data.set(key, props); });
  }

  pub inflight deleteContact(props: shared.DeleteContactProps) {
    let key = this.hash(props.emailAddress);

    if !Json.has(this.contacts.data(), key) {
      throw "{props.emailAddress} not found";
    }

    this.contacts.update((data) => { Json.delete(data, key); });
  }

  pub inflight listContacts(props: shared.ListContactsProps): Array<Array<shared.Contact>> {
    let topicsMap = MutMap<shared.Topic>{};

    if let topics = this.props.topics {
      for topic in topics {
        topicsMap.set(topic.topicName, topic);
      }
    }

    let contacts = MutArray<MutArray<shared.Contact>>[MutArray<shared.Contact>[]];

    let var i = 0;

    for contact_ in Json.values(this.contacts.data()) {
      let contact = shared.Contact.fromJson(contact_);

      let contactTopicsMap = MutMap<shared.TopicPreferences>{};

      if let topics = contact.topicPreferences {
        for topic in topics {
          contactTopicsMap.set(topic.topicName, topic);
        }
      }

      if contact.unsubscribeAll? {
        continue;
      }

      if props.topicName? && (contactTopicsMap.tryGet(props.topicName!)?.subscriptionStatus != "OPT_IN" || topicsMap.tryGet(props.topicName!)?.defaultSubscriptionStatus != "OPT_IN") {
        continue;
      }

      if props.pageSize? && i == props.pageSize! {
        contacts.push(MutArray<shared.Contact>[]);
        i = 0;
      }

      contacts.at(contacts.length - 1).push(contact);

      i += 1;
    }

    return unsafeCast(contacts);
  }

  static extern "./email-sim.js" inflight _sendEmail(from: str, to: str, subject: str, body: str): void;

  pub inflight sendEmail(props: shared.SendEmailProps) {
    for address in props.to {
      EmailSim._sendEmail(this.props.email, address, props.subject, props.body + "<hr /><a href='{this.api.url}/unsubscribe/{this.hash(address)}'>Unsubscribe</a>");
    }
  }
}
