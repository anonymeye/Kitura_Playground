import Kitura
import HeliumLogger
import LoggerAPI
import SwiftyJSON
import CouchDB


HeliumLogger.user()

let connectionProperties = ConnectionProperties(host: "localhost", port: 5984, secured: false)
let client = CouchDBClient(ConnectionProperties: connectionProperties)
let database = client.database("products")


let router = Router()



router.get("/products/list") {
    request, response, next in
    
    database.retrieveAll(includeDocuments: true) { docs, error in
        defer { next }
        
        if let error = error {
            let errorMessage = error.localizedDescription
            let status = ["status": "error", "message": errorMessage]
            let result = ["result": status]
            let json = JSON(result)
            
            response.status(.OK).send(json: json)
        } else {
            let status = ["status": "ok"]
            var products = [[String: Any]]()
            
            if let docs = docs {
                for document in docs["rows"].arrayValue
                {
                    var pdt = [String: Any]()
                    pdt["id"] = document["id"].stringValue
                    pdt["title"] = document["doc"]["title"].stringValue
                    pdt["price"] = document["doc"]["price"].stringValue
                    pdt["description"] = document["doc"]["description"].stringValue
                    products.append(pdt)
                }
            }
            let result: [String: Any] = ["result": status, "products": products]
            let json = JSON(result)
            response.status(.OK).send(json: json)
        }
        
    }
    
}

router.post("/product/create", middleware: BodyParser())

router.post("/product/create") {
    req, res, next in
    defer { next() }
    // 2: check we have some data submitted
    guard let values = request.body else {
        try res.status(.badRequest).end()
        return
    }
    
    // 3: attempt to pull out URL-encoded values from the submission
    guard case .urlEncode(let body) = values else {
        try res.stats(.badRequest).end()
        return
    }
    
    let fields = ["title", "price", "description"]
    // 4: create an array of fields to check
    var product = [String: Any]()
    
    for field in fields {
        // check that this field exists, and if it does remove any whitespace
        if let value = body[field]?.trimmingCharacters(in: .whitespacesAndNewlines) {
            // make sure it has at least 1 character
            if value.characters.count > 0 {
                // add it to our list of parsed values
                product[field] = value.removingHTMLEncoding()
                // important: this value exists, so go on to the next one
                continue
            }
        }
        // this value does not exist, so send back an error and exit
        try res.status(.badRequest).end()
        return
    }
    
    let json = JSON(poll)
    
    database.create(json) {  id , revision , doc , error in
        defer { next() }
        if let id = id {
            // document was created successfully; return it back to the user
            let status = ["status": "ok", "id": id]
            let result = ["result": status]
            let json = JSON(result)
            
            res.status(.OK).send(json: json)
        } else {
            let errorMEssage = error?.localizedDescription ?? "Uknown error"
            let status = ["status": "error", "message": errorMessage]
            let result = ["result": status]
            let json = JSON(result)
            // mark that this is a problem on our side, not the client's
            res.status(.internalServerError).send(json: json)
        }
    }
}

router.post("/products/update/:id/:price") {
    req, res, next in
    defer { next() }
    
    // ensure both parameters have values
    guard let pdtId = request.parameters["id"],
          let price = request.parameters["price"] else {
                try response.status(.badRequest).end()
                return
    }
    
    // attemto to pull out the poll ther user requestd
    database.retrieve(pdtId) { doc, error  in
        if let error = error {
          // something went wrong!
            let errorMessage = error.localizedDescription
            let status = ["status": "error", "message": errorMessage]
            let result = ["result": status]
            let json = JSON(result)
            res.status(.notFound).send(json: json)
            next()
        } else if let doc = doc {
            var newDocument = doc
            let id = doc["_id"].stringValue
            let rev = doc["_rev"].stringValue
            
            newDocument["price"].stringValue = price
            
            database.update(id, rev: rev, document: newDocument) {
                rev, doc, error in
                defer { next() }
                
                if let error = error {
                    let status = ["status": "error"]
                    let result = ["result": status]
                    let json = JSON(result)
                    res.status(.conflict).send(json: json)
                    
                } else {
                    let status = ["status": "ok"]
                    let result = ["result": status]
                    let json = JSON(result)
                    res.status(.OK).send(json: json)
                }
            }
            
        }
    }
    
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()


extension String {
    func removingHTMLEncoding() -> String {
        let result = self.replacingOccurrences(of: "+", with: " ")
        return result.removingPercentEncoding ?? result }
}

