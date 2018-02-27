/// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

final class ViewControllerRouter {

  private init() {}
  static let shared = ViewControllerRouter()

  private var scheduleViewController: ScheduleViewController!
  private var sessionViewController: SessionViewController!

  func configureSplitViewController(_ controller: UISplitViewController, initialSession: Session) {
    controller.delegate = self

    let viewControllers = controller.viewControllers as! [UINavigationController]

    // When we launch from a deep link on iOS 11, the split view controller isn't fully configured yet and
    // only has 1 item in its `viewControllers` array. In that case we just push the second view controller
    // on the stack manually ¯\_(ツ)_/¯

    if viewControllers.count == 1 {
      let sessionViewController: SessionViewController = controller.storyboard!.instantiateViewController()
      sessionViewController.session = initialSession
      viewControllers.first!.pushViewController(sessionViewController, animated: false)
    } else {
      scheduleViewController = viewControllers.first!.viewControllers.first! as! ScheduleViewController
      sessionViewController = viewControllers.last!.viewControllers.first! as! SessionViewController
      sessionViewController.session = initialSession
    }
  }
}

extension ViewControllerRouter: UISplitViewControllerDelegate {
  func splitViewController(_ splitViewController: UISplitViewController,
                           collapseSecondary secondaryViewController: UIViewController,
                           onto primaryViewController: UIViewController) -> Bool
  {
    return true
  }
}
