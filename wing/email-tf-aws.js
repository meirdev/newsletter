// email-tf-aws.js

import {
  SESv2Client,
  CreateEmailIdentityCommand,
  CreateContactCommand,
  DeleteContactCommand,
  UpdateContactCommand,
  ListContactsCommand,
  SendEmailCommand,
} from "@aws-sdk/client-sesv2";

const client = new SESv2Client();

const createContact = async (
  contactListName,
  { emailAddress, topicPreferences, unsubscribeAll }
) => {
  await client.send(
    new CreateContactCommand({
      ContactListName: contactListName,
      EmailAddress: emailAddress,
      TopicPreferences: topicPreferences,
      UnsubscribeAll: unsubscribeAll,
    })
  );
};

exports._createContact = createContact;

const updateContact = async (
  contactListName,
  { emailAddress, topicPreferences, unsubscribeAll }
) => {
  await client.send(
    new UpdateContactCommand({
      ContactListName: contactListName,
      EmailAddress: emailAddress,
      TopicPreferences: topicPreferences,
      UnsubscribeAll: unsubscribeAll,
    })
  );
};

exports._updateContact = updateContact;

const deleteContact = async (contactListName, { emailAddress }) => {
  await client.send(
    new DeleteContactCommand({
      ContactListName: contactListName,
      EmailAddress: emailAddress,
    })
  );
};

exports._deleteContact = deleteContact;

const listContacts = async (contactListName, { topicName, pageSize }) => {
  const allContacts = [];

  let nextToken = undefined;

  do {
    const response = await client.send(
      new ListContactsCommand({
        ContactListName: contactListName,
        Filter: {
          FilteredStatus: "OPT_IN",
          TopicFilter: topicName
            ? {
                TopicName: topicName,
                UseDefaultIfPreferenceUnavailable: true,
              }
            : undefined,
        },
        PageSize: pageSize,
        NextToken: nextToken,
      })
    );

    const contacts = response.Contacts.map(
      ({
        EmailAddress: emailAddress,
        TopicPreferences: topicPreferences,
        UnsubscribeAll: unsubscribeAll,
      }) => ({
        emailAddress,
        topicPreferences: topicPreferences?.map(
          ({
            TopicName: topicName,
            SubscriptionStatus: subscriptionStatus,
          }) => ({
            topicName,
            subscriptionStatus,
          })
        ),
        unsubscribeAll,
      })
    );

    allContacts.push(contacts);

    nextToken = response.NextToken;
  } while (nextToken);

  return allContacts;
};

exports._listContacts = listContacts;

const sendEmail = async (from, { to, subject, body, topicName }) => {
  await client.send(
    new SendEmailCommand({
      FromEmailAddress: from,
      Destination: {
        ToAddresses: to,
      },
      Content: {
        Simple: {
          Subject: {
            Charset: "UTF-8",
            Data: subject,
          },
          Body: {
            Html: {
              Charset: "UTF-8",
              Data: body,
            },
          },
        },
      },
      ListManagementOptions: topicName
        ? {
            ContactListName: "Default",
            TopicName: topicName,
          }
        : undefined,
    })
  );
};

exports._sendEmail = sendEmail;

const createEmailIdentity = async ({ emailIdentity }) => {
  await client.send(
    new CreateEmailIdentityCommand({
      EmailIdentity: emailIdentity,
    })
  );
};

exports._createEmailIdentity = createEmailIdentity;
