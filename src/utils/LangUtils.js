/*
 * @flow
 */

const OBJECT_TYPE_TAGS = {
  STRING: '[object String]',
  WORKER: '[object Worker]'
};

export function objectToString(value :any) {

  return Object.prototype.toString.call(value);
}

export function isString(value :any) {

  // return typeof value == 'string' || (isObjectLike(value) && objectToString.call(value) == stringTag);
  return value !== undefined && value != null && objectToString(value) === OBJECT_TYPE_TAGS.STRING;
}

export function isWorker(value :any) {

  return value !== undefined && value != null && objectToString(value) === OBJECT_TYPE_TAGS.WORKER;
}
