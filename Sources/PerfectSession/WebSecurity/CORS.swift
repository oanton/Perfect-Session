//
//  CORS.swift
//  PerfectSession
//
//  Created by Jonathan Guthrie on 2017-01-13.
//
//

import PerfectHTTP


public class CORSheaders {

	/// Called once before headers are sent to the client. If needed, sets the cookie with the CORS headers.
	public static func make(_ request: HTTPRequest, _ response: HTTPResponse) {
		if SessionConfig.CORS.enabled && SessionConfig.CORS.acceptableHostnames.count > 0 {

			let origin = CSRFSecurity.getOrigin(request)
			if origin.isEmpty {
				// Auto-fail if no origin.
				print("CORS Warning: No Origin")
				return
			}
			let wildcards = SessionConfig.CORS.acceptableHostnames.filter({$0.contains("*") && $0 != "*"})

			var corsOK = false

			// check if specifically in inclusions
			if SessionConfig.CORS.acceptableHostnames.contains("*") {
				corsOK = true
			} else if SessionConfig.CORS.acceptableHostnames.contains(origin.lowercased()) {
				corsOK = true
			} else if wildcards.count > 0 {
				// check if covered by a wildcard
				for wInc in wildcards {
					let opts = wInc.split("*")
					if origin.startsWith(opts[0]) { corsOK = true }
					if origin.endsWith(opts.last!) { corsOK = true }
				}
			}
			// ADD CORS HEADERS?
			if corsOK {
				// headers here
				if SessionConfig.CORS.acceptableHostnames.count == 1, SessionConfig.CORS.acceptableHostnames[0] == "*" {
					response.addHeader(.accessControlAllowOrigin, value: "*")
				} else {
					response.addHeader(.accessControlAllowOrigin, value: "\(origin)")
				}

				// Access-Control-Allow-Methods
				let str = SessionConfig.CORS.methods.map{String(describing: $0)}
				response.addHeader(.custom(name: "Access-Control-Allow-Methods"), value: str.joined(separator: ", "))

				// Access-Control-Allow-Credentials
				if SessionConfig.CORS.withCredentials {
					response.addHeader(.custom(name: "Access-Control-Allow-Credentials"), value: "true")
				}
				// Access-Control-Max-Age
				if SessionConfig.CORS.maxAge > 0 {
					response.addHeader(.custom(name: "Access-Control-Max-Age"), value: String(SessionConfig.CORS.maxAge))
				}
			}
			
		}
	}
	
}
