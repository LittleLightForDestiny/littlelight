
import FlutterMacOS
import FMDB
import SQLite3

let _channelName:String = "com.tekartik.sqflite"
let _inMemoryPath:String = ":memory:"

let _methodGetPlatformVersion:String = "getPlatformVersion"
let _methodGetDatabasesPath:String = "getDatabasesPath"
let _methodDebugMode:String = "debugMode"
let _methodOptions:String = "options"
let _methodOpenDatabase:String = "openDatabase"
let _methodCloseDatabase:String = "closeDatabase"
let _methodExecute:String = "execute"
let _methodInsert:String = "insert"
let _methodUpdate:String = "update"
let _methodQuery:String = "query"
let _methodBatch:String = "batch"

// For open
let _paramReadOnly:String = "readOnly"
let _paramSingleInstance:String = "singleInstance"
// Open result
let _paramRecovered:String = "recovered"

// For batch
let _paramOperations:String = "operations"
// For each batch operation
let _paramPath:String = "path"
let _paramId:String = "id"
let _paramTable:String = "table"
let _paramValues:String = "values"

let _sqliteErrorCode:String = "sqlite_error"
let _errorBadParam:String = "bad_param" // internal only
let _errorOpenFailed:String = "open_failed"
let _errorDatabaseClosed:String = "database_closed"

// options
let _paramQueryAsMapList:String = "queryAsMapList"

// Shared
let SqfliteParamSql:String = "sql"
let SqfliteParamSqlArguments:String = "arguments"
let SqfliteParamNoResult:String = "noResult"
let SqfliteParamContinueOnError:String = "continueOnError"
let SqfliteParamMethod:String = "method"
// For each operation in a batch, we have either a result or an error
let SqfliteParamResult:String = "result"
let SqfliteParamError:String = "error"
let SqfliteParamErrorCode:String = "code"
let SqfliteParamErrorMessage:String = "message"
let SqfliteParamErrorData:String = "data"

let _extra_log:Bool = false // to set to true for type debugging

let logLevelNone = 0;
let logLevelSql = 1;
let logLevelVerbose = 2;
let logLevel = logLevelNone;


protocol SqfliteDatabase {
    var fmDatabaseQueue:FMDatabaseQueue! {get}
    var databaseId:NSNumber! {get}
    var path:String! {get}
    var singleInstance:Bool {get}
}

class SqflitePlugin : NSObject, FlutterPlugin {

    private var databaseMap:NSMutableDictionary!
    private var singleInstanceDatabaseMap:NSMutableDictionary!
    private var mapLock:NSObject!
    
    let _log:Bool = false
    let _extra_log:Bool = false
    
    let _queryAsMapList:Bool = false
    
    let _lastDatabaseId:Int = 0
    let _databaseOpenCount:Int = 0


    public static func register(with registrar:FlutterPluginRegistrar) {
        let channel:FlutterMethodChannel = FlutterMethodChannel(name:_channelName,
                                         binaryMessenger:registrar.messenger)
        let instance:SqflitePlugin = SqflitePlugin()
        registrar.addMethodCallDelegate(instance, channel:channel)
    }
    
    
    override init() {
        super.init()
        self.databaseMap = NSMutableDictionary()
        self.singleInstanceDatabaseMap = NSMutableDictionary()
        self.mapLock = NSObject()
    }

    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let wrapResult:FlutterResult = { res in
            DispatchQueue.main.async(execute: {
                result(res)
            })
        }
        
