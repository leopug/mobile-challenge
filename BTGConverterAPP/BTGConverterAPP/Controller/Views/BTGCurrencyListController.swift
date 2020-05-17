//
//  BTGCurrencyListController.swift
//  BTGConverterAPP
//
//  Created by Leonardo Maia Pugliese on 16/05/20.
//  Copyright © 2020 Leonardo Maia Pugliese. All rights reserved.
//

import Foundation

protocol CurrencyListController {
    func getCurrencyToCurrencyReceiver()
}

class BTGCurrencyListController: CurrencyListController {

    private let networkController = BTGNetworkController.shared
    weak private var currencyListReceiver : CurrencyListReceiver?
    private let localStorage : LocalStorage = BTGLocalStorage()
    
    private var currencyDescriptionList : [CurrencyDescription] = []
    
    init(currencyListReceiver: CurrencyListReceiver) {
        self.currencyListReceiver = currencyListReceiver
    }
    
    func getCurrencyToCurrencyReceiver() {
        
        if localStorage.isLocalStorageValid(ofType: .avaliableQuotes) {
            currencyDescriptionList = localStorage.getAvaliableQuotes()!
            print("got from the cacheeee avaliable currencies")
        } else {
            print("got from the weeeb avaliable currencies")
            networkController.getAvaliableCurrencies {[weak self] result in
                switch result {
                case .success(let avaliableCurrencies):
                    self?.setCurrencyDescription(from: avaliableCurrencies)
                    
                    guard let currencyListReceiver    = self?.currencyListReceiver ,
                          let currencyDescriptionList = self?.currencyDescriptionList else { return }
                    currencyListReceiver.setCurrencyDescriptions(currencyDescriptions: currencyDescriptionList)
                    self?.localStorage.setAvaliableQuotes(self!.currencyDescriptionList)
                case .failure(let error):
                    self?.currencyListReceiver?.showErrorMessage(message: error.rawValue)
                }
            }
        }
    }
    
    func setCurrencyDescription(from avaliableCurrencies: AvaliableCurrencies) {
        for (abbreviation, fullDescription) in avaliableCurrencies.currencies {
            let currencyDescription = CurrencyDescription(abbreviation: abbreviation, fullDescription: fullDescription)
            if !currencyDescriptionList.contains(currencyDescription) {
               currencyDescriptionList.append(CurrencyDescription(abbreviation: abbreviation, fullDescription: fullDescription))
            }
        }
    }
    
}