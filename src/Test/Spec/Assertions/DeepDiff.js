"use strict";

function DeepDiffMapper() {

  this.VALUE_CREATED = 'created';
  this.VALUE_UPDATED = 'changed';
  this.VALUE_DELETED = 'deleted';
  this.VALUE_UNCHANGED = 'unchanged';

  this.map = function(obj1, obj2) {
    if (this.isFunction(obj1) || this.isFunction(obj2)) {
      throw 'Invalid argument. Function given, object expected.';
    }
    if (this.isValue(obj1) || this.isValue(obj2)) {
      return {
	changeType: this.compareValues(obj1, obj2),
	data: (obj1 === undefined) ? obj2 : obj1
      };
    }

    var diff = {};
    for (var key in obj1) {
      if (this.isFunction(obj1[key])) {
	continue;
      }

      var value2 = undefined;
      if ('undefined' != typeof(obj2[key])) {
	value2 = obj2[key];
      }

      diff[key] = this.map(obj1[key], value2);
    }
    for (var key in obj2) {
      if (this.isFunction(obj2[key]) || ('undefined' != typeof(diff[key]))) {
	continue;
      }

      diff[key] = this.map(undefined, obj2[key]);
    }

    return diff;

  };

  this.compareValues = function(value1, value2) {
    if (value1 === value2) {
      return this.VALUE_UNCHANGED;
    }
    if (
      this.isDate(value1)
      && this.isDate(value2)
      && value1.getTime() === value2.getTime()
    ) {
      return this.VALUE_UNCHANGED;
    }
    if ('undefined' == typeof(value1)) {
      return this.VALUE_CREATED;
    }
    if ('undefined' == typeof(value2)) {
      return this.VALUE_DELETED;
    }

    return this.VALUE_UPDATED;
  };

  this.isFunction = function(obj) {
    return {}.toString.apply(obj) === '[object Function]';
  };

  this.isArray = function(obj) {
    return {}.toString.apply(obj) === '[object Array]';
  };

  this.isDate = function(obj) {
    return {}.toString.apply(obj) === '[object Date]';
  };

  this.isObject = function(obj) {
    return {}.toString.apply(obj) === '[object Object]';
  };

  this.isValue = function(obj) {
    return !this.isObject(obj) && !this.isArray(obj);
  };
}

var deepDiffMapper = new DeepDiffMapper();

function getChangePathAndType(diff, changeVector){
  var change = { path: [], type: null };
  for (var key in diff){
    var val = diff[key];
    if (diff.hasOwnProperty(key) && val.changeType !== 'unchanged') {
      changeVector.push(key);
      if (val.changeType === undefined) change = getChangePathAndType(val, changeVector);
      else  return { path: changeVector, type: val.changeType };
    }
  };
  return change;
};

exports.deepDiff = function(obj1){
  return function(obj2){
    return deepDiffMapper.map(obj1, obj2);
  };
};

exports._getFirstChange = function(_Just) {
  return function(_Nothing){
    return function(diff){
      var change = getChangePathAndType(diff, []),
	  changePathStr = "";

      change.path.forEach(function(key){
	changePathStr += key + ".";
      });

      if (changePathStr === "") return _Nothing;
      else return _Just({
	path: changePathStr.slice(0, -1),
	changeType: change.type
      });
    };
  };
};
