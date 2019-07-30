//
//  Score.swift
//  SetGame
//
//  Created by Lukas on 30/07/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//


/**
 Player's score value
 
 - author:
 Lukas Lizal
 */
class Score {
    var playerScore: Int = 0
    
    func reset() {
        self.playerScore = 0
    }
    
    func increaseScore() {
        self.playerScore += 3
    }
    
    func penalty() {
        self.playerScore += 1
    }
}
