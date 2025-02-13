//
//  Coord.swift
//  TestApp
//
//  Created by Никита Лужбин on 13.02.2025.
//


struct Coord: Equatable, Hashable {
    let x: Int
    let y: Int
    
    static func +(lhs: Coord, rhs: Coord) -> Coord {
        return Coord(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}