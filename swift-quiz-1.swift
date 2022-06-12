import UIKit

protocol ReaderDelegate: class { // в этом случае class depricated, заменить на AnyObject
    func didReadData(data: Data) // можно проще назвать: didRead(data: Data)
}

class Reader{ // пробел перед скобкой + сделать класс final, как следствие будет direct dispatch
    var file: String! // переместить в параметры метода read. если оставить, то заменить implicit unwrap на explicit unwrap: String?
    var output: ReaderDelegate? // переименовать на delegate и сделать weak чтобы не было retain cycle
    var readCompleteBlock: (() -> Void)? // зачем нужен делегат и completion? как миниум переместить в параметры метода read
    
    func read() { // добавить параметры read(file: String?, completion: (() -> Void)?)
        let fileUrl = URL(fileURLWithPath: file!) // противоречит 8 стр.: implicit unwrap не нужнается в force unwrap. лучше проверить через guard
        let data = try? Data(contentsOf: fileUrl) // стр. 14-15 лучше вывести в др. поток, а completion вернуться в главный чтобы не тормозить гл. поток
        self.output?.didReadData(data: data!) // заменить force unwrap на проверку через guard
        self.readCompleteBlock?(); // лишние скобки и точка с запятой. вообще не понятно, зачем здесь и делегат и completion. может оставить что-то одно?
    }
}

class orderReader: ReaderDelegate { // название класса должно начинаться с большой буквы + сделать класс final
    public var reader: Reader // нет смысла в public, т.к. OrderReader не паблик
    init(_ file: URL) { // в идеале лучше пробрасывать объект Reader в init, а не собирать его внутри init
        self.reader = Reader()
        self.reader.file = file.absoluteString.replacingOccurrences(of: "file://", with: "")
        self.reader.output = self
        self.reader.readCompleteBlock = {
            self.didComplete() // добавить [weak self]
        }
    }
    
    func Read() { // название метода должно быть с маленькой буквы: func read()
        self.reader.read()
    }
    
    func didComplete() { // сделать этот метод private
        print("end of file")
    }
    
    func didReadData(data: Data) {
        print("\(data)")
    }
}

let filePath = Bundle.main.path(forResource: "myOrders.csv", ofType: nil)
let orderReader = orderReader(URL(fileURLWithPath: filePath!)) // имя класса должно быть с большой буквы: OrderReader(URL...) 
                                                               // заменить force unwrap на проверку guard
orderReader.Read()
