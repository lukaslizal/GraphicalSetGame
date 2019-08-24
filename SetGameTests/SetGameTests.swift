//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Lukas on 23/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import XCTest
@testable import SetGame
class SetGameTests: XCTestCase {
    var sut: Game?

    override func setUp() {
        super.setUp()
        sut = Game()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitialCardCount() {
        // given
        let initialCardsOnTableCount = Game.Constants.initialCardCountOnTable

        // when
        // .. when in initial state

        // then
        XCTAssertEqual(sut?.cardsOnTable.count, initialCardsOnTableCount, "Wrong number of cards on table after new game started.")
        XCTAssertEqual(sut?.cardsInPack.count, 81 - initialCardsOnTableCount, "Wrong number of cards in pack after new game started.")
    }

    func testDealThreeCardsOnce() {
        let cardsToDeal = 3
        if var sut = sut {
            // given
            let cardsOnTable = sut.cardsOnTable.count
            let cardsInPack = sut.cardsInPack.count

            // when
            sut.dealCards(quantity: cardsToDeal)

            // then
            if cardsInPack - cardsToDeal >= 0 {
                XCTAssertEqual(sut.cardsInPack.count, cardsInPack - cardsToDeal, "Wrong number of cards in pack after dealt 3 cards.")
                XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsToDeal, "Wrong number of cards on table after dealt 3 cards.")
            }
            else {
                XCTAssertEqual(sut.cardsInPack.count, 0, "Wrong number of cards in pack after dealt 3 cards.")
                XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsInPack, "Wrong number of cards on table after dealt 3 cards.")
            }
        }
    }

    func testDealThreeCardsTenTimes() {
        let cardsToDeal = 3
        let iterations = 10
        for _ in 0..<iterations {
            if var sut = sut {
                // given
                let cardsOnTable = sut.cardsOnTable.count
                let cardsInPack = sut.cardsInPack.count

                // when
                sut.dealCards(quantity: cardsToDeal)

                // then
                if cardsInPack - cardsToDeal >= 0 {
                    XCTAssertEqual(sut.cardsInPack.count, cardsInPack - cardsToDeal, "Wrong number of cards in pack after dealt 3 cards.")
                    XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsToDeal, "Wrong number of cards on table after dealt 3 cards.")
                }
                else {
                    XCTAssertEqual(sut.cardsInPack.count, 0, "Wrong number of cards in pack after dealt 3 cards.")
                    XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsInPack, "Wrong number of cards on table after dealt 3 cards.")
                }
            }
        }
    }

    func testDealThreeCardsThirtyTimes() {
        let cardsToDeal = 3
        let iterations = 30
        for _ in 0..<iterations {
            if var sut = sut {
                // given
                let cardsOnTable = sut.cardsOnTable.count
                let cardsInPack = sut.cardsInPack.count

                // when
                sut.dealCards(quantity: cardsToDeal)

                // then
                if cardsInPack - cardsToDeal >= 0 {
                    XCTAssertEqual(sut.cardsInPack.count, cardsInPack - cardsToDeal, "Wrong number of cards in pack after dealt 3 cards.")
                    XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsToDeal, "Wrong number of cards on table after dealt 3 cards.")
                }
                else {
                    XCTAssertEqual(sut.cardsInPack.count, 0, "Wrong number of cards in pack after dealt 3 cards.")
                    XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsInPack, "Wrong number of cards on table after dealt 3 cards.")
                }
            }
        }
    }


    func testDealOneCard() {
        let cardsToDeal = 1
        if var sut = sut {
            // given
            let cardsOnTable = sut.cardsOnTable.count
            let cardsInPack = sut.cardsInPack.count

            // when
            sut.dealCards(quantity: cardsToDeal)

            // then
            if cardsInPack - cardsToDeal >= 0 {
                XCTAssertEqual(sut.cardsInPack.count, cardsInPack - cardsToDeal, "Wrong number of cards in pack after dealt 3 cards.")
                XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsToDeal, "Wrong number of cards on table after dealt 3 cards.")
            }
            else {
                XCTAssertEqual(sut.cardsInPack.count, 0, "Wrong number of cards in pack after dealt 3 cards.")
                XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsInPack, "Wrong number of cards on table after dealt 3 cards.")
            }
        }
    }

    func testDealTwentyCards() {
        let cardsToDeal = 20
        if var sut = sut {
            // given
            let cardsOnTable = sut.cardsOnTable.count
            let cardsInPack = sut.cardsInPack.count

            // when
            sut.dealCards(quantity: cardsToDeal)

            // then
            if cardsInPack - cardsToDeal >= 0 {
                XCTAssertEqual(sut.cardsInPack.count, cardsInPack - cardsToDeal, "Wrong number of cards in pack after dealt 3 cards.")
                XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsToDeal, "Wrong number of cards on table after dealt 3 cards.")
            }
            else {
                XCTAssertEqual(sut.cardsInPack.count, 0, "Wrong number of cards in pack after dealt 3 cards.")
                XCTAssertEqual(sut.cardsOnTable.count, cardsOnTable + cardsInPack, "Wrong number of cards on table after dealt 3 cards.")
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
