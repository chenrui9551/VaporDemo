import Vapor
import VaporSQLite

class Customer: NodeRepresentable {
    var firstName: String!
    var lastName: String!

    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["firstName": self.firstName,
                     "lastName": self.lastName])
    }

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}

let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.get("hello") { req in
    return "Hello Vapor!"
}

drop.get("customers") { req in
    let customer = Customer(firstName: "Chen", lastName: "Rui")
    return try JSON(node: [customer])
}

drop.get("customers", Int.self) { req, id in
    return "The passed id is \(id)"
}

drop.get("version") { req in
    let result = try drop.database?.driver.raw("SELECT sqlite_version()")
    return try JSON(node: result)
}

drop.post("customer") { req in
    guard let firstName = req.json?["firstName"]?.string! else {
        fatalError("firstName is missing!")
    }

    guard let lastName = req.json?["lastName"]?.string! else {
        fatalError("lastName is missing!")
    }

    let result = try drop.database?.driver.raw("INSERT INTO Customers(firstName, lastName) VALUES(?, ?)", [firstName, lastName])

    return try JSON(node: ["success":true])
}

drop.get("helloJSON") { req in
    return JSON(["message":"Hello Vapor!"])
}

drop.run()
