/*
 * @flow
 */

import WebCryptoWorkerAPI from './WebCryptoWorkerAPI';

import * as WebCryptoAlgorithms from '../webcrypto/constants/WebCryptoAlgorithms';
import * as WebCryptoOperations from '../webcrypto/constants/WebCryptoOperations';

function validateWebCryptoTask(task) {

  let taskId = null;
  let errorMessage = null;

  if (task === undefined || task == null) {
    errorMessage = 'INVALID_WORKER_TASK';
  }

  if (task.id === undefined || task.id == null) {
    errorMessage = 'WORKER_TASK_MISSING_TASK_ID';
  }
  else {
    taskId = task.id;
  }

  const algorithm = task.algorithm;
  if (!WebCryptoAlgorithms.isValidAlgorithm(algorithm)) {
    errorMessage = 'INVALID_WEB_CRYPTO_ALGORITHM';
  }

  const operation = task.operation;
  if (!WebCryptoOperations.isValidOperation(operation)) {
    errorMessage = 'INVALID_WEB_CRYPTO_OPERATION';
  }

  if (errorMessage) {
    postMessage({
      taskId,
      error: errorMessage
    });
    return false;
  }

  return true;
}

function onIncomingMessage(messageEvent) {

  const task = messageEvent.data;
  if (!validateWebCryptoTask(task)) {
    return;
  }

  const algorithm = task.algorithm;
  const operation = task.operation;
  const parameters = task.parameters;

  if (task.id === '0') {
    throw new TypeError('boom');
  }

  Promise
    .resolve(
      WebCryptoWorkerAPI[algorithm][operation](parameters)
    )
    .then((result) => {
      postMessage({
        result,
        taskId: task.id
      });
    });
}

/* eslint-disable no-undef */
onmessage = onIncomingMessage;
/* eslint-enable no-undef */
