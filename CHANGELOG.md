#MMRecord Changelog

##[1.2.0](https://github.com/mutualmobile/MMRecord/issues?milestone=5&state=closed) (Monday, December 23th, 2013)
###New
* Added a new sub spec called AFMMRecordResponseSerializer that returns MMRecord objects in an AFNetworking 2.0 success block. (Conrad Stoll)
* Added a new sample project called MMRecordFoursquare that implements the Foursquare Venue API and the AFMMRecordResponseSerializer. (Conrad Stoll)
* Added a new way to conditionally delete orphans that did not come back in a response. (Conrad Stoll)
* Improved the experience for customizing the marshalling behavior to allow transformed property setting. (Rene Cacheaux and Conrad Stoll)

###Fixed
* **FIXED** an issue([#34](https://github.com/mutualmobile/MMRecord/issues/34)) where MMRecord's future with AFNetworking 2.0 was uncertain. (Conrad Stoll)
* **FIXED** an issue([#4](https://github.com/mutualmobile/MMRecord/issues/4)) where MMRecord had difficulty deleting orphans if you wanted to. (Conrad Stoll)

##[1.1.0](https://github.com/mutualmobile/MMRecord/issues?milestone=4&state=closed) (Monday, July 8th, 2013)
###New
* You can now specify a specific page manager for any request. (Conrad Stoll)

###Fixed
* **FIXED** an issue([#28](https://github.com/mutualmobile/MMRecord/pull/28)) where null relationship values were not being sanitized. (Rene Cacheaux)
* **FIXED** an issue([#24](https://github.com/mutualmobile/MMRecord/pull/24)) where request options were not thread safe in batch requests. (Conrad Stoll)
* **FIXED** an issue([#16](https://github.com/mutualmobile/MMRecord/issues/16)) with duplicate proto records in the import process. (Luke Rhodes)

##[1.0.3](https://github.com/mutualmobile/MMRecord/issues?milestone=3&state=closed) (Thursday, June 6th, 2013)

###Fixed
* **FIXED** an issue([#19](https://github.com/mutualmobile/MMRecord/pull/19)) where request options were not thread safe in batch requests. (Conrad Stoll)
* **FIXED** an issue where a logging function was not respecting the set logging level. (Conrad Stoll)

##[1.0.2](https://github.com/mutualmobile/MMRecord/issues?milestone=2&state=closed) (Wednesday, May 22nd, 2013)

###Fixed
* **FIXED** an issue([#12](https://github.com/mutualmobile/MMRecord/pull/12)) where a model misconfiguration could result in a crash. (John Thomas)
* **FIXED** an issue([#11](https://github.com/mutualmobile/MMRecord/pull/11)) where a retain cycle could cause a substantial leak in the parsing process. (Conrad Stoll)

##[1.0.1](https://github.com/mutualmobile/MMRecord/issues?milestone=1&state=closed) (Wednesday, May 8th, 2013)
###New
* Support for Unix Time Stamps. (Matt Weathers)
* Cocoa Lumberjack Support (Lars Anderson)

###Fixed
* **FIXED** an issue([#10](https://github.com/mutualmobile/MMRecord/pull/10)) where batch request failure blocks were not working as intended. (Swapnil Jadhav)
* **FIXED** an issue([#9](https://github.com/mutualmobile/MMRecord/pull/9)) where the primary key could not be a key path (John McIntosh)

##1.0.0 (Friday, April 5th, 2013)
 * Initial Library Release