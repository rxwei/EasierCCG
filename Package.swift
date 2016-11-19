import PackageDescription

let package = Package(
    name: "EasierCCG",
    targets: [
        Target(name: "CCG"),
        Target(name: "SymbolicParser", dependencies: [ "CCG" ])
    ],
    dependencies: [
        .Package(url: "https://github.com/rxwei/Parsey", majorVersion: 1, minor: 4)
    ]
)
