/*
 * @flow
 */

import WorkerTask from './WorkerTask';

import * as LangUtils from '../utils/LangUtils';

// let uniqueTaskIdCounter = 0;
//
// export default class WorkerThread {
//
//   workerKey :string;
//   worker :Object;
//   taskQueue :WorkerTask[];
//   isWorkerAvailable :boolean;
//
//   constructor(workerKey :number, workerInstance :Object) {
//
//     if (!LangUtils.isWorker(workerInstance)) {
//       throw new Error('missing required argument: workerInstance');
//     }
//
//     this.workerKey = workerKey;
//     this.worker = workerInstance;
//     this.taskQueue = [];
//     this.isWorkerAvailable = true;
//
//     this.initializeWorker();
//   }
//
//   initializeWorker() {
//
//     this.worker.onerror = (errorEvent) => {
//
//       if (this.taskQueue.length > 0) {
//
//         const finishedTask = this.taskQueue.shift();
//         finishedTask.reject('uncaught error in worker');
//       }
//
//       this.isWorkerAvailable = true;
//       this.process();
//     };
//
//     this.worker.onmessage = (messageEvent) => {
//
//       if (this.taskQueue.length === 0) {
//         // we expect taskQueue to contain at least 1 task, one which the worker just finished processing
//         return;
//       }
//
//       const taskResult = messageEvent.data;
//
//       const finishedTask = this.taskQueue.shift();
//       if (finishedTask.details.id !== messageEvent.data.taskId) {
//         finishedTask.reject('expected task IDs to match');
//       }
//       else {
//         finishedTask.resolve(taskResult.result);
//       }
//
//       this.isWorkerAvailable = true;
//       this.process();
//     };
//   }
//
//   generateWorkerTaskId() :string {
//
//     return `${uniqueTaskIdCounter++}`;
//   }
//
//   runWorkerTask(workerTask :WorkerTask) :void {
//
//     this.taskQueue.push(workerTask);
//     this.process();
//   }
//
//   process() {
//
//     if (this.taskQueue.length === 0) {
//       return;
//     }
//
//     if (this.isWorkerAvailable) {
//
//       const headTask = this.taskQueue[0];
//       const transferableTask = headTask.asTransferableObject();
//
//       this.isWorkerAvailable = false;
//       this.worker.postMessage(transferableTask);
//     }
//   }
//
//   kill() {
//
//     this.worker.terminate();
//   }
// }

const WorkerThread = (() => {

  let uniqueTaskIdCounter = 0;

  class Impl {

    generateWorkerTaskId() {

      return `${uniqueTaskIdCounter++}`;
    }

    runWorkerTask() {}
    kill() {}
  }

  return Impl;
})();

export default WorkerThread;
