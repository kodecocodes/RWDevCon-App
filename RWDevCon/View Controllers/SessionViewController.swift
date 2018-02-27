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

final class SessionViewController: UIViewController, SessionSharer, SessionFavoriter {
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var descriptionLabel: UILabel!
  @IBOutlet private var locationButton: UIButton!
  @IBOutlet private var timeLabel: UILabel!
  @IBOutlet private var pageControl: UIPageControl!
  @IBOutlet private var speakerScrollView: UIScrollView!
  @IBOutlet private var favoriteBarButtonItem: UIBarButtonItem!
  @IBOutlet private var rwConnectImage: UIImageView!

  private var speakerViews: [SpeakerView] = []

  var session: Session! {
    didSet { updateForCurrentSession() }
  }

  override var previewActionItems: [UIPreviewActionItem] {
    let titleKey = session.isFavorite ? "DELETE_FAVORITE" : "ADD_FAVORITE"
    let title = NSLocalizedString(titleKey, comment: "")
    let style: UIPreviewActionStyle = session.isFavorite ? .destructive : .default
    return [UIPreviewAction(title: title, style: style) { [weak self] _, _ in self?.toggleFavorite() }]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateForCurrentSession()

    // Update navigation bar in case we're the secondary view controller on iPad
    let image = UIImage(named: "rwdevcon-bg")
    navigationController?.navigationBar.setBackgroundImage(image, for: .default)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setToolbarHidden(true, animated: true)
  }

  private func updateForCurrentSession() {
    guard let session = session else {
      return
    }
    
    titleLabel?.text = session.title
    descriptionLabel?.text = session.description
    locationButton?.setTitle(session.location, for: .normal)
    timeLabel?.text = session.dayAndTime
    rwConnectImage?.isHidden = session.type != .rwconnect

    updateFavoriteBarButtonItem()
    updateSpeakers()
  }

  private func updateSpeakers() {
    guard let speakerScrollView = speakerScrollView else {
      return
    }

    speakerViews.forEach { $0.removeFromSuperview() }
    speakerViews = []

    session.speakers?.forEach(add)
    pageControl.numberOfPages = speakerViews.count
    speakerViews.last?.trailingAnchor.constraint(equalTo: speakerScrollView.trailingAnchor).isActive = true

    // Set scroll view height to highest SpeakerView to make sure it doesn't scroll vertically
    let heights = speakerViews.map { $0.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height }
    let effectiveHeight = heights.max() ?? 0
    speakerScrollView.heightAnchor.constraint(equalToConstant: effectiveHeight).isActive = true
  }

  private func add(speaker: Speaker) {
    let speakerView = SpeakerView(speaker: speaker)
    speakerScrollView.addSubview(speakerView)

    let aligningAnchor = speakerViews.last?.trailingAnchor ?? speakerScrollView.leadingAnchor

    NSLayoutConstraint.activate([
      speakerView.topAnchor.constraint(equalTo: speakerScrollView.topAnchor),
      speakerView.leadingAnchor.constraint(equalTo: aligningAnchor),
      speakerView.widthAnchor.constraint(equalTo: speakerScrollView.widthAnchor),
    ])

    speakerViews.append(speakerView)
  }

  private func updateFavoriteBarButtonItem() {
    let key = session.isFavorite ? "UNMARK_AS_FAVORITE" : "MARK_AS_FAVORITE"
    favoriteBarButtonItem.title = NSLocalizedString(key, comment: "")
  }

  @IBAction private func toggleFavorite() {
    toggleFavorite(session: session)
    updateFavoriteBarButtonItem()
  }

  @IBAction private func shareSession() {
    shareSession(session)
  }
}

extension SessionViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView == speakerScrollView {
      pageControl.currentPage = Int(ceil(scrollView.contentOffset.x / scrollView.bounds.width))
    }
  }
}
