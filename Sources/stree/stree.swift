import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

@main
public struct stree {
    var nesting: String = "    "
    var hiddenPrefix: Character = "."

    private var showAll: Bool = false
    private var maximumLevel: Int?
    private var path: String?

    public func printHelp() {
        print("""
            stree -- directory tree viewing program.
            Usage:
                stree [--help|-a|-L] path
            Arguments:
                --help print help
                -a include hidden files
                -L limit maximum level of directory tree depth
            Examples:
                stree .
                stree -a .
                stree -L 1 .
            """
        )
    }

    public init(_ arguments: Array<String>) {
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

            switch argument {
                case "--help":
                    self.printHelp()
                    exit(0)
                case "-a":
                    self.showAll = true
                case "-L":
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
                default:
                    if pathFound {
                        break
                    }
                    pathFound = true

                    self.path = argument
            }
        }
    }

    public func printPathStart(_ path: String) throws {
        let boldPath = self.bold(path)
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

    public func bold(_ item: String) -> String{
        "\u{001B}[1;30m\(item)\u{001B}[0;30m"
    }

    public func printPath(_ path: String, _ level: Int) throws {
        if !self.canTraverse(level) {
            return
        }

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
                let boldItem = self.bold(item)
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
        let application = stree(CommandLine.arguments)
        if let path = application.path { 
            try application.printPathStart(path)
        } else {
            application.printHelp()
        }
    }
}
