import Foundation

extension Array {
  subscript(safe index: Index) -> Element? {
    0 <= index && index < count ? self[index] : nil
  }
}

extension String {
  public func bold() -> String {
    "\u{001B}[1;30m\(self)\u{001B}[0;30m"
  }
}

extension URL {
  var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}

@main
public struct Stree {
  private let VERSION: String = "1.2.0"

  public var nesting: String = "    "

  private var showAll: Bool = false
  private var maximumLevel: Int?
  private var summary: Bool = false
  private var path: String?

  private var hiddenPrefix: Character = "."
  private var maximumLevelReached: Int?

  private enum Argument: String {
    case version = "--version"
    case help = "--help"
    case all = "-a"
    case limit = "-L"
    case summary = "-s"
  }

  private func printVersion() {
    print("stree@\(VERSION)")
  }

  private func printHelp() {
    print(
      """
      stree -- directory tree viewing program.
      Usage:
          stree [--version|--help|-a|-L|-s] path
      Arguments:
          --version print version,
          --help print help,
          -a include hidden files,
          -L limit maximum level of directory tree depth.
          -s print summary
      Examples:
          stree .
          stree -a .
          stree -L 1 .
          stree -s .
      """
    )
  }

  private func printSummary() {
    if !self.summary {
      return
    }
    if let maximumLevelReached = self.maximumLevelReached {
      print("Maximum level reached: \(maximumLevelReached).")
    } else {
      print("Was not traversing.")
    }
  }

  public init(_ arguments: [String]) {
    var skipNext: Bool = false
    var pathFound: Bool = false

    for (index, argument) in arguments.enumerated() {
      if index == 0 {
        continue
      }
      if skipNext {
        skipNext = false
        continue
      }

      let enumerated_argument = Argument(rawValue: argument)
      switch enumerated_argument {
      case .version:
        self.printVersion()
        exit(0)
      case .help:
        self.printHelp()
        exit(0)
      case .all:
        self.showAll = true
      case .limit:
        if !skipNext {
          skipNext = true
        } else {
          break
        }

        guard let maximumLevelString = arguments[safe: index + 1] else {
          break
        }
        let maximumLevel = Int(maximumLevelString)!
        if maximumLevel < 0 {
          break
        }

        self.maximumLevel = maximumLevel
      case .summary:
        self.summary = true
      default:
        if pathFound {
          break
        }
        pathFound = true

        self.path = argument
      }
    }
  }

  private mutating func printPathStart(_ path: String) throws {
    self.maximumLevelReached = 0

    let boldPath = path.bold()
    print(boldPath)
    try self.printPath(path, 0)
  }

  private func canTraverse(_ nextLevel: Int) -> Bool {
    if let maximumLevel = self.maximumLevel {
      if nextLevel >= maximumLevel {
        return false
      }
    }
    return true
  }

  private func hidden(_ item: String) -> Bool {
    item[item.index(item.startIndex, offsetBy: 0)] == self.hiddenPrefix
  }

  private mutating func printPath(_ path: String, _ level: Int) throws {
    if !self.canTraverse(level) {
      return
    }

    self.maximumLevelReached = level

    let nextLevel = level + 1
    let items = try FileManager.default.contentsOfDirectory(atPath: path)

    for item in items {
      if !self.showAll && self.hidden(item) {
        continue
      }

      let itemPath = NSString.path(withComponents: [path, item])
      let url = URL(fileURLWithPath: itemPath)
      let itemPrefix = String(repeating: self.nesting, count: nextLevel)

      if url.isDirectory {
        let boldItem = item.bold()
        print("\(itemPrefix) \(boldItem)")

        if !self.canTraverse(nextLevel) {
          continue
        }
        try self.printPath("\(itemPath)", nextLevel)
      } else {
        print("\(itemPrefix) \(item)")
      }
    }
  }

  public static func main() throws {
    var application = Stree(CommandLine.arguments)
    if let path = application.path {
      try application.printPathStart(path)
      application.printSummary()
    } else {
      application.printHelp()
    }
  }
}
