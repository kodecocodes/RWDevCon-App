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

private let kCellContentHeight: CGFloat = 45

enum SessionCellDisplayMode: Int {
  case compact = 55
  case regular = 75
}

final class SessionCell: UITableViewCell {
  @IBOutlet private var talkTypeIcon: UIView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtitleLabel: UILabel!
  @IBOutlet private var rwconnectImageView: UIImageView!

  @IBOutlet private var verticalSpacing: [NSLayoutConstraint]!

  override func awakeFromNib() {
    super.awakeFromNib()
    update(forDisplayMode: .regular)
  }

  var session: Session! {
    didSet {
      talkTypeIcon.backgroundColor = session.type.color
      titleLabel.text = session.title
      subtitleLabel.text = session.location
      rwconnectImageView.isHidden = session.type != .rwconnect
    }
  }

  func update(forDisplayMode displayMode: SessionCellDisplayMode) {
    let spacing = CGFloat(displayMode.rawValue) - kCellContentHeight
    verticalSpacing.forEach { $0.constant = spacing / 2 }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    talkTypeIcon.layer.cornerRadius = talkTypeIcon.bounds.height / 2
  }
}
