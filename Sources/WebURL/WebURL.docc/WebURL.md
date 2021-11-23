# ``WebURL``

A new URL type for Swift.

## Overview

WebURL is a new URL library, built to conform to the latest [industry standard](https://url.spec.whatwg.org/) for parsing and manipulating URLs. It has a very lenient parser which matches modern browsers, as well as JavaScript's native URL class and other modern libraries. WebURL values are automatically normalized according to the standard, meaning they remain highly interoperable with legacy systems and other libraries, and are much easier to work with.

The API incorporates modern best practices, so it helps you write more robust, correct code. This library takes full advantage of Swift language features such as generics and zero-cost wrapper views, to deliver an expressive, easy-to-use API which doesn't have to sacrifice performance. Gone are the days when a proper URL type was _so much slower_ than a hacky regex!

**Visit the ``WebURL/WebURL`` type to get started.**

## Topics

### Parsing and Manipulating URLs

- ``WebURL/WebURL``
- <doc:PercentEncoding>

### Network Hosts

- ``IPv4Address``
- ``IPv6Address``

### Deprecated APIs

- <doc:Deprecated>
