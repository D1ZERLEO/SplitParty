//
//  AppRoute.swift
//  Split Party
//
//  Created by Дарья Шаталова on 10/31/25.
//


enum AppRoute: Hashable {
    case login
    case register
    case forgotPassword
    case enterCode(isRegistration: Bool)
    case resetPassword
    case passwordChanged
    case home
}