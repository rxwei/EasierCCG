import PackageDescription

let package = Package(
    name: "EasierCCG",
    dependencies: [
        .Package(url: "https://github.com/rxwei/Parsey", majorVersion: 1, minor: 4)
    ]
)
