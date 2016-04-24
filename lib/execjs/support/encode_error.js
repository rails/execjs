function encodeError(err) {
  var errMeta = {type: typeof(err), name: null, message: '' + err, stack: null};
  if (typeof(err) === 'object') {
    // Copy "message" and "name" since those are standard attributes for an Error
    if (typeof(err.name) !== 'undefined') errMeta.name = err.name;
    if (typeof(err.message) !== 'undefined') errMeta.message = err.message;
    if (typeof(err.stack) !== 'undefined') errMeta.stack = err.stack;
    // Copy all of the other properties that are tacked on the Error itself
    if (typeof(Object.assign) === 'function') Object.assign(errMeta, err);
  }
  return errMeta;
};
