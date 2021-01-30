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
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.1.0/libgit2.zip",
			checksum: "3f11e16440aaaf58d6831a716ecd7bf29343344efb01a9bb1d800c2c9ea3d63a"
		),
		.binaryTarget(
			name: "libssh2",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.1.0/libssh2.zip",
			checksum: "1d45791a89f8229fe0db56cace11e4bd57a8df5f54a0f88f8f74159a3a3ac5f8"
		),
		.binaryTarget(
			name: "libssl",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.1.0/libssl.zip",
			checksum: "bead2f809a7b053b301a48b53a03e3d34bcec0ae130d968df4dc78ac66be326a"
		),
		.binaryTarget(
			name: "libcrypto",
			url: "https://github.com/mfcollins3/libgit2-ios/releases/download/v1.1.0/libcrypto.zip",
			checksum: "d267d966b1d18a943b8109cfcdc005c23557945bc490ff261423856f44157191"
		),
	]
)
