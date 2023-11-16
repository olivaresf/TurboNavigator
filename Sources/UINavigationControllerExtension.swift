import UIKit

extension UINavigationController {
    func replaceLastViewController(with viewController: UIViewController) {
        let viewControllers = viewControllers.dropLast()
        setViewControllers(viewControllers + [viewController], animated: false)
    }
    
    func refreshNativeTopViewController() {
        if let topViewController = topViewController as? TurboNativeRefreshable {
            topViewController.refresh()
        }
    }
}
