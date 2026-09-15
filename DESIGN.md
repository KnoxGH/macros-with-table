# TableMacro interface direction

TableMacro should feel like a bold, colorful instrument, not a generic gray analytics dashboard. It still leans on native macOS structure — sidebar, forms, standard controls — but its color system is deliberately loud: a saturated signature accent plus one vivid, distinct color per desk zone, so a result reads at a glance instead of through a single monochrome highlight.

## Reference lessons

- Apple places Liquid Glass in the functional layer—navigation and controls—and recommends standard materials for content. Use system components first and custom glass sparingly. See [Materials](https://developer.apple.com/design/human-interface-guidelines/materials) and [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos/).
- A stable sidebar, a single obvious working area, progressive disclosure, and purposeful motion keep advanced sensing and rejection controls out of the primary path — bold color doesn't require abandoning that structure.
- Color should carry real meaning: each desk zone's color appears everywhere that zone is referenced (the desk map, results, the confusion matrix, the actions list), so the palette does information work, not just decoration.

## Design rules

1. One signature accent (a saturated violet) plus the four-color zone palette defined in `TableMacroTheme`. No arbitrary additional colors — every color used has a meaning (a zone, or the shared accent).
2. Panels use a soft tinted gradient card (`tablemacroCard`) instead of plain system materials, so state (which zone, pass/fail) is visible in the background color itself.
3. No boxes inside boxes beyond that one card level. A container must communicate real grouping or interaction.
4. No uppercase eyebrow copy, excessive tracking, or invented metrics. Every number must come from real capture or evaluation data.
5. Titles use a heavy, rounded display face (`Font.tablemacroTitle`); body text stays system default for readability.
6. Liquid Glass is for toolbar and important controls. Content uses `tablemacroCard`/`tablemacroPrimaryButton`/`tablemacroSecondaryButton` rather than ad-hoc styling.
7. Prefer native `NavigationSplitView`, `List`, `Form`, `Table`, `LabeledContent`, `Gauge`, `ProgressView`, menus, sheets, and toolbars — the color system sits on top of standard structure, not a custom one.
8. Motion explains a state change (a zone lighting up, a pulsing waveform while listening); nothing pulses merely to look alive.

## Signal-processing lessons

- A surface tap is a short power pulse whose neighboring windows are substantially quieter. TableMacro applies this temporal principle after capture, with deliberately looser thresholds because it has only the MacBook microphone rather than contact accelerometers.
- Effective duration above roughly 40% of the envelope maximum is a well-known way to distinguish a percussive event from a sustained one. TableMacro combines that cue with late-to-impact energy and early-energy concentration; no single cue rejects an event by itself.
- Combining temporal and spectral features with a learned classifier suits on-device mechano-acoustic touch classification. TableMacro uses ten spatially varied captures per broad zone and a regularized linear boundary, while retaining nearest-example novelty and user-recorded negative checks.

## Screen hierarchy

- **Desk:** two continuous two-zone rails around one MacBook silhouette, one compact result strip, and no-profile onboarding in place. Individual zones are not rendered as four floating cards.
- **Calibration:** one target at a time. Beginning setup is the explicit capture intent; TableMacro then collects ten clean taps spread across the highlighted area, disarms during each move, and automatically arms the next zone after a short transition. A visible Arm control remains available after a pause. A measured consistency check can redo the weakest zone before saving, and Talking rejection capture is surfaced as the recommended final step.
- **Actions:** a four-row editor grouped by the left and right side of the MacBook. Native pickers progressively reveal only the fields needed for the selected action, including Shortcuts, app/file bookmarks, shell commands, and screenshots.
- **Diagnostics:** factual hardware and signal details in a form, with sensing comparisons disclosed on demand.
- **Accuracy Test:** a focused 60-tap run followed by a plain results table and four-by-four confusion matrix.

The sidebar keeps Desk, Calibration, Actions, and Accuracy Test in workflow order. Hardware and sensing diagnostics live in a separate Advanced section.
