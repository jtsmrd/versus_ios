//
//  User.swift
//  Versus
//
//  Created by JT Smrdel on 4/12/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class User: Codable {
    
    private var _id: Int?
    private var _bio: String?
    private var _name: String?
    private var _email: String?
    private var _enabled: Bool?
    private var _featured: Bool?
    private var _rankId: Int?
    private var _updateDate: Date?
    private var _username: String?
    private var _entries: [Entry]?
    private var _profileImage: String?
    private var _backgroundImage: String?
    private var _followedUserCount: Int?
    private var _followerCount: Int?
    private var _totalTimesVoted: Int?
    private var _totalWins: Int?
    private var _apnsToken: String?
    
    var profileImageDownloadState: ImageDownloadState = .new
    var profileImageImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _bio = "bio"
        case _name = "name"
        case _email = "email"
        case _enabled = "enabled"
        case _featured = "featured"
        case _rankId = "rankId"
        case _updateDate = "updateDate"
        case _username = "username"
        case _entries = "entries"
        case _profileImage = "profileImage"
        case _backgroundImage = "backgroundImage"
        case _followedUserCount = "followedUserCount"
        case _followerCount = "followerCount"
        case _totalTimesVoted = "totalTimesVoted"
        case _totalWins = "totalWins"
        case _apnsToken = "apnsToken"
    }
}

extension User {
    
    
    var backgroundImage: String {
        get {
            return _backgroundImage ?? ""
        }
        set {
            _backgroundImage = newValue
        }
    }
    
    
    var bio: String {
        get {
            return _bio ?? ""
        }
        set {
            _bio = newValue
        }
    }
    
    
    var email: String {
        return _email ?? ""
    }
    
    
    var entries: [Entry] {
        return _entries ?? [Entry]()
    }
    
    
    var name: String {
        get {
            return _name ?? ""
        }
        set {
            _name = newValue
        }
    }
    
    
    var followedUserCount: Int {
        return _followedUserCount ?? 0
    }
    
    
    var followerCount: Int {
        return _followerCount ?? 0
    }
    
    
    var featured: Bool {
        return _featured ?? false
    }
    
    
    var profileImage: String {
        get {
            return _profileImage ?? ""
        }
        set {
            _profileImage = newValue
        }
    }
    
    
    var rank: Rank {
        return Rank(rankId: _rankId)
    }
    
    
    var totalTimesVoted: Int {
        return _totalTimesVoted ?? 0
    }
    
    
    var totalWins: Int {
        return _totalWins ?? 0
    }
    
    
    var id: Int {
        return _id ?? 0
    }
    
    
    var username: String {
        return _username ?? ""
    }
    
    var apnsToken: String? {
        get {
            return _apnsToken
        }
        set {
            _apnsToken = newValue
        }
    }
}
