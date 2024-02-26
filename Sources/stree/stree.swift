import Foundation

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
public struct stree {
  let VERSION = "1.2.0"
  var nesting: String = "    "
  var hiddenPrefix: Character = "."

  private var showAll: Bool = false
  private var maximumLevel: Int?
  private var path: String?
  private var summary: Bool = false
  private var maximumLevelReached: Int?

  public enum Argument: String {
    case version = "--version"
    case help = "--help"
    case all = "-a"
    case limit = "-L"
    case summary = "-s"
  }

  public func printVersion() {
    print("stree@\(VERSION)")
  }

  public func printHelp() {
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

  public func printSummary() {
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

        let nextIndex = index + 1
        if nextIndex >= arguments.count {
          break
        }

        let maximumLevelString = arguments[nextIndex]
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

  public mutating func printPathStart(_ path: String) throws {
    self.maximumLevelReached = 0

    let boldPath = path.bold()
    print(boldPath)
    try self.printPath(path, 0)
  }

  public func canTraverse(_ nextLevel: Int) -> Bool {
    if let maximumLevel = self.maximumLevel {
      if nextLevel >= maximumLevel {
        return false
      }
    }
    return true
  }

  public func hidden(_ item: String) -> Bool {
    item[item.index(item.startIndex, offsetBy: 0)] == self.hiddenPrefix
  }

  public mutating func printPath(_ path: String, _ level: Int) throws {
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
    var application = stree(CommandLine.arguments)
    if let path = application.path {
      try application.printPathStart(path)
      application.printSummary()
    } else {
      application.printHelp()
    }
  }
}
