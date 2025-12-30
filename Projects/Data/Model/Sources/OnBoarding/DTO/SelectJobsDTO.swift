//
//  SelectJobsDTO.swift
//  Model
//
//  Created by Wonji Suh  on 12/30/25.
//

//public typealias SelectJobsDTO = [SelectJobsDTOResponse]

public struct SelectJobsDTO: Decodable {
  public let data: [SelectJobsDTOResponse]
}


public struct SelectJobsDTOResponse: Decodable {
    let key, description: String
}
