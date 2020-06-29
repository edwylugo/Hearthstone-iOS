//
//  HearthstoreREST.swift
//  Hearthstone
//
//  Created by Edwy Lugo on 29/06/20.
//  Copyright © 2020 Edwy Lugo. All rights reserved.
//

import Foundation

enum HearthstoreError {
    case url
    case taskerror(error: Error)
    case noResponse(error: Error)
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON(error: Error)
}

class HearthstoreREST {
    
    // Endereço da API
    private static let basePath = "https://omgvamp-hearthstone-v1.p.rapidapi.com/info"
    
    // Arquivo de configurações
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        // config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type": "application/json", "x-rapidapi-host":"omgvamp-hearthstone-v1.p.rapidapi.com", "x-rapidapi-key":"b855fe6446msh7f628aeb6fed556p165dbfjsn518f58738ed7"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    // Compartilhar a Sessão URL //URLSession.shared
    private static let session = URLSession(configuration: configuration)
    
    
    // Carregar dados da entidade Sincronismo (GET)
           class func loadInfo(onComplete: @escaping (Info) -> Void, onError: @escaping (HearthstoreError) -> Void) {
               print("basePath: \(basePath)")
               guard let url = URL(string: basePath) else {
                   onError(.url)
                   return
               }

               // Criando tarefa
               let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in

                   if error == nil {
                       // checando objeto de resposta
                       guard let response = response as? HTTPURLResponse else {
                           onError(.noResponse(error: error!))
                           return
                       }

                       if response.statusCode == 200 {
                           guard let data = data else { return }

                           do {
                               let listloadInfo = try JSONDecoder().decode(Info.self, from: data)
                               onComplete(listloadInfo)

                            print("## Lista carregada com sucesso ##")
                            print("Classes: \(listloadInfo.classes.count)")
                            print("Races: \(listloadInfo.races.count)")
                            print("Types: \(listloadInfo.types.count)")

                           } catch {
                               print(error.localizedDescription)
                               onError(.invalidJSON(error: error))
                           }

                       } else {
                           print("Algum status inválido pelo servidor!!")
                           onError(.responseStatusCode(code: response.statusCode))
                       }
                   } else {
                       // To sem internet ou Modo Avião
                       onError(.taskerror(error: error!))
                   }
               }

               dataTask.resume()
           }
       }