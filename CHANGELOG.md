#MMRecord Changelog

##[1.4.1](https://github.com/mutualmobile/MMRecord/issues?milestone=9&state=closed) (Friday, July 4th, 2014)
**Fixed**
* **FIXED** an issue([#83](https://github.com/mutualmobile/MMRecord/issues/83)) where MMRecord treated empty result sets as request failures. (Andrea Cremaschi)

##[1.4.0](https://github.com/mutualmobile/MMRecord/issues?milestone=7&state=closed) (Friday, June 27th, 2014)
**New**
* Improved support for sub-entity inheritance. [#50](https://github.com/mutualmobile/MMRecord/issues/50) (Andrea Cremaschi)
* Improved support for sub-entity inheritance in relationships. [#52](https://github.com/mutualmobile/MMRecord/pull/52) (Ian Dundas)
* Added logging and tracking of Core Data errors. [#53](https://github.com/mutualmobile/MMRecord/issues/53) (Viktor Krykun)
* Improved error handling for invalid response formats. [#54](https://github.com/mutualmobile/MMRecord/pull/54) (Jeremy Hilts)
* Added support for MMRecordOptions and the entityPrimaryKeyInjectionBlock in AFMMRecordResponseSerializer. [#56](https://github.com/mutualmobile/MMRecord/issues/56) (Ian Dundas, Jon Brooks, Conrad Stoll)
* Added a new subclassing option for customizing the primary key for a representation. [#58](https://github.com/mutualmobile/MMRecord/pull/58) (Conrad Stoll)
* Added a new MMRecordDebugger class for improving the MMRecord debugging experience. [#59](https://github.com/mutualmobile/MMRecord/pull/59) (Conrad Stoll)
* Added support for merging duplicate dictionaries that represent a single record. [#60](https://github.com/mutualmobile/MMRecord/pull/60) (Andrea Cremaschi and Conrad Stoll)
* Added support for Swift, and a new MMRecordAtlassian example project written in Swift. [#74](https://github.com/mutualmobile/MMRecord/pull/74) (Conrad Stoll)
* Added logging to handle an issue where setting an existing relationship may invalidate an existing inverse relationship. [#75](https://github.com/mutualmobile/MMRecord/issues/75) (Alex Malek)
* Added support for Facebook Tweaks. [#77](https://github.com/mutualmobile/MMRecord/pull/77) (Conrad Stoll)

**Fixed**
* **FIXED** an issue([#45](https://github.com/mutualmobile/MMRecord/issues/45)) where the AFMMRecordResponseSerializer did not pass through AFNetworking 2.0 errors. (Brian Watson)
* **FIXED** an issue([#46](https://github.com/mutualmobile/MMRecord/issues/46)) where the AFMMRecordResponseSerializer did not handle root level response objects. (Andrea Cremaschi)
* **FIXED** an issue([#55](https://github.com/mutualmobile/MMRecord/pull/55)) where the MMRecordMarshaler did not iterate through all potential key paths. (Nick Bolton)


##[1.3.0](https://github.com/mutualmobile/MMRecord/issues?milestone=6&state=closed) (Tuesday, March 4th, 2014)
**New**
* Added a new way to inject a primary key into the population system. [#41](https://github.com/mutualmobile/MMRecord/pull/41) (Conrad Stoll)
* Added a new option for performing pre-population steps in the population system. [#41](https://github.com/mutualmobile/MMRecord/pull/41) (Conrad Stoll)
* Added new safeguards against creating duplicate records when using relationship primary keys. [#41](https://github.com/mutualmobile/MMRecord/pull/41) (Conrad Stoll)
* Added a new subspec called SessionManagerServer that provides an example server for using AFNetworking 2.0. [#43](https://github.com/mutualmobile/MMRecord/pull/43) (Conrad Stoll)
* Added the SessionManagerServer to the MMRecordFoursquare example. [#43](https://github.com/mutualmobile/MMRecord/pull/43) (Conrad Stoll)

**Fixed**
* **FIXED** an issue([#39](https://github.com/mutualmobile/MMRecord/issues/39)) where the AFMMRecordResponseSerializationMapper was not generic. (Rodrigo Aguilar)
* **FIXED** an issue([#40](https://github.com/mutualmobile/MMRecord/issues/40)) where there was a retain cycle in the parsing system. (Jim Stewart)

##[1.2.0](https://github.com/mutualmobile/MMRecord/issues?milestone=5&state=closed) (Monday, December 23th, 2013)
**New**
* Added a new subspec called AFMMRecordResponseSerializer that returns MMRecord objects in an AFNetworking 2.0 success block. (Conrad Stoll)
* Added a new sample project called MMRecordFoursquare that implements the Foursquare Venue API and the AFMMRecordResponseSerializer. (Conrad Stoll)
* Added a new way to conditionally delete orphans that did not come back in a response. (Conrad Stoll)
* Improved the experience for customizing the marshalling behavior to allow transformed property setting. (Rene Cacheaux and Conrad Stoll)

**Fixed**
* **FIXED** an issue([#34](https://github.com/mutualmobile/MMRecord/issues/34)) where MMRecord's future with AFNetworking 2.0 was uncertain. (Conrad Stoll)
* **FIXED** an issue([#4](https://github.com/mutualmobile/MMRecord/issues/4)) where MMRecord had difficulty deleting orphans if you wanted to. (Conrad Stoll)

##[1.1.1](https://github.com/mutualmobile/MMRecord/issues?milestone=8&state=closed) (Monday, July 8th, 2013)

**Fixed**
* **FIXED** an issue([#32](https://github.com/mutualmobile/MMRecord/pull/32)) causing a crash with nil keys. (Conrad Stoll)

##[1.1.0](https://github.com/mutualmobile/MMRecord/issues?milestone=4&state=closed) (Monday, July 8th, 2013)
**New**
* You can now specify a specific page manager for any request. (Conrad Stoll)

**Fixed**
* **FIXED** an issue([#28](https://github.com/mutualmobile/MMRecord/pull/28)) where null relationship values were not being sanitized. (Rene Cacheaux)
* **FIXED** an issue([#24](https://github.com/mutualmobile/MMRecord/pull/24)) where request options were not thread safe in batch requests. (Conrad Stoll)
* **FIXED** an issue([#16](https://github.com/mutualmobile/MMRecord/issues/16)) with duplicate proto records in the import process. (Luke Rhodes)

##[1.0.3](https://github.com/mutualmobile/MMRecord/issues?milestone=3&state=closed) (Thursday, June 6th, 2013)

**Fixed**
* **FIXED** an issue([#19](https://github.com/mutualmobile/MMRecord/pull/19)) where request options were not thread safe in batch requests. (Conrad Stoll)
* **FIXED** an issue where a logging function was not respecting the set logging level. (Conrad Stoll)

##[1.0.2](https://github.com/mutualmobile/MMRecord/issues?milestone=2&state=closed) (Wednesday, May 22nd, 2013)

**Fixed**
* **FIXED** an issue([#12](https://github.com/mutualmobile/MMRecord/pull/12)) where a model misconfiguration could result in a crash. (John Thomas)
* **FIXED** an issue([#11](https://github.com/mutualmobile/MMRecord/pull/11)) where a retain cycle could cause a substantial leak in the parsing process. (Conrad Stoll)

##[1.0.1](https://github.com/mutualmobile/MMRecord/issues?milestone=1&state=closed) (Wednesday, May 8th, 2013)
**New**
* Support for Unix Time Stamps. (Matt Weathers)
* Cocoa Lumberjack Support (Lars Anderson)

**Fixed**
* **FIXED** an issue([#10](https://github.com/mutualmobile/MMRecord/pull/10)) where batch request failure blocks were not working as intended. (Swapnil Jadhav)
* **FIXED** an issue([#9](https://github.com/mutualmobile/MMRecord/pull/9)) where the primary key could not be a key path (John McIntosh)

##1.0.0 (Friday, April 5th, 2013)
 * Initial Library Release