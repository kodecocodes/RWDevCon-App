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

import ClockKit

final class ComplicationController: NSObject, CLKComplicationDataSource {

  private lazy var currentConference: Conference = {
    ConferenceManager.loadStoredData()
    return ConferenceManager.current
  }()

  func getSupportedTimeTravelDirections(
    for complication: CLKComplication,
    withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void)
  {
    handler([.forward, .backward])
  }

  func getTimelineStartDate(for complication: CLKComplication,
                            withHandler handler: @escaping (Date?) -> Void)
  {
    handler(currentConference.date.start)
  }

  func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
    handler(currentConference.date.end)
  }

  func getPrivacyBehavior(for complication: CLKComplication,
                          withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void)
  {
    handler(.showOnLockScreen)
  }

  // MARK: - Timeline Population

  func getCurrentTimelineEntry(for complication: CLKComplication,
                               withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
  {
    let entry = currentConference.currentSessions.first.flatMap { session in
      timelineEntry(for: session, complication: complication)
    }

    handler(entry)
  }

  func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int,
                          withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
  {
    let earlierSessions = currentConference.sessions.flatMap { $0 }.filter { $0.date.start < date }
    let earlierEntries = earlierSessions.flatMap { timelineEntry(for: $0, complication: complication) }
    handler(Array(earlierEntries.prefix(limit)))
  }

  func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int,
                          withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
  {
    let laterSessions = currentConference.sessions.flatMap { $0 }.filter { $0.date.start > date }
    let laterEntries = laterSessions.flatMap { timelineEntry(for: $0, complication: complication) }
    handler(Array(laterEntries.prefix(limit)))
  }

  private func timelineEntry(for session: Session, complication: CLKComplication)
    -> CLKComplicationTimelineEntry?
  {
    switch complication.family {
    case .modularLarge:
      let template = CLKComplicationTemplateModularLargeStandardBody()
      template.headerTextProvider = CLKSimpleTextProvider(text: session.title)
      template.body1TextProvider = CLKTimeIntervalTextProvider(interval: session.date)
      template.body2TextProvider = CLKSimpleTextProvider(text: session.location)

      return CLKComplicationTimelineEntry(date: session.date.start, complicationTemplate: template)

    case .utilitarianLarge:
      let template = CLKComplicationTemplateUtilitarianLargeFlat()
      template.textProvider = CLKSimpleTextProvider(text: session.title)

      return CLKComplicationTimelineEntry(date: session.date.start, complicationTemplate: template)

    default:
      return nil
    }
  }
}

private extension CLKTimeIntervalTextProvider {
  convenience init(interval: DateInterval) {
    self.init(start: interval.start, end: interval.end, timeZone: TimeZone(abbreviation: "EDT"))
  }
}
