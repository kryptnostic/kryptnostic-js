/*
 * @flow
 */

import WebCryptoWorkerThread from '../webworkers/WebCryptoWorkerThread';
import WebCryptoInterface from './WebCryptoInterface';

import * as WebCryptoAlgos from './constants/WebCryptoAlgorithms';
import * as WebCryptoOps from './constants/WebCryptoOperations';

class WebCryptoAPI extends WebCryptoInterface {}

const webCryptoWorkerThread = new WebCryptoWorkerThread();

WebCryptoAPI[WebCryptoAlgos.SHA_256][WebCryptoOps.DIGEST] = (data :Uint8Array) :Promise<Uint8Array> => {

  return webCryptoWorkerThread.runCryptoTask(
    WebCryptoAlgos.SHA_256,
    WebCryptoOps.DIGEST,
    data
  );
};

WebCryptoAPI[WebCryptoAlgos.SHA_512][WebCryptoOps.DIGEST] = (data :Uint8Array) :Promise<Uint8Array> => {

  return webCryptoWorkerThread.runCryptoTask(
    WebCryptoAlgos.SHA_512,
    WebCryptoOps.DIGEST,
    data
  );
};

// WebCryptoAPI[WebCryptoAlgos.AES_CTR_128][WebCryptoOps.ENCRYPT] = (data :Uint8Array) :Promise<Uint8Array> => {
//
//   const task = new WorkerTask({
//     algorithm: WebCryptoAlgos.AES_CTR_128,
//     operation: WebCryptoOps.ENCRYPT,
//     parameters: data
//   });
//   task.run();
//
//   // TaskRunner.registerRunner(webcryptoWorker);
//   // TaskRunner.newTask(task).run();
//   // TaskRunner.runTask(task);
//   //
//   // WorkerProxy.runTask(task);
//   // worker.runTask(task);
// };

/*
 *
 *
 *
 *
 *
 *
 *
 *
 */

/*
 * explore possibly inlining worker task
 */
// WebCryptoAPI.SHA_512.digest = (data :Uint8Array) :Promise<Uint8Array> => {
//
//   const workerTask = new WorkerTask({
//     algorithm: WebCryptoAlgos.SHA_256,
//     operation: WebCryptoOps.DIGEST,
//     parameters: data
//   });
//
//   const workerThread = WebCryptoWorker.newWorkerThread((task) => {
//     WebCryptoAPI.SHA_512.digest(data);
//   });
//
//   workerThread
//     .run(workerTask)
//     .then((result) => {
//       return result;
//     });
// };

export default WebCryptoAPI;
