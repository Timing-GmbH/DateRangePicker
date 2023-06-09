// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "DateRangePicker",
	defaultLocalization: "en",
	platforms: [
		.macOS(.v10_13),
	],
	products: [
		.library(
			name: "DateRangePicker",
			targets: ["DateRangePicker"]),
	],
	targets: [
		.target(
			name: "DateRangePicker"),
		.testTarget(
			name: "DateRangePickerTests",
			dependencies: ["DateRangePicker"]),
	]
)
