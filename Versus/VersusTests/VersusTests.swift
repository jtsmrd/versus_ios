//
//  VersusTests.swift
//  VersusTests
//
//  Created by JT Smrdel on 1/12/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import XCTest
@testable import Versus

class VersusTests: XCTestCase {

    private let accountService = AccountService.instance
    private let voteService = VoteService.instance
    
    private var voteId: Int?
    
    override func setUp() {
        
        login()
    }

    override func tearDown() {
        
        CurrentAccount.setToken(token: "")
    }

    func login() {

        let loginPromise = expectation(description: "User logged in successfully.")
        
        accountService.login(
            username: "smrd813",
            password: "Passw0rd"
        ) { (account, error) in

            XCTAssertNotNil(account)
            XCTAssertNil(error)
            
            if account != nil {
                loginPromise.fulfill()
            }
            
            CurrentAccount.setAccount(account: account!)
        }
        
        wait(for: [loginPromise], timeout: 5)
    }
    
//    func testCreateVote() {
//
//        let votePromise = expectation(description: "User voted successfully.")
//
//        voteService.voteForEntry(
//            entryId: 21,
//            competitionId: 1
//        ) { (vote, error) in
//
////            self.voteId = vote?.id
//
//            if vote != nil {
//                votePromise.fulfill()
//            }
//
//            XCTAssertNotNil(vote)
//            XCTAssertNil(error)
//        }
//
//        wait(for: [votePromise], timeout: 5)
//    }
    
//    func testUpdateVote() {
//
//        let promise = expectation(description: "Vote updated successfully")
//
//        voteService.updateVote(
//            voteId: 26,
//            entryId: 66
//        ) { (vote, error) in
//
//            if vote != nil {
//                promise.fulfill()
//            }
//
//            XCTAssertNotNil(vote)
//            XCTAssertNil(error)
//        }
//
//        wait(for: [promise], timeout: 5)
//    }
    
    func testDeleteVote() {

        let deletePromise = expectation(description: "Vote deleted successfully")

        voteService.deleteVote(voteId: 26) { (error) in

            if error == nil {
                deletePromise.fulfill()
            }

            XCTAssertNil(error)
        }

        wait(for: [deletePromise], timeout: 5)
    }
    
    

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