        if (_methodGetPlatformVersion == method) {
            result("iOS " + (ProcessInfo.processInfo.operatingSystemVersionString))
        } else if (_methodOpenDatabase == method) {
            self.handleOpenDatabaseCall(call: call, result: wrapResult)
//            self.handleOpenDatabaseCall(call result:wrappedResult);
//        } else if ([_methodInsert isEqualToString:call.method]) {
//            [self handleInsertCall:call result:wrappedResult];
//        } else if ([_methodQuery isEqualToString:call.method]) {
//            [self handleQueryCall:call result:wrappedResult];
//        } else if ([_methodUpdate isEqualToString:call.method]) {
//            [self handleUpdateCall:call result:wrappedResult];
//        } else if ([_methodExecute isEqualToString:call.method]) {
//            [self handleExecuteCall:call result:wrappedResult];
//        } else if ([_methodBatch isEqualToString:call.method]) {
//            [self handleBatchCall:call result:wrappedResult];
//        } else if ([_methodGetDatabasesPath isEqualToString:call.method]) {
//            [self handleGetDatabasesPath:call result:result];
//        } else if ([_methodCloseDatabase isEqualToString:call.method]) {
//            [self handleCloseDatabaseCall:call result:wrappedResult];
//        } else if ([_methodOptions isEqualToString:call.method]) {
//            [self handleOptionsCall:call result:result];
//        } else if ([_methodDebug isEqualToString:call.method]) {
//            [self handleDebugCall:call
//                result:result];
//        } else if ([_methodDebugMode isEqualToString:call.method]) {
//            [self handleDebugModeCall:call
//                result:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }

    func handleError(db:FMDatabase!, result:FlutterResult) -> Bool {
        // handle error
        if db.hadError() {
            result(FlutterError(code: _sqliteErrorCode,
                                              message:String(format:"%@", db.lastError() as CVarArg),
                                       details:nil))
            return true
        }
        return false
    }

    func handleError(db:FMDatabase!, operation:SqfliteOperation!) -> Bool {
        // handle error
        if db.hadError() {
            var details:NSMutableDictionary! = nil
            let sql:String! = operation.getSql()
            if sql != nil {
                details = NSMutableDictionary()
                details.setObject(sql, forKey:SqfliteParamSql as NSString)
                let sqlArguments:[AnyObject]! = operation.getSqlArguments()
                if sqlArguments != nil {
                    details.setObject(sqlArguments, forKey:SqfliteParamSqlArguments as NSString)
                }
            }

//            operation.error(error:FlutterError.errorWithCode(_sqliteErrorCode,
//                                                  message:String(format:"%@", db.lastError()),
//                                                  details:details))
            return true
        }
        return false
    }

//    class func toSqlValue(value:NSObject!) -> Data! {
//
//    }
//
//    class func fromSqlValue(sqlValue:NSObject!) -> NSObject! {
//
//    }
//
//    class func arrayIsEmpy(array:[AnyObject]!) -> Bool {
//
//    }
//
//    class func toSqlArguments(rawArguments:[AnyObject]!) -> [AnyObject]! {
//
//    }
//
//    class func fromSqlDictionary(sqlDictionary:NSDictionary!) -> NSDictionary! {
//
//    }
//
//    func executeOrError(db:FMDatabase!, call:FlutterMethodCall!, result:FlutterResult) -> Bool {
//
//    }
//
//    func executeOrError(db:FMDatabase!, operation:SqfliteOperation!) -> Bool {
//
//    }

    //
    // query
    //
//    func query(db:FMDatabase!, operation:SqfliteOperation!) -> Bool {
//
//    }

    func handleQueryCall(call:FlutterMethodCall!, result:FlutterResult) {
        
    }

    //
    // insert
    //
//    func insert(db:FMDatabase!, operation:SqfliteOperation!) -> Bool {
//
//    }

    func handleInsertCall(call:FlutterMethodCall!, result:FlutterResult) {

    }

    //
    // update
    //
//    func update(db:FMDatabase!, operation:SqfliteOperation!) -> Bool {
//
//    }

    func handleUpdateCall(call:FlutterMethodCall!, result:FlutterResult) {
        
    }

    //
    // execute
    //
//    func execute(db:FMDatabase!, operation:SqfliteOperation!) -> Bool {
//
//    }

    func handleExecuteCall(call:FlutterMethodCall!, result:FlutterResult) {

    }

    //
    // batch
    //
    func handleBatchCall(call:FlutterMethodCall!, result:FlutterResult) {

    }

//
    class func makeOpenResult(_ databaseId:NSNumber!, recovered:Bool) -> NSDictionary! {
        let result:NSMutableDictionary = NSMutableDictionary.init();
        result.setObject(databaseId, forKey: _paramId as NSString);
        if (recovered) {
            result.setObject(NSNumber.init(booleanLiteral: recovered), forKey: _paramRecovered as NSString);
        }
        return result;
    }

    //
    // open
    //
    func handleOpenDatabaseCall(call:FlutterMethodCall!, result:FlutterResult) {
        
    }

    //
    // close
    //
    func handleCloseDatabaseCall(call:FlutterMethodCall!, result:FlutterResult) {
        
    }

    //
    // Options
    //
    func handleOptionsCall(call:FlutterMethodCall!, result:FlutterResult) {
        
    }

    //
    // getDatabasesPath
    // returns the Documents directory on iOS
    //
    func handleGetDatabasesPath(call:FlutterMethodCall!, result:FlutterResult) {
        
    }

    func handleMethodCall(call:FlutterMethodCall, result:FlutterResult) {
        guard let arguments:[String:AnyObject] = call.arguments as? [String:AnyObject] else{
            print("Invalid params");
            return;
        }
        guard let path:String = arguments[_paramPath] as? String else{
            print("Invalid path param");
            return;
        }
        guard let readOnlyValue:NSNumber = arguments[_paramReadOnly] as? NSNumber else{
            print("Invalid read only param");
            return;
        }
        let readOnly:Bool = readOnlyValue.boolValue == true
        guard let singleInstanceValue:NSNumber = arguments[_paramSingleInstance] as? NSNumber else{
            print("Invalid single instance param");
            return;
        }
        let inMemoryPath:Bool = SqflitePlugin.isInMemoryPath(path);
        // A single instance must be a regular database
        let singleInstance:Bool = singleInstanceValue.boolValue != false && !inMemoryPath;

        let _log:Bool = SqflitePlugin.hasSqlLogLevel(logLevel);
        if (_log) {
            NSLog("opening %@ %@ %@", path, readOnly ? " read-only" : "", singleInstance ? "" : " new instance");
        }

        // Handle hot-restart for single instance
        // The dart code is killed but the native code remains
        if (singleInstance) {
            objc_sync_enter(self.mapLock)
            if let database:SqfliteDatabase = self.singleInstanceDatabaseMap?[path] as? SqfliteDatabase{
                if (_log) {
                    NSLog("re-opened singleInstance %@ id %@", path, database.databaseId)
                }
                result(SqflitePlugin.makeOpenResult(database.databaseId, recovered:true))
                return;
            }
            objc_sync_exit(self.mapLock)
        }
//
//        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path flags:(readOnly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE))];
//        bool success = queue != nil;
//
//        if (!success) {
//            NSLog(@"Could not open db.");
//            result([FlutterError errorWithCode:_sqliteErrorCode
//                message:[NSString stringWithFormat:@"%@ %@", _errorOpenFailed, path]
//                details:nil]);
//            return;
//        }
//
//        NSNumber* databaseId;
//        @synchronized (self.mapLock) {
//            SqfliteDatabase* database = [SqfliteDatabase new];
//            databaseId = [NSNumber numberWithInteger:++_lastDatabaseId];
//            database.fmDatabaseQueue = queue;
//            database.singleInstance = singleInstance;
//            database.databaseId = databaseId;
//            database.path = path;
//            database.logLevel = logLevel;
//            self.databaseMap[databaseId] = database;
//            // To handle hot-restart recovery
//            if (singleInstance) {
//                self.singleInstanceDatabaseMap[path] = database;
//            }
//            if (_databaseOpenCount++ == 0) {
//                if (hasVerboseLogLevel(logLevel)) {
//                    NSLog(@"Creating operation queue");
//                }
//            }
//
//        }
//
//        result([SqflitePlugin makeOpenResult: databaseId recovered:false]);
    }
    class func isInMemoryPath(_ path:String)->Bool {
    if (path == _inMemoryPath) {
        return true;
    }
    return false;
    }
    
    class func hasSqlLogLevel(_ logLevel:Int)->Bool {
    return logLevel >= logLevelSql;
    }
}
