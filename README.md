# PDFKitViewer
PDFKit sample

PDFKitViewer illustrates the display of a PDF document. 

PDFKitViewer demonstrates some simple and some less than simple uses of PDFKit:
• Basic use of PDFView
• Using PDFDocument to search
• PDFOutline as data for NSOutlineView.

Display of a PDFDocument is handled by the PDFView class. The sample allows the user to select and open a PDF file, which is then displayed in a PDFView object.

PDFKitViewer includes several useful features:
• Single page or side-by-side page display display of a document outline
• A search tool in the drawer

Revision History

Tiger (no date) Version 1.0, 

2018-07-25 Version 2.0
Brought up-to-date in macOS 10.13.5 with Xcode 9.2
Base SDK 10.13
macOS Deployment Target 10.13
Repaired warnings and updated Deprecated APIs
Added Read Me with Revision History and Eratta

Eratta

"Overridden deprecated methods" warning needs to be turned on and warnings repaired.

Turn on other warnings and fix issues that crop up.
https://github.com/boredzo/Warnings-xcconfig/wiki/Warnings-Explained

NSDrawer has been deprecated in 10.13.
