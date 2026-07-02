//
//  EditLocalFunction.swift
//  TIMER
//
//  Created by Aditya Maroo on 03/10/24.
//

import Foundation
///
///Interval Item Change on cut
///
func cutChangeIndex(selectedIntervalItem: [IntervalItem], totalIntervalItem: [IntervalItem])-> [IntervalItem]{
    let newintervalListData = totalIntervalItem.filter{
        !selectedIntervalItem.contains($0)
    }
//    for index in 0..<newintervalListData.count{
//        newintervalListData[index].indexValue = Int64(index)
//    }
    return newintervalListData
}
///
///Message Index Change on Cut
///
func cutChangeMessageIndex(selectedMessage: [MessageItems], totalMessage: [MessageItems])-> [MessageItems]{
    let newMessageList = totalMessage.filter{
        !selectedMessage.contains($0)
    }
    for index in 0..<newMessageList.count{
        newMessageList[index].indexValue = Int64(index)
    }
    return newMessageList
}
///
///Item index Change on cut
///
func cutChangeItemIndex(selectedMessage: [Item], totalMessage: [Item])-> [Item]{
    let newMessageList = totalMessage.filter{
        !selectedMessage.contains($0)
    }
    for index in 0..<newMessageList.count{
        newMessageList[index].indexValue = Int64(index)
    }
    return newMessageList
}
