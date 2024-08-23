'use strict';
exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const random = Math.random();
  const redirectDomain = random < 0.5 ? 'tf.fritzalbrecht.com' : 'cdk.fritzalbrecht.com';

  console.info(`Random value: ${random}`);
  console.info(`Redirecting to: ${redirectDomain}`);

  const response = {
    status: '302',
    statusDescription: 'Found',
    headers: {
      location: [{
        key: 'Location',
        value: `https://${redirectDomain}`,
      }],
    },
  };
  return response;
};