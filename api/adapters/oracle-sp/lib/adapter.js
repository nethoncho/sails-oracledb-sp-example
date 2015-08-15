/**
 * Module Dependencies
 */

var oracledb = require('oracledb');
oracledb.outFormat = oracledb.OBJECT;

var WLError = require('../../../../node_modules/sails/node_modules/waterline/lib/waterline/error/WLError');

/**
 * oracle-sp
 *
 */
module.exports = (function () {


  var connections = {};

  var adapter = {

    syncable: false,

    // Default configuration for connections
    defaults: {
    },

    /**
     *
     * This method runs when a model is initially registered
     * at server-start-time.  This is the only required method.
     *
     * @param  {[type]}   connection [description]
     * @param  {[type]}   collection [description]
     * @param  {Function} cb         [description]
     * @return {[type]}              [description]
     */
    registerConnection: function(connection, collections, cb) {

      if(!connection.identity) return cb(new Error('Connection is missing an identity.'));
      if(!connection.cursorName) return cb(new Error('Connection is missing cursorName'));
      if(connections[connection.identity]) return cb(new Error('Connection is already registered.'));
      sails.log.debug('******************* oracle-sp: registerConnection');
      sails.log.debug(connection);

      oracledb.getConnection({
        user: connection.user,
        password: connection.password,
        connectString: connection.connectString
      },
        function(error, newConnection){
          if(error) {
            sails.log.error('oracle-sp: Could not connect to database');
            return;
          }
          connections[connection.identity] = {};
          connections[connection.identity].package = connection.package;
          connections[connection.identity].cursorName = connection.cursorName;
          connections[connection.identity].customExceptions = [];
          connections[connection.identity].oracledb = newConnection;
          sails.log.debug('******************* oracle-sp: Connected');
          if(connection.findCustomExceptions) {
            adapter.findCustomExceptions(connection.identity, connection.findCustomExceptions);
          }
      });

      cb();
    },


    /**
     * Fired when a model is unregistered, typically when the server
     * is killed. Useful for tearing-down remaining open connections,
     * etc.
     *
     * @param  {Function} cb [description]
     * @return {[type]}      [description]
     */
    // Teardown a Connection
    teardown: function (conn, cb) {

      if (typeof conn == 'function') {
        cb = conn;
        conn = null;
      }
      if (!conn) {
        connections = {};
        return cb();
      }
      if(!connections[conn]) return cb();
      delete connections[conn];
      cb();
    },


    // Return attributes
    describe: function (connection, collection, cb) {
			// Add in logic here to describe a collection (e.g. DESCRIBE TABLE logic)
      return cb();
    },

    /**
     *
     * REQUIRED method if integrating with a schemaful
     * (SQL-ish) database.
     *
     */
    define: function (connection, collection, definition, cb) {
			// Add in logic here to create a collection (e.g. CREATE TABLE logic)
      return cb();
    },

    /**
     *
     * REQUIRED method if integrating with a schemaful
     * (SQL-ish) database.
     *
     */
    drop: function (connection, collection, relations, cb) {
      // Add in logic here to delete a collection (e.g. DROP TABLE logic)
      return cb();
    },

    /**
     *
     * REQUIRED method if users expect to call Model.find(), Model.findOne(),
     * or related.
     *
     * You should implement this method to respond with an array of instances.
     * Waterline core will take care of supporting all the other different
     * find methods/usages.
     *
     */
    find: function (connection, collection, options, cb) {
      var queryString = '';
      var results = [];
      var bindVars = {};

      sails.log.debug('oracle-sp: find');

      queryString += 'BEGIN ';
      queryString += connections[connection].package + '.';
      queryString += collection + '_R(';

      if(options.hasOwnProperty('where') && _.isPlainObject(options.where)) {
        sails.log.debug('found where clause %j', options.where);
        _.forOwn(options.where, function(value, key) {
          queryString += 'P_' + key + ' => :' + key;
          queryString += ', ';
          bindVars[key] = value;
        });
      }

      queryString += 'P_' + connections[connection].cursorName + ' => :cursor';
      queryString += '); END;';

      sails.log.debug(queryString);

      bindVars.cursor = { type: oracledb.CURSOR, dir : oracledb.BIND_OUT };

      connections[connection].oracledb.execute(queryString, bindVars, function(err, result) {
        if(err) {
          return cb(adapter.processOracleError(err));
        }
        result.outBinds.cursor.getRows(1000, function(err, rows){ //TODO: FIXME: Hard codded for 1,000 rows for now. This needs to be refactored
          adapter.delayedCursorClose(result.outBinds.cursor);
          cb(null, rows);
        });
      });
    },

    create: function (connection, collection, values, cb) {
      var queryString = '';
      var results = [];
      var bindVars = {};

      delete values.createdAt; // Not used by this adapter
      delete values.updatedAt;

      sails.log.debug('oracle-sp: create');

      queryString += 'BEGIN ';
      queryString += connections[connection].package + '.';
      queryString += collection + '_C(';

      _.forOwn(values, function(value, key) {
        queryString += 'p_' + key + ' => :' + key;
        queryString += ', ';
        bindVars[key] = value;
      });

      queryString += 'p_details => :cursor';
      queryString += '); END;';

      sails.log.debug(queryString);

      bindVars.cursor = { type: oracledb.CURSOR, dir : oracledb.BIND_OUT };

      sails.log.debug(bindVars);

      connections[connection].oracledb.execute(queryString, bindVars, function(err, result) {
        if(err) {
          return cb(adapter.processOracleError(err));
        }
        result.outBinds.cursor.getRows(10, function(err, rows){ // should only return 1 row, set the limit to 10 for testing
          adapter.delayedCursorClose(result.outBinds.cursor);
          sails.log.debug(rows);
          cb(null, rows[0]);
        });
      });
    },

    update: function (connection, collection, options, values, cb) {
      var queryString = '';
      var bindVars = {};

      delete values.updatedAt;

      sails.log.debug('oracle-sp: update');
      sails.log.debug(options);
      sails.log.debug(values);
      var queryString = '';
      var bindVars = {};

      delete values.updatedAt;

      sails.log.debug('oracle-sp: update');
      sails.log.debug(options);
      sails.log.debug(values);

      queryString += 'BEGIN ';
      queryString += connections[connection].package + '.';
      queryString += collection + '_U(';

      if(options.hasOwnProperty('where') && _.isPlainObject(options.where)) {
        sails.log.debug('found where clause %j', options.where);
        _.forOwn(options.where, function(value, key) {
          queryString += 'P_' + key + ' => :' + key;
          bindVars[key] = value;
        });
      }

      _.forOwn(values, function(value, key) {
        queryString += ', P_' + key + ' => :' + key;
        bindVars[key] = value;
      });

      queryString += '); END;';

      sails.log.debug(queryString);
      sails.log.debug(bindVars);

      connections[connection].oracledb.execute(queryString, bindVars, function(err, result) {
        if(err) {
          return cb(adapter.processOracleError(err));
        } else {
          return cb(null, options.where);
        }
      });
    },

    destroy: function (connection, collection, options, cb) {
      var queryString = '';
      var bindVars = {};

      sails.log.debug('oracle-sp: destroy');
      sails.log.debug(options);

      queryString += 'BEGIN ';
      queryString += connections[connection].package + '.';
      queryString += collection + '_D(';

      if(options.hasOwnProperty('where') && _.isPlainObject(options.where)) {
        sails.log.debug('found where clause %j', options.where);
        _.forOwn(options.where, function(value, key) {
          queryString += 'P_' + key + ' => :' + key;
          bindVars[key] = value;
        });
      }

      queryString += '); END;';

      sails.log.debug(queryString);
      sails.log.debug(bindVars);

      connections[connection].oracledb.execute(queryString, bindVars, function(err, result) {
        if(err) {
          return cb(adapter.processOracleError(err));
        } else {
          return cb(null, options.where);
        }
      });
    },

    findCustomExceptions: function(identity, procedure) {
      setTimeout(function () {
        var queryString = '';
        var bindVars = {};

        queryString += 'BEGIN ';
        queryString += connections[identity].package + '.';
        queryString += procedure + '(';

        queryString += 'P_' + connections[identity].cursorName + ' => :cursor';
        queryString += '); END;';

        sails.log.debug(queryString);

        bindVars.cursor = { type: oracledb.CURSOR, dir : oracledb.BIND_OUT };

        connections[identity].oracledb.execute(queryString, bindVars, function(err, result) {
          if(err) {
            sails.log.warn('oracle-sp: could not find any custom exception messages');
            sails.log.debug(err);
            return;
          }
          result.outBinds.cursor.getRows(1000, function(err, rows){ //TODO: FIXME: Hard codded for 1,000 rows for now. This needs to be refactored
            adapter.delayedCursorClose(result.outBinds.cursor);
//            sails.log.debug('oracle-sp: custom exception messages')
            connections[identity].customExceptions = rows.slice();
//            sails.log.debug(connections[identity].customExceptions);
          });
        });
      }, 1);
    },

    processOracleError: function (error) {
      var formattedErr;
      sails.log.warn(error);
      var errorArray = error.toString().split(':');
      if(errorArray.length >= 2) {
        if(errorArray[0] === 'Error') {
          var errorValue = errorArray[1].trim();
          formattedErr = new WLError();
          formattedErr.code = 'E_USAGE';
          formattedErr.status = 409;
          formattedErr.reason = 'Oracle Error ' + errorValue;
          formattedErr.details = errorValue;
        }
      }
      return formattedErr || error;
    },

    delayedCursorClose: function (cursor) {
      setTimeout(function () {
        cursor.close(function(err){
          if(err) {
            sails.log.warn(err);
          }
        });
      }, 1000);
    }

  };

  // Expose adapter definition
  return adapter;

})();

