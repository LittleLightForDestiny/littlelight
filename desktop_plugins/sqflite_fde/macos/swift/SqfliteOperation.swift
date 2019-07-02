//
//  Operation.m
//  sqflite
//
//  Created by Alexandre Roux on 09/01/2018.
//

import CoreFoundation
import FlutterMacOS

//#import <Foundation/Foundation.h>
//#import "SqfliteOperation.h"
//#import "SqflitePlugin.h"

// Abstract
class SqfliteOperation : NSObject {

    func getMethod() -> String! {
        return  nil
    }
    func getSql() -> String! {
        return nil
    }
    func getSqlArguments() -> [AnyObject]! {
        return nil
    }
    func getNoResult() -> Bool {
        return false
    }
    func getContinueOnError() -> Bool {
        return false
    }
    func success(results:NSObject!) {}

    func error(error:FlutterError!) {}
}

class SqfliteBatchOperation : SqfliteOperation {

    var dictionary:NSDictionary!
    var results:NSObject!
    var error:FlutterError!
    var noResult:Bool
    var continueOnError:Bool
    
    override init(){
        super.init()
    }


    override func getMethod() -> String {
        return dictionary.object(forKey: SqfliteParamMethod) as! String
    }

    override func getSql() -> String {
        return dictionary.object(forKey: SqfliteParamSql) as! String
    }

    override func getSqlArguments() -> [AnyObject] {
        let arguments:[AnyObject]! = dictionary.object(forKey: SqfliteParamSqlArguments) as? [AnyObject]
        return SqflitePlugin.toSqlArguments(rawArguments: arguments)
    }

    override func getNoResult() -> Bool {
        return noResult
    }

    override func getContinueOnError() -> Bool {
        return continueOnError
    }

    override func success(results:NSObject!) {
        self.results = results
    }

    override func error(error:FlutterError!) {
        self.error = error
    }

    func handleSuccess(results:NSMutableArray!) {
        if !self.getNoResult() {
            // We wrap the result in 'result' map
            results.add(NSDictionary(object: ((self.results == nil) ? NSNull() : self.results),
                                                                forKey:SqfliteParamResult as NSString))
        }
    }

    // Encore the flutter error in a map
    func handleErrorContinue(results:NSMutableArray!) {
        if !self.getNoResult() {
            // We wrap the error in an 'error' map
            let error:NSMutableDictionary! = NSMutableDictionary()
            error[SqfliteParamErrorCode] = self.error.code
            if self.error.message != nil {
                error[SqfliteParamErrorMessage] = self.error.message
            }
            if self.error.details != nil {
                error[SqfliteParamErrorData] = self.error.details
            }
            results.add(NSDictionary(object: error,
                                                          forKey:SqfliteParamError! as NSString))
        }
    }

    func handleError(result:FlutterResult) {
        result(error)
    }
}

class SqfliteMethodCallOperation : SqfliteOperation {

    var flutterMethodCall:FlutterMethodCall
    var flutterResult:FlutterResult
    
    override init(){
        super.init()
    }

    class func newWithCall(flutterMethodCall:FlutterMethodCall!, result flutterResult:@escaping FlutterResult) -> SqfliteMethodCallOperation! {
        let operation:SqfliteMethodCallOperation! = SqfliteMethodCallOperation()
        operation.flutterMethodCall = flutterMethodCall
        operation.flutterResult = flutterResult
        return operation
    }

    override func getMethod() -> String {
        return flutterMethodCall.method as String
    }

    override func getSql() -> String {
        let arguments:[String:Any] = flutterMethodCall.arguments as! [String:Any]
        return arguments[SqfliteParamSql] as! String
    }

    override func getNoResult() -> Bool {
        let arguments:[String:Any] = flutterMethodCall.arguments as! [String:Any]
        let noResult:NSNumber = arguments[SqfliteParamNoResult] as! NSNumber
        return noResult.boolValue
    }

    override func getContinueOnError() -> Bool {
        let arguments:[String:Any] = flutterMethodCall.arguments as! [String:Any]
        let noResult:NSNumber = arguments[SqfliteParamContinueOnError] as! NSNumber
        return noResult.boolValue
    }

    override func getSqlArguments() -> [AnyObject]! {
        let arguments:[String:Any] = flutterMethodCall.arguments as! [String:Any]
        let sqlArguments:[AnyObject]! = flutterMethodCall.arguments[SqfliteParamSqlArguments]
        return SqflitePlugin.toSqlArguments(arguments)
    }

    override func success(results:NSObject!) {
        flutterResult(results)
    }
    override func error(error:FlutterError!) {
        flutterResult(error)
    }
}
