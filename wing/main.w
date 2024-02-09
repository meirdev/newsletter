// main.w

bring aws;
bring cloud;
bring ex;
bring fs;
bring util;

bring "@cdktf/provider-aws" as tfaws;

bring "./email.w" as email_;
bring "./email-shared.w" as emailShared;

let RATE_PER_SECONDS = 1;

pub struct SubscribeRequest {
  emailAddress: str;
}

pub struct SendEmailRequest {
  subject: str;
  body: str;
  topicName: str?;
}

pub struct Message {
  subject: str;
  body: str;
  to: Array<str>;
  topicName: str?;
}

let config = fs.readJson("./config.json");

let secret = new cloud.Secret(name: "api-key");

let email = new email_.Email(
  emailShared.EmailProps.fromJson(config),
);

let api = new cloud.Api(cors: true);

let website = new ex.ReactApp(
  projectPath: "../website",
  startCommand: "npm run dev",
  buildDir: "/dist",
  localPort: 5173,
);

let queue = new cloud.Queue();

let consumer = queue.setConsumer(inflight (message) => {
  log(message);

  let msg = Message.parseJson(message);

  email.sendEmail(
    subject: msg.subject,
    body: msg.body,
    to: msg.to,
    topicName: msg.topicName,
  );

  util.sleep(1s);
});

website.addEnvironment("apiUrl", api.url);

api.post("/subscribe", inflight (req) => {
  try {
    let body = SubscribeRequest.parseJson(req.body!);

    email.createContact(emailAddress: body.emailAddress);

    email.createEmailIdentity(emailIdentity: body.emailAddress);

    return {
      status: 200,
    };
  } catch error {
    log("{error}");

    return {
      status: 500,
    };
  }
});

api.post("/send-email", inflight (req) => {
  let apiKey = secret.value();

  try {
    if req.headers!.get("x-api-key") != apiKey {
      return {
        status: 403,
      };
    }

    let body = SendEmailRequest.parseJson(req.body!);

    for contacts in email.listContacts(topicName: body.topicName, pageSize: RATE_PER_SECONDS) {
      let to = MutArray<str>[];

      for contact in contacts {
        to.push(contact.emailAddress);
      }

      queue.push(Json.stringify(Message {
        subject: body.subject,
        body: body.body,
        to: unsafeCast(to),
        topicName: body.topicName,
      }));
    }

    return {
      status: 200,
    };
  } catch error {
    log("{error}");

    return {
      status: 403,
    };
  }
});
