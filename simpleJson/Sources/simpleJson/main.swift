import HeliumLogger
import Kitura
import SwiftyJSON
import Foundation

HeliumLogger.use()

let router = Router()

router.get("/products") {
    request, response, next in
    defer { next() }
    let product = Product(id: "1", title: "product1", content: "nothing")
    if let encodedJson = try? JSONEncoder().encode(product) {
        let json = JSON(encodedJson)
        response.status(.OK).send(json: json)
    }
}


Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()



