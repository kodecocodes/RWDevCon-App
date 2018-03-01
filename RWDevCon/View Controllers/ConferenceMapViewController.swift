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

final class ConferenceMapViewController: UIViewController {
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var doneButton: UIButton!

  private let tapGesture = UITapGestureRecognizer()

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    doneButton.isHidden = modalPresentationStyle == .pageSheet
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    scrollView.flashScrollIndicators()

    addTapGesture()
  }

  private func addTapGesture() {
    tapGesture.addTarget(self, action: #selector(handleTap(sender:)))
    tapGesture.delegate = self
    view.window?.addGestureRecognizer(tapGesture)
  }

  @objc
  private func handleTap(sender: UITapGestureRecognizer) {
    if !view.bounds.contains(sender.location(in: view)) {
      dismiss()
    }
  }

  @IBAction private func dismiss() {
    tapGesture.view?.removeGestureRecognizer(tapGesture)
    dismiss(animated: true, completion: nil)
  }
}

extension ConferenceMapViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
  {
    return true
  }
}
