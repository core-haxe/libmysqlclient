package mysql;

class MySqlClientError {
    public var errorMessage:String;
    public var errorNumber:Int;

    public function new(errorMessage:String, errorNumber:Int) {
        this.errorMessage = errorMessage;
        this.errorNumber = errorNumber;
    }

    public function toString():String {
        return errorMessage + " (" + errorNumber + ")";
    }
}