import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 使用此方法可选择性地配置UIWindow `window`并将其附加到提供的UIWindowScene `scene`。
        // 如果使用storyboard，`window`属性将自动初始化并附加到scene。
        // 此委托并不表示连接scene或session是新的（请参阅`application:configurationForConnectingSceneSession`）。
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 当scene被系统释放时调用（例如由于应用程序被终止或scene会话被丢弃）。
        // 释放与scene关联的任何资源，因为它们可能不会再次出现。
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 当scene从非活动状态变为活动状态时调用。
        // 使用此方法重新启动scene暂停时（或尚未启动）的任何任务。
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 当scene将从活动状态转换为非活动状态时调用。
        // 这可能发生在临时中断（例如来电）时。
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 当scene从后台进入前台时调用。
        // 使用此方法撤消进入后台时所做的更改。
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 当scene从前台进入后台时调用。
        // 使用此方法保存数据、释放共享资源并存储足够的scene状态信息，
        // 以便在scene重新连接时将其恢复到当前状态。
    }
}