//
//  DynamicCaptureFeedbackEnforcedDetectors.h
//  CFDocumentScanSDK
//
//  Created by John Hammerlund on 9/28/21.
//  Copyright © 2021 IDMetrics. All rights reserved.
//

#ifndef DynamicCaptureFeedbackEnforcedDetectors_h
#define DynamicCaptureFeedbackEnforcedDetectors_h

/// Configurable detectors that are enforced within a Dynamic Capture Feedback session
typedef NS_OPTIONS(NSUInteger, DynamicCaptureFeedbackEnforcedDetectors) {
    /// Enforces detection of the barcode in applicable documents
    DynamicCaptureFeedbackEnforcedDetectorsBarcode = 1 << 0,
    /// Enforces detection of the Machine-Readable Zone (MRZ) in applicable documents
    DynamicCaptureFeedbackEnforcedDetectorsMachineReadableZone = 1 << 1,
    /// Enforces detection of minimum document lighting. Processing may fail if the document is too dim.
    DynamicCaptureFeedbackEnforcedDetectorsDocumentLighting = 1 << 2,
    /// Enforces detection of maximum glare. Requires Document Lighting.
    DynamicCaptureFeedbackEnforcedDetectorsGlare = 1 << 3,
    /// Enforces document / background contrast detection. Requires Document Lighting.
    DynamicCaptureFeedbackEnforcedDetectorsContrast = 1 << 4,
    
    /// Enforces all light quality detection (Document Lighting, Glare, Contrast)
    DynamicCaptureFeedbackEnforcedDetectorsLightQuality = 0b00011100, // (1 << 4) & (1 << 3) & (1 << 2)
    /// Enforces all Dynamic Capture Feedback options applicable to the document type
    DynamicCaptureFeedbackEnforcedDetectorsAll = 0b11111111,
};

#endif /* DynamicCaptureFeedbackEnforcedDetectors_h */
