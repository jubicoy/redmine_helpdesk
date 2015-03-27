# Redmine Helpdesk - JubicOy Fork

[![Build Status](https://travis-ci.org/jubicoy/redmine_helpdesk.svg?branch=jubicoy%2Fmaster)](https://travis-ci.org/jubicoy/redmine_helpdesk) [![Code Climate](https://codeclimate.com/github/jubicoy/redmine_helpdesk/badges/gpa.svg)](https://codeclimate.com/github/jubicoy/redmine_helpdesk) [![Test Coverage](https://codeclimate.com/github/jubicoy/redmine_helpdesk/badges/coverage.svg)](https://codeclimate.com/github/jubicoy/redmine_helpdesk)

**See [jfqd/redmine_helpdesk](https://github.com/jfqd/redmine_helpdesk) for full description and instructions.**

Lightweight helpdesk plugin for redmine. Adds the email sender-address of an anonymous supportclient to the custom field 'owner-email' of a ticket which was created by a support email. Answers can be send to the supportclient by checking the support checkbox on a journal.

## Additional Features

* First reply can be disabled
* Configurable email subject (optional)
* MacroExpander for expanding ```##project-name```, etc. macros in subject, first reply and footer.
* Footer not sent with first reply
* owner-email can be overwritten by ```Owner-email: <email>``` in email. Unlike other ```IssueCustomFields``` this value respects the allow_override option in the mail command.

## Compatibility

This plugin is tested against Redmine 2.4.7, 2.5.3, 2.6.2 and 3.0.1. However, 3.0.x compatibility is not verified besides the included test suite.

* A version for Redmine 1.2.x. up to 1.4.7. is tagged with [v1.4](https://github.com/jfqd/redmine_helpdesk/tree/v1.4 "plugin version for Redmine 1.2.x up to 1.4.7") and available for [download on github](https://github.com/jfqd/redmine_helpdesk/archive/v1.4.zip "download plugin for Redmine 1.2.x up to 1.4.7").
* A version for Redmine 2.3.x is tagged with [v2.3](https://github.com/jfqd/redmine_helpdesk/tree/v2.3 "plugin version for Redmine 2.3.x") and available for [download on github](https://github.com/jfqd/redmine_helpdesk/archive/v2.3.zip "download plugin for Redmine 2.3.x").

## Contribution

* [ssidelnikov](https://github.com/ssidelnikov) - Make sure that the notes length is always calculated
* [nifuki](https://github.com/nifuki) - Fixed bug trying to send an email with empty notes
* [nifuki](https://github.com/nifuki) - Fixed non-working helpdesk-send-to-owner-default checkbox
* [box789](https://github.com/box789) - Russian translation
* [seqizz](https://github.com/seqizz) - Turkish translation
* [benstwa](https://github.com/benstwa) - 'send' should be 'sent'
* [davidef](https://github.com/davidef) - Add setting for handling sent to owner default value
* [Craig Gowing](https://github.com/craiggowing) - Redmine 2.4 compatibility
* [Barbazul](https://github.com/barbazul) - Added reply-to header
* [Orchitech Solutions](https://github.com/orchitech) - Added issue matching based on standard MIME header references
* [Orchitech Solutions](https://github.com/orchitech) - Added support for non-anonymous supportclients (sponsored by ISIC Global Office)

## License

This plugin is licensed under the MIT license. See LICENSE-file for details.

## Copyright

Copyright (c) 2012-2014 Stefan Husch, qutic development. The development has been fully sponsored by netz98.de
