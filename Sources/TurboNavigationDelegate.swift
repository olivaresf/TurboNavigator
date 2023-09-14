import SafariServices
import Turbo
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationDelegate: AnyObject {
    typealias RetryBlock = () -> Void

    /// Respond to authentication challenge presented by web servers behing basic auth.
    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    /// Optional. Allow or cancel a visit.
    /// If allowed, you may provide a view controller to be displayed, otherwise a new `VisitableViewController` is used.
    /// If rejected, no changes to navigation occur.
    /// If not implemented, proposals are accepted and a new `VisitableViewController` is displayed.
    ///
    /// - Parameter proposal: navigation destination
    /// - Returns: how to react to the visit proposal
    func response(forProposal proposal: VisitProposal) -> VisitProposalResponse

    /// Optional. An error occurred loading the request, present it to the user.
    /// Retry the request by executing the closure.
    /// If not implemented, will present the error's localized description and a Retry button.
    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retry: @escaping RetryBlock)

    /// Optional. Implement to customize handling of external URLs.
    /// If not implemented, will present `SFSafariViewController` as a modal and load the URL.
    func openExternalURL(_ url: URL, from controller: UIViewController)

    /// Optional. Implement to become the web view's navigation delegate after the initial cold boot visit is completed.
    /// https://github.com/hotwired/turbo-ios/blob/main/Docs/Overview.md#becoming-the-web-views-navigation-delegate
    func sessionDidLoadWebView(_ session: Session)
}

public extension TurboNavigationDelegate {
    
    func response(forProposal proposal: VisitProposal) -> VisitProposalResponse { .acceptWithVisitableViewController }

    func visitableDidFailRequest(_ visitable: Visitable, error: Error, retry: @escaping RetryBlock) {
        if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                retry()
            }
        }
    }

    func openExternalURL(_ url: URL, from controller: UIViewController) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            safariViewController.preferredControlTintColor = .tintColor
        }
        controller.present(safariViewController, animated: true)
    }

    func didReceiveAuthenticationChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }

    func sessionDidLoadWebView(_ session: Session) {}
}

public enum VisitProposalResponse : Equatable {
    case acceptWithVisitableViewController
    case acceptWithCustom(UIViewController)
    case reject
}
