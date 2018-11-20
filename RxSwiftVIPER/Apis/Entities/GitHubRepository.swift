//
//  GitHubRepository.swift
//  RxSwiftVIPER
//
//  Created by 林　翼 on 2018/11/20.
//  Copyright © 2018年 Tsubasa Hayashi. All rights reserved.
//

import Foundation

struct GitHubRepository: Decodable {
    let id: Int
    let fullName: String
    let description: String
    let stargazersCount: Int
    let url: String

    private enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case description
        case stargazersCount = "stargazers_count"
        case url = "html_url"
    }
}

struct SearchRepositoriesResponse: Decodable {
    let items: [GitHubRepository]
}
