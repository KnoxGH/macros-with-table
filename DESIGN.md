# TableMacro interface direction

TableMacro should feel like a quiet macOS instrument: spatial, precise, and calm. It should not look like a generic analytics dashboard or a science-fiction control panel.

## Reference lessons

- Apple places Liquid Glass in the functional layer—navigation and controls—and recommends standard materials for content. Use system components first and custom glass sparingly. See [Materials](https://developer.apple.com/design/human-interface-guidelines/materials) and [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos/).
- A calm interface avoids competing for attention it has not earned; structure should be felt rather than seen. TableMacro therefore uses fewer icons, separators, borders, and elevated containers.
- A stable sidebar, a single obvious working area, progressive disclosure, and purposeful motion keep advanced sensing and rejection controls out of the primary path.
- Task focus, contextual dimming, and attention to interaction details matter more than decoration.

## Anti-slop rules

1. No purple–cyan gradients, neon glow, decorative blobs, or forced dark mode.
2. No bento grid of interchangeable metric cards.
3. No boxes inside boxes. A container must communicate real grouping or interaction.
4. No uppercase eyebrow copy, excessive tracking, or oversized marketing headings inside the app.
5. One semantic accent color. Status colors are reserved for success, warning, recording, and error.
6. No decorative icon tiles. Symbols identify actions or objects only.
7. No invented metrics or ornamental charts. Every number must come from real capture or evaluation data.
8. Liquid Glass is for toolbar and important controls. Content uses standard system materials.
9. Prefer native `NavigationSplitView`, `List`, `Form`, `Table`, `LabeledContent`, `Gauge`, `ProgressView`, menus, sheets, and toolbars.
10. Motion explains a state change; nothing continuously pulses merely to look alive.

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
