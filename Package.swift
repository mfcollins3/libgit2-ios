// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "libgit2",
	platforms: [.iOS(.v13)],
	products: [
		.library(
			name: "libgit2",
			targets: [
				"libgit2",
				"libssh2",
				"libssl",
				"libcrypto"
			]
		),
	],
	dependencies: [],
	targets: [
		.binaryTarget(
			name: "libgit2",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/1.5.0/libgit2.zip",
			checksum: "cb06393e43fe89496fa154e661ecf5218c5fd483f6b719720b8b9c6a88f263a6"
		),
		.binaryTarget(
			name: "libssh2",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/1.5.0/libssh2.zip",
			checksum: "c75b8a5202fd9f7cbe173a25507e853750f286a634f665692912f370581e4c00"
		),
		.binaryTarget(
			name: "libssl",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/1.5.0/libssl.zip",
			checksum: "130e5841e91f8bce647a1df75bef84a1014a54a885205ccf4a7ffc3ad42bc2d5"
		),
		.binaryTarget(
			name: "libcrypto",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/1.5.0/libcrypto.zip",
			checksum: "325a78943fb9bf3d8e9b02eb1aa00254ca575fb426be0c47c90324fcf4f37359"
		),
	]
)
