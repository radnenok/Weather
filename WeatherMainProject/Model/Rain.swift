//
//  Rain.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 27.07.21.
//

import Foundation

import Foundation
struct Rain : Codable {
    let h: Int?

    enum CodingKeys: String, CodingKey {

        case h = "1h"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        h = try? values.decodeIfPresent(Int.self, forKey: .h)
    }

}
