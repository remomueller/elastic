## 0.6.1 (April 11, 2013)

### Bug Fix
- Since Windows version doesn't run through Apache or Nginx, serve static assets directly through Rails

## 0.6.0 (April 11, 2013)

### Breaking Change
- Deprecated support for XML messaging in favor of JSON web API

### Enhancements
- **Gem Changes**
  - Updated to Rails 4.0.0.beta1
  - Updated to Contour 2.0.0.beta.4

## 0.5.9 (March 20, 2013)

### Enhancements
- Use of Ruby 2.0.0-p0 is now recommended

## 0.5.8 (February 15, 2013)

### Security Fix
- Updated Rails to 3.2.12

### Enhancements
- ActionMailer can now also be configured to send email through NTLM
  - `ActionMailer::Base.smtp_settings` now requires an `:email` field

## 0.5.7 (January 9, 2013)

### Enhancements
- Updated CarrierWave to 0.8.0
- Updated to Contour 1.1.2 and use Contour pagination theme
- Added CodeClimate badge to README

## 0.5.6 (January 8, 2013)

### Security Fix
- Updated Rails to 3.2.11

### Enhancements
- Updated to Thin 1.5.0

## 0.5.5 (January 3, 2013)

### Security Fix
- Updated Rails to 3.2.10

### Enhancements
- Updated to Ruby 1.9.3-p327
- Updated to Contour 1.1.1

### Bug Fix
- User activation emails are no longer sent out when a user's status is changed from pending to inactive

## 0.5.4 (August 13, 2012)

### Enhancements
- Updated to Rails 3.2.8
  - Removed deprecated use of update_attribute for Rails 4.0 compatibility
- **Email Changes**
  - Default application name is now added to the from: field for emails
  - Email subjects no longer include the application name
- About page reformatted to include links to github and contact information

### Refactoring
- Mass-assignment attr_accessible and params slicing implemented to leverage Rails 3.2.x configuration defaults
- Consistent sorting and display of model counts used across all objects, (downloaders, segments, users)

### Testing
- Use ActionDispatch for Integration tests instead of ActionController

## 0.5.3 (June 27, 2012)

### Enhancements
- Update to Rails 3.2.6 and Contour 1.0.2
- Update to Ruby 1.9.3-p194

## 0.5.2 (March 22, 2012)

### Enhancements
- Update to Rails 3.2.2 and Contour 0.10.2 with Contour-Minimalist theme
- External User ID now shown on downloaders index

## 0.5.1 (January 23, 2012)

### Refactoring
- Gem dependencies updated
  - Rails 3.2.0
  - Contour ~> 0.9.3
- Devise migration and configuration file updated
- Environment files updated to be in sync with Rails 3.2.0

## 0.5.0 (January 19, 2012)

### Enhancements
- Update to Rails 3.2.0.rc2 and Contour 0.9.0
- **Downloader Changes**
  - Downloaders are now associated with an external user
  - Downloaders are now identifiable by a digest of the file names
  - Tracking now exists per user per file by
    - Count of checksum requests
    - Count of file download requests
- **Segments Changes**
  - Segments have a many to many associate with downloaders
  - A segment's file checksum is not computed until it is specifically requested through a download checksum request
- JSON messaging has been implemented for downloaders, XML messaging will be deprecated in a future release

### Testing
- SimpleCov added for test coverage
- TravisCI configuration files added

### Bug Fix
- Logging in as a valid user no longer creates a redirect loop

## 0.4.0 (October 19, 2011)

### Enhancements
- Pagination added to downloaders and segments index pages

### Documentation
- Default database for windows is now set to pg instead of sqlite3
- The default downloader type is now a Ruby program wrapped inside of an executable that uses Ruby Net class to incrementally download files
- Peer-to-peer file downloader generation has been removed

### Bug Fix
- Assets compression turned off since Windows currently fails on rake assets:precompile

## 0.3.0 (October 19, 2011)

### Enhancements
- Update to Rails 3.1.1
- Update authentication interface to use Contour 0.5.6

### Documentation
- Added information on how to setup Elastic as a robust/reliable Windows 7 Service using Thin Server and Microsoft Resource Kit Tools

### Testing
- Test suite updated to contain base set of passing test cases

## 0.2.0 (October 14, 2011)

### Enhancements
- Switch to file serving via ruby script
- Allow multiple locations for stored files, downloaders now require a folder location

## 0.1.0 (July 19, 2011)

- Initial implementation of torrents controller

## 0.0.0 (May 27, 2011)

- Initial version with user, authentications, menu, stylesheets, images, and javascript.
