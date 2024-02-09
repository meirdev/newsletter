// email-sim.js

import child_process from "node:child_process";

import nodemailer from "nodemailer";

const runMailDev = () => {
  const child = child_process.exec(
    `docker run --rm -p 1080:1080 -p 1025:1025 maildev/maildev`
  );

  return () => child.kill();
};

exports._runMailDev = runMailDev;

const sendEmail = (from, to, subject, body) => {
  const transporter = nodemailer.createTransport({
    port: 1025,
    host: "localhost",
    tls: {
      rejectUnauthorized: false,
    },
  });

  const message = {
    from,
    to,
    subject,
    html: body,
  };

  transporter.sendMail(message, (error) => {
    if (error) {
      console.log(error);
    }
  });
};

exports._sendEmail = sendEmail;
