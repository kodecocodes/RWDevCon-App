/// Copyright (c) 2018 Razeware LLC
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

final class SpeakerView: UIView {
  @IBOutlet private var photo: UIImageView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var socialButton: UIButton!
  @IBOutlet private var bioLabel: UILabel!

  private let speaker: Speaker

  init(speaker: Speaker) {
    self.speaker = speaker
    super.init(frame: .zero)

    let objects = Bundle.main.loadNibNamed("SpeakerView", owner: self, options: nil)
    if let view = objects?.first as? UIView {
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        view.leadingAnchor.constraint(equalTo: leadingAnchor),
        view.trailingAnchor.constraint(equalTo: trailingAnchor),
        view.topAnchor.constraint(equalTo: topAnchor),
        view.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
    }

    translatesAutoresizingMaskIntoConstraints = false
    isUserInteractionEnabled = true
    backgroundColor = .clear
    
    photo.image = speaker.photo
    nameLabel.text = speaker.name
    socialButton.setTitle("@" + speaker.twitterHandle, for: .normal)
    bioLabel.text = speaker.bio
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction private func openSpeakerTwitterProfile() {
    let url = URL(string: "https://twitter.com/" + speaker.twitterHandle)!
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
