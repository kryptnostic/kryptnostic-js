/*
 * @flow
 */

console.log('Web Worker!');
console.log('================');

/* eslint-disable no-undef */
onmessage = function onmessage() {

  // postMessage('WebWorker: RSA keypair generation starting...');
  // Promise.resolve(
  //   generateRSAKeyPair()
  // ).then((rsaKeyPair) => {
  //   postMessage('WebWorker: RSA keypair generation finished.');
  //   postMessage(`WebWorker: rsaKeyPair.publicKey.byteLength = ${rsaKeyPair.publicKey.byteLength}`);
  //   postMessage(`WebWorker: rsaKeyPair.privateKey.byteLength = ${rsaKeyPair.privateKey.byteLength}`);
  // })
  // .catch((e) => {
  //   postMessage('WebWorker: RSA keypair generation failed');
  //   postMessage(e);
  // });


};
