//
//  RouteTests.swift
//  App
//
//  Created by Riyad Shauk on 10/4/18.
//
import Vapor
import XCTest

@testable import App

// For testing examples, see: https://github.com/vapor/vapor/blob/master/Tests/VaporTests/ApplicationTests.swift
class RouteTests: XCTestCase {
    func testContent() throws {
        let app = try Application()
        let req = Request(using: app)
        req.http.body = """
        {
            "hello": "world"
        }
        """.convertToHTTPBody()
        req.http.contentType = .json
        try XCTAssertEqual(req.content.get(at: "hello").wait(), "world")
    }
    
    func testShopperCreationValid() throws {
        try Application.makeTest { router in
            router.post(CreateShopperRequest.self, at: "shopper") { req, user -> String in
                return "ok"
            }
            }
            .test(.POST, "shopper", beforeSend: {
                try $0.content.encode(["name": "riyad", "password": "123", "verifyPassword": "123", "email": "a@b.com"])
            }, afterSend: { res in
                XCTAssertEqual(res.http.status, .ok)
            })
    }
    
    func testShopperCreationInvalidRequestBody() throws {
        try Application.makeTest { router in
            router.post(CreateShopperRequest.self, at: "shopper") { req, user -> String in
                return "ok"
            }
            }.test(.POST, "shopper", beforeSend: {
                try $0.content.encode(["name": "vapor"])
            }, afterSend: { res in
                XCTAssertEqual(res.http.status, .badRequest)
            })
    }
    
    func testShopperCreationInvalidPasswordVerification() throws {
        try Application.makeTest { router in
            router.post(CreateUserRequest.self, at: "shopper") { req, user -> String in
                let shopperController = ShopperController()
                let shopperResponseFuture = try shopperController.create(req)
                var status = "ok"
                shopperResponseFuture.whenFailure({ (Error) in
                    if Error.localizedDescription.contains("Password and verification must match.") {
                        status = "invalid password"
                    }
                })
                if status == "invalid password" {
                    throw Abort(.badRequest, reason: "Password and verification must match.")
                }
                return status
            }
            }.test(.POST, "shopper", beforeSend: {
                try $0.content.encode(["name": "riyad", "password": "123", "verifyPassword": "no", "email": "a@b.com"])
            }, afterSend: { res in
                XCTAssertEqual(res.http.status, .badRequest)
                XCTAssert(res.http.body.string.contains("Password and verification must match."))
            })
    }
    
//    func testShopper

    
}

// These private extensions (for tests to work) were taken directly from: https://github.com/vapor/vapor/blob/master/Tests/VaporTests/ApplicationTests.swift (commit af4cdf2bfaf46f87fdd4b4d1cec2ecf43b4cc6e5)
// MARK: Private
private extension Application {
    // MARK: Static
    static func makeTest(configure: (inout Config, inout Services) throws -> () = { _, _ in }, routes: (Router) throws -> ()) throws -> Application {
        var services = Services.default()
        var config = Config.default()
        try configure(&config, &services)
        
        let router = EngineRouter.default()
        try routes(router)
        services.register(router, as: Router.self)
        return try Application.asyncBoot(config: config, environment: .xcode, services: services).wait()
    }
    
    @discardableResult
    func test(
        _ method: HTTPMethod,
        _ path: String,
        beforeSend: @escaping (Request) throws -> () = { _ in },
        afterSend: @escaping (Response) throws -> ()
        ) throws  -> Application {
        let http = HTTPRequest(method: method, url: URL(string: path)!)
        return try test(http, beforeSend: beforeSend, afterSend: afterSend)
    }
    
    @discardableResult
    func test(
        _ http: HTTPRequest,
        beforeSend: @escaping (Request) throws -> () = { _ in },
        afterSend: @escaping (Response) throws -> ()
        ) throws -> Application {
        let promise = eventLoop.newPromise(Void.self)
        eventLoop.execute {
            let req = Request(http: http, using: self)
            do {
                try beforeSend(req)
                try self.make(Responder.self).respond(to: req).map { res in
                    try afterSend(res)
                    }.cascade(promise: promise)
            } catch {
                promise.fail(error: error)
            }
        }
        try promise.futureResult.wait()
        return self
    }
    
    // MARK: Live
    static func runningTest(port: Int, routes: (Router) throws -> ()) throws -> Application {
        let router = EngineRouter.default()
        try routes(router)
        var services = Services.default()
        services.register(router, as: Router.self)
        let serverConfig = NIOServerConfig(
            hostname: "localhost",
            port: port,
            backlog: 8,
            workerCount: 1,
            maxBodySize: 128_000,
            reuseAddress: true,
            tcpNoDelay: true//,
//            webSocketMaxFrameSize: 1 << 14
        )
        services.register(serverConfig)
        let app = try Application.asyncBoot(config: .default(), environment: .xcode, services: services).wait()
        try app.asyncRun().wait()
        return app
    }
    
    @discardableResult
    func clientTest(
        _ method: HTTPMethod,
        _ path: String,
        beforeSend: (Request) throws -> () = { _ in },
        afterSend: (Response) throws -> ()
        ) throws -> Application {
        let config = try make(NIOServerConfig.self)
        let path = path.hasPrefix("/") ? path : "/\(path)"
        let req = Request(
            http: .init(method: method, url: "http://localhost:\(config.port)" + path),
            using: self
        )
        try beforeSend(req)
        let res = try FoundationClient.default(on: self).send(req).wait()
        try afterSend(res)
        return self
    }
    
    @discardableResult
    func clientTest(_ method: HTTPMethod, _ path: String, equals: String) throws -> Application {
        return try clientTest(method, path) { res in
            XCTAssertEqual(res.http.body.string, equals)
        }
    }
}

private extension Environment {
    static var xcode: Environment {
        return .init(name: "xcode", isRelease: false, arguments: ["xcode"])
    }
}

private extension HTTPBody {
    var string: String {
        guard let data = self.data else {
            return "<streaming>"
        }
        return String(data: data, encoding: .ascii) ?? "<non-ascii>"
    }
}

private extension Data {
    var utf8: String? {
        return String(data: self, encoding: .utf8)
    }
}
