#! /usr/bin/swift

// Generates a Swift source file with the contents of a fuzzing corpus.
// The source file can be used by tests, or executed as a script to recreate the corpus.

import Foundation

// 1. Parse command-line args.
// Example usage: ./corpus-to-test.swift Corpora/foundation-to-web foundation_to_web 16 ../Tests/WebURLFoundationExtrasTests/FuzzCorpus_foundation_to_web.swift

var cmdargs_it = CommandLine.arguments.makeIterator()
guard let _ = cmdargs_it.next() else {
  fatalError("First entry should be the script's name")
}
guard let _corpusDir = cmdargs_it.next() else {
  fatalError("❌ First argument should be the corpus directory")
}
let corpusDir = URL(fileURLWithPath: _corpusDir)
guard let corpusName = cmdargs_it.next() else {
  fatalError("❌ Second argument should be the corpus name. Must be a valid Swift identifier.")
}
guard let _maxLength = cmdargs_it.next(), let maxLength = Int(_maxLength), maxLength > 0 else {
  fatalError("❌ Third argument should be the maximum length of each entry in the corpus")
}
guard let outputFile = cmdargs_it.next() else {
  fatalError("❌ Fourth argument should be the output file name")
}
guard cmdargs_it.next() == nil else {
  fatalError("❌ Too many arguments")
}

// 2. Gather the files in the corpus directory and produce a sorted list.

var corpusEntries = [URL]()
do {
  let enumerator = FileManager().enumerator(at: corpusDir, includingPropertiesForKeys: nil)!
  while let next = enumerator.nextObject() as? URL {
    corpusEntries.append(next)
  }
  corpusEntries.sort(by: {
    // Restored corpus entries have numeric names, whilst new/reduced entries have UUID names.
    // Sort by count first, so restored entries remain at the top of the list.
    let lhs = $0.lastPathComponent
    let rhs = $1.lastPathComponent
    guard lhs.utf8.count == rhs.utf8.count else {
      return lhs.utf8.count < rhs.utf8.count
    }
    return lhs < rhs
  })
}

// 3. Generate the output file.

var output =
  """
  // Copyright The swift-url Contributors.
  //
  // Licensed under the Apache License, Version 2.0 (the "License");
  // you may not use this file except in compliance with the License.
  // You may obtain a copy of the License at
  //
  //     http://www.apache.org/licenses/LICENSE-2.0
  //
  // Unless required by applicable law or agreed to in writing, software
  // distributed under the License is distributed on an "AS IS" BASIS,
  // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  // See the License for the specific language governing permissions and
  // limitations under the License.


  // --------------------------------------------------------------
  // DO NOT EDIT - THIS FILE WAS GENERATED BY CORPUS-TO-TEST.SWIFT
  // --------------------------------------------------------------
  // Generated at: \(Date())
  // Entries: \(corpusEntries.count)
  // Max length: \(maxLength)


  // swift-format-ignore
  internal let corpus_\(corpusName): [[UInt8]] = [\n
  """

for testDataURL in corpusEntries {
  let testData = try Data(contentsOf: testDataURL)
  // Generate an array literal containing the bytes.
  var arrayLiteralString = testData.reduce(into: "[") { str, byte in
    str += "0x" + (byte < 0x10 ? "0" : "") + String(byte, radix: 16, uppercase: true) + ", "
  }
  arrayLiteralString.removeLast(2)
  arrayLiteralString.append("]")
  // Include the string representation as a comment, but strip it of null bytes and newlines.
  var stringRepresentation = String(decoding: testData, as: UTF8.self)
  stringRepresentation.removeAll(where: { $0.asciiValue == 0 || $0.isNewline })
  output += "  \(arrayLiteralString),  // \"\(stringRepresentation)\"\n"
}

output +=
  #"""
  ]

  import Foundation

  // swift-format-ignore
  private func recreateCorpus_\#(corpusName)(_ outputDir: URL) throws {
    try? FileManager().removeItem(at: outputDir)
    try FileManager().createDirectory(at: outputDir, withIntermediateDirectories: true, attributes: nil)
    var entryNumber = 0
    for entry in corpus_\#(corpusName) {
      let destinationURL = outputDir.appendingPathComponent("\(entryNumber)", isDirectory: false)
      try Data(entry).write(to: destinationURL)
      entryNumber += 1
    }
  }

  // To recreate the corpus, uncomment this line and run the file using the interpreter (e.g. 'swift {this-file}')
  // try! recreateCorpus_\#(corpusName)(URL(fileURLWithPath: "recreated_corpus_\#(corpusName)"))

  """#

let outputFileURL = URL(fileURLWithPath: outputFile)
try! output.write(to: outputFileURL, atomically: false, encoding: .utf8)
