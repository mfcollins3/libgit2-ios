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
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libgit2.zip",
			checksum: "d5d98de86bcdd13b41f457d025abadf20d8b358b88d9e8543d4f117ad863d015"
		),
		.binaryTarget(
			name: "libssh2",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libssh2.zip",
			checksum: "43e0f5baf31bfecb5fd6bdd66b01d57e3582122a762eaab735311c6de4d09adb"
		),
		.binaryTarget(
			name: "libssl",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libssl.zip",
			checksum: "f0b23204497ba411da78ac4c1818badd9495e4e4c2ffef6babcbef05c697b0e1"
		),
		.binaryTarget(
			name: "libcrypto",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libcrypto.zip",
			checksum: "5cf22fa92138182dd34d15224d1f886aea949a7c89106261a309367abb2b6988"
		),
	]
)
