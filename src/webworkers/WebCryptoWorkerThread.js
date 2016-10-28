/*
 * @flow
 */

import WebCryptoWorker from 'worker!./WebCryptoWorker';
import WorkerTask from './WorkerTask';
import WorkerThread from './WorkerThread';

const WEB_CRYPTO_WORKER_KEY = 'WEB_CRYPTO_WORKER';

export default class WebCryptoWorkerThread extends WorkerThread {

  constructor() {

    super(WEB_CRYPTO_WORKER_KEY, new WebCryptoWorker());
  }

  runCryptoTask(algorithm :string, operation :string, parameters :any) :Promise<any> {

    const taskId = this.generateWorkerTaskId();
    const cryptoTask = new WorkerTask(
      {
        algorithm,
        operation,
        parameters,
        id: taskId
      }
    );

    super.runWorkerTask(cryptoTask);

    return cryptoTask.asPromise();
  }
}
