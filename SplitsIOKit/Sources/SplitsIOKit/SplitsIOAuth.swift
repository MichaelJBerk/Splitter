//
//  File.swift
//  
//
//  Created by Michael Berk on 8/11/20.
//

import Foundation
import Cocoa
import OAuth2
/// Class for handling authentication with Splits.io
///
/// To use this, you'll need to set up a client and secret on Splits.io.
public class SplitsIOAuth {
	let oAuth2: OAuth2CodeGrant
	
	/// Initalize SplitsIOAuth. Requires developer setup from Splits.io
	/// - Parameters:
	///   - client: Cleint ID
	///   - secret: Secret ID
	///   - redirects: Array of URI redirects for the application
	public init(client: String, secret: String, redirects: String) {
		oAuth2 = OAuth2CodeGrant(settings: [
		 "client_id": "\(client)",
			"client_secret": "\(secret)",
			"authorize_uri": "https://splits.io/oauth/authorize",
			"token_uri": "https://splits.io/oauth/token",
			"redirect_uris": [redirects],
			"scope": "upload_run delete_run manage_race",
			"keychain": "true",
		] as OAuth2JSON)
	}
	
	public func authenticate(completion: @escaping() -> ()) throws {
		oAuth2.logger = OAuth2DebugLogger(.trace)
		do {
			let url = try oAuth2.authorizeURL()
			try oAuth2.authorizer.openAuthorizeURLInBrowser(url)
			oAuth2.didAuthorizeOrFail = { authParams, error in
				print(self.oAuth2.accessToken)
				NotificationCenter.default.post(name: .splitsIOLogin, object: nil)
				completion()
				
			}
		} catch {
			print("authURL error:", error)

		}
		
		
		
	}
	public func logout(completion: @escaping() -> ()) {
		oAuth2.forgetTokens()
		NotificationCenter.default.post(name: .splitsIOLogout, object: nil)
		completion()
		
	}
	
	
}

extension Notification.Name {
	public static let splitsIOLogin = Notification.Name(rawValue: "splitsIOLogin")
	public static let splitsIOLogout = Notification.Name(rawValue: "splitsIOLogout")
}
