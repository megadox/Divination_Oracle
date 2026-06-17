# Divination Result Image Plan

## Goal
- Keep the current tarot card image flow.
- Make non-tarot result images feel specific to the actual reading result, not just the divination type.

## This pass
- Reuse the existing representative base image for each divination type.
- Add payload-driven hero overlays in the result screen.
  - `saju`: highlight dominant element, zodiac animal, season, yin/yang.
  - `zodiac`: highlight resolved sign, element, modality.
  - `rune`: highlight the selected rune set, centered on the first rune.
  - `omikuji`: highlight fortune grade and focus area.

## Why this approach
- It improves result-specific visuals immediately without creating dozens of new bitmap assets.
- It keeps the asset structure simple and leaves room for later per-sign/per-rune/per-fortune dedicated art.
- It is Flutter-only, so no DB migration is needed for this step.
