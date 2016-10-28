/*
 * @flow
 */

export default class WorkerTask {

  details :Object;
  promise :Promise;
  resolve :Function;
  reject :Function;

  constructor(taskDetails :Object) {

    // TODO - check argument compatibility for transferring to a Web Worker

    this.details = taskDetails;

    this.promise = new Promise((resolve, reject) => {
      this.resolve = resolve;
      this.reject = reject;
    });
  }

  asPromise() {

    return this.promise;
  }

  asTransferableObject() {

    return this.details;
  }
}
