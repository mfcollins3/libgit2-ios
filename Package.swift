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
			checksum: "e803a4a9d9a99940a6447d3182bedccbfb4765c334768c21c487febaaabe2d8d"
		),
		.binaryTarget(
			name: "libssh2",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libssh2.zip",
			checksum: "6db15f16999b9cdb16a29a1b3c4b7b55a4ea787188c91eb1f0d95a0ac988cbb6"
		),
		.binaryTarget(
			name: "libssl",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libssl.zip",
			checksum: "c36bf18b53ccd4dc59e7f8941ae3a244261966cb04520551d800a02271142980"
		),
		.binaryTarget(
			name: "libcrypto",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.4.3/libcrypto.zip",
			checksum: "7de762979d28e6159b942216d27263a6f4dbb69e481ec25020d843368ed61da2"
		),
	]
)
