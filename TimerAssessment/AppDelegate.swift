//
//  AppDelegate.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Realmのマイグレーション設定
        configureRealm()
        return true
    }

    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 2, // memoフィールド追加のためバージョンを2に
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // memo フィールドは Optional なので、既存データには自動的に nil が設定される
                    // 特別な処理は不要
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
