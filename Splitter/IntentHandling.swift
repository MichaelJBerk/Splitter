//
//  IntentHandling.swift
//  IntentHandling
//
//  Created by Michael Berk on 10/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import AppKit
import Intents

@available(macOS 12.0, *)
extension AppDelegate {
    func application(_ application: NSApplication, handlerFor intent: INIntent) -> Any? {
        if intent is StartRunIntent || intent is OpenRunIntent {
            return RunIntentHandler()
        }
        if intent is GetOpenRunsIntent {
            return GetOpenRunsIntentHandler()
        }
        return nil
    }
}
@available(macOS 12.0, *)
class RunIntentHandler: NSObject {
    enum RunIntentError: LocalizedError {
        case fileError
        
        var errorDescription: String? {
            switch self {
            case .fileError:
                return "The file chosen is invalid"
            }
        }
    }
    
    class RunIntentResponse: INIntentResponse {}
    
    func handleIntent(intent: RunIntent, completion: @escaping (Error?) -> Void) {
        if let file = intent.file, let fileURL = file.fileURL {
            NSDocumentController.shared.openDocument(withContentsOf: fileURL, display: true, completionHandler: {document, alreadyOpen, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                //Start the run, if it's the "Start Run" intent
                if intent is StartRunIntent {
                    if let splitterDoc = document as? SplitterDoc, let vc = splitterDoc.viewController {
                        vc.run.timer.start()
                    } else {
                        completion(RunIntentError.fileError)
                        return
                    }
                }
                completion(nil)
               
            })
        } else {
            completion(RunIntentError.fileError)
        }
    }
}
@available(macOS 12.0, *)
extension RunIntentHandler: StartRunIntentHandling {
    func handle(intent: StartRunIntent, completion: @escaping (StartRunIntentResponse) -> Void) {
        handleIntent(intent: intent, completion: { error in
            if let error = error {
                let alert = NSAlert(error: error)
                NSApp.beginModalSession(for: alert.window)
                completion(.init(code: .failure, userActivity: nil))
            } else {
                completion(.init(code: .success, userActivity: nil))
            }
        })
    }
}

@available (macOS 12.0, *)
extension RunIntentHandler: OpenRunIntentHandling {
    func handle(intent: OpenRunIntent, completion: @escaping (OpenRunIntentResponse) -> Void) {
        handleIntent(intent: intent, completion: { error in
            if let error = error {
                let alert = NSAlert(error: error)
                NSApp.beginModalSession(for: alert.window)
                completion(.init(code: .failure, userActivity: nil))
            } else {
                completion(.init(code: .success, userActivity: nil))
            }
        })
    }
    
    
}

@available (macOS 12.0, *)
protocol RunIntent {
    var file: INFile? {get set}
}

@available(macOS 12.0, *)
extension StartRunIntent: RunIntent {}

@available(macOS 12.0, *)
extension OpenRunIntent: RunIntent {}

@available (macOS 12.0, *)
class GetOpenRunsIntentHandler: NSObject, GetOpenRunsIntentHandling {
    
    func handle(intent: GetOpenRunsIntent, completion: @escaping (GetOpenRunsIntentResponse) -> Void) {
        let docs: [INFile] = NSDocumentController.shared.documents.compactMap {
            if let url = $0.fileURL {
                let uti = try? NSWorkspace.shared.type(ofFile: url.path)
                return INFile(fileURL: url, filename: $0.displayName, typeIdentifier: uti)
            } else {return nil}
        }
        let response = GetOpenRunsIntentResponse(code: .success, userActivity: nil)
        response.files = docs
        completion(response)
    }
}
