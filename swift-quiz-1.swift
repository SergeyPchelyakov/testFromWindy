import UIKit

protocol ReaderDelegate: class {
    func didReadData(data: Data)
}

class Reader{
    var file: String!
    var output: ReaderDelegate?
    var readCompleteBlock: (() -> Void)?
    
    func read() {
        let fileUrl = URL(fileURLWithPath: file!)
        let data = try? Data(contentsOf: fileUrl)
        self.output?.didReadData(data: data!)
        self.readCompleteBlock?();
    }
}

class orderReader: ReaderDelegate {
    public var reader: Reader
    init(_ file: URL) {
        self.reader = Reader()
        self.reader.file = file.absoluteString.replacingOccurrences(of: "file://", with: "")
        self.reader.output = self
        self.reader.readCompleteBlock = {
            self.didComplete()
        }
    }
    
    func Read() {
        self.reader.read()
    }
    
    func didComplete() {
        print("end of file")
    }
    
    func didReadData(data: Data) {
        print("\(data)")
    }
}

let filePath = Bundle.main.path(forResource: "myOrders.csv", ofType: nil)
let orderReader = orderReader(URL(fileURLWithPath: filePath!))
orderReader.Read()