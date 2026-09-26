---
name: remotion-app-showcase
description: Create cinematic product showcase videos for iOS apps using Remotion. Use when building app demos, App Store previews, feature highlights, or marketing videos with real app recordings.
---

# Remotion App Showcase Skill

Use this skill to create professional, cinematic product showcase videos for iOS apps using Remotion and real simulator recordings.

## When to activate this skill

- User wants to create an app demo or showcase video
- User wants an App Store preview video
- User wants to highlight app features in a marketing video
- User has app screen recordings and wants to present them professionally
- User asks about Remotion, video creation, or app presentations
- User wants to use `mise run video:*` tasks

## Philosophy

**Show pieces, not full screens.** Focus on the specific UI element that proves the feature works — a button tap, a card swipe, a stat updating. Crop/mask to isolate the focal component rather than showing the entire screen.

**Spring physics > linear easing.** Use `spring()` for all animations — it feels more cinematic and natural.

**One comprehensive event per operation.** Structure the video with a clear narrative arc: Hook → Problem/Solution → Feature Demo → CTA.

## Prerequisites

1. **Video project** at `videos/` using Bun (not npm)
2. **Real app recordings** in `public/` directory (use simulator + `mobilecli screencapture`)
3. **Brand assets**: logo, colors, app icon in `public/`

**Dependencies are managed via mise + Bun:**
```bash
mise run video:install   # Installs Bun deps in videos/ directory
```

### Project structure

```
videos/
├── package.json          # Bun deps (remotion, react, etc.)
├── bun.lock             # Bun lockfile
├── remotion.config.ts   # Remotion CLI config
├── tsconfig.json        # TypeScript config
├── src/
│   ├── index.tsx        # Remotion root + compositions
│   ├── showcase/        # Showcase components
│   │   ├── constants.ts       # Colors, fonts, timing
│   │   ├── PhoneFrame.tsx     # iPhone device frame
│   │   ├── AnimatedCursor.tsx # Tap cursor with ripple
│   │   ├── TextOverlay.tsx    # Spring-animated headlines
│   │   ├── IntroScene.tsx     # Logo reveal + tagline
│   │   ├── AppShowcaseScene.tsx # Feature with phone + video
│   │   ├── OutroScene.tsx     # CTA + download button
│   │   └── ShowcaseVideo.tsx  # Main composition
│   └── ExerciseDemo.tsx # Legacy exercise demos
├── public/              # Video assets + images
│   ├── app-demo.mp4
│   ├── incline-dumbbell-press.mp4
│   └── deadlift.mp4
└── out/                 # Rendered videos (gitignored)
```

## Workflow

### 1. Record app footage

Use `mobilecli` to capture real app interactions:

```bash
# Boot simulator
mise run ios:sim:boot26

# Build and install app
mise run ios:build:dev

# Record screen
mobilecli screencapture --device <id> --format mjpeg | \
  ffmpeg -f mjpeg -i - -c:v libx264 -pix_fmt yuv420p -an recording.mp4
```

Re-encode for Chrome compatibility:
```bash
ffmpeg -i recording.mp4 -c:v libx264 -pix_fmt yuv420p -profile:v main \
  -level 4.0 -movflags +faststart -an public/recording.mp4
```

### 2. Set up project structure

```
videos/
├── src/
│   ├── showcase/
│   │   ├── constants.ts        # Colors, fonts, timing
│   │   ├── PhoneFrame.tsx      # iPhone device frame
│   │   ├── AnimatedCursor.tsx  # Tap cursor with ripple
│   │   ├── TextOverlay.tsx     # Spring-animated headlines
│   │   ├── IntroScene.tsx      # Logo reveal + tagline
│   │   ├── AppShowcaseScene.tsx # Feature with phone + video
│   │   ├── OutroScene.tsx      # CTA + download button
│   │   └── ShowcaseVideo.tsx   # Main composition
│   └── index.tsx               # Remotion root
└── public/
    ├── app-demo.mp4
    ├── feature-1.mp4
    └── logo.png
```

### 3. Core components

#### PhoneFrame

```tsx
import React from 'react';

export const PhoneFrame: React.FC<{children: React.ReactNode}> = ({children}) => {
  return (
    <div style={{
      width: 360,
      height: 720,
      borderRadius: 48,
      background: '#1A1A1A',
      padding: 12,
      boxShadow: '0 25px 80px rgba(255,214,10,0.15), 0 10px 30px rgba(0,0,0,0.5)',
    }}>
      <div style={{
        width: '100%',
        height: '100%',
        borderRadius: 36,
        overflow: 'hidden',
        position: 'relative',
      }}>
        {/* Dynamic Island */}
        <div style={{
          position: 'absolute',
          top: 12,
          left: '50%',
          transform: 'translateX(-50%)',
          width: 100,
          height: 28,
          background: '#000',
          borderRadius: 14,
          zIndex: 10,
        }} />
        {children}
      </div>
    </div>
  );
};
```

#### AnimatedCursor

```tsx
import {interpolate, useCurrentFrame} from 'remotion';

export const AnimatedCursor: React.FC<{
  startX: number; startY: number;
  endX: number; endY: number;
  startFrame: number; duration: number;
  clickFrame?: number;
}> = ({startX, startY, endX, endY, startFrame, duration, clickFrame}) => {
  const frame = useCurrentFrame();
  
  const progress = interpolate(frame, [startFrame, startFrame + duration], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  
  const x = interpolate(progress, [0, 1], [startX, endX]);
  const y = interpolate(progress, [0, 1], [startY, endY]);
  
  return (
    <div style={{position: 'absolute', left: x, top: y, zIndex: 100}}>
      <svg width="32" height="32" viewBox="0 0 24 24" fill="white">
        <path d="M5.5 3.21V20.8c0 .45.54.67.85.35l4.86-4.86a.5.5 0 0 1 .35-.15h6.87a.5.5 0 0 0 .35-.85L6.35 2.85a.5.5 0 0 0-.85.36z"/>
      </svg>
    </div>
  );
};
```

### 4. Scene structure

Follow this narrative arc:

```
Intro (3s) → Feature 1 (4s) → Feature 2 (4s) → Feature 3 (4s) → Outro (3s)
```

Use `TransitionSeries` for smooth transitions:

```tsx
import {TransitionSeries} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';
import {slide} from '@remotion/transitions/slide';

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={90}>
    <IntroScene />
  </TransitionSeries.Sequence>
  
  <TransitionSeries.Transition
    presentation={fade({})}
    timing={{durationInFrames: 30, easing: (t) => t * t * (3 - 2 * t)}}
  />
  
  <TransitionSeries.Sequence durationInFrames={120}>
    <AppShowcaseScene videoSrc="feature.mp4" featureTitle="Feature" ... />
  </TransitionSeries.Sequence>
  
  <TransitionSeries.Transition
    presentation={slide({direction: 'from-right'})}
    timing={{durationInFrames: 30, easing: (t) => t * t * (3 - 2 * t)}}
  />
  
  {/* ... more scenes ... */}
</TransitionSeries>
```

### 5. Animation best practices

**Spring physics for all motion:**
```tsx
const scale = spring({frame, fps, config: {damping: 16, stiffness: 80}});
const opacity = interpolate(frame, [0, 20], [0, 1]);
```

**Text entrances:**
```tsx
const translateY = interpolate(frame, [0, 20], [40, 0]);
const opacity = interpolate(frame, [0, 15], [0, 1]);
// Combine: transform: `translateY(${translateY}px)`, opacity
```

**Phone frame entrance:**
```tsx
const phoneEntrance = spring({
  frame: frame - 15,
  fps,
  config: {damping: 14, stiffness: 80},
});
// transform: `scale(${0.85 + entrance * 0.15}) translateY(${(1 - entrance) * 50}px)`
```

### 6. Design tokens

Keep all visual identity in one place:

```tsx
export const COLORS = {
  background: '#000000',
  surface: '#0A0A0A',
  accent: '#FFD60A',
  accentMuted: '#FFD60A80',
  accentGlow: '#FFD60A40',
  text: '#FFFFFF',
  textSecondary: '#A0A0A0',
};

export const FONTS = {
  display: "'Oswald', 'Bebas Neue', sans-serif",
  body: "'Source Sans 3', 'Helvetica Neue', sans-serif",
};

export const DURATIONS = {
  intro: 90,      // 3s
  feature: 120,   // 4s
  outro: 90,      // 3s
  transition: 30, // 1s
};
```

### 7. Render and QA (via mise)

```bash
# Preview in browser
mise run video:dev

# Render the main showcase video
mise run video:render:showcase

# Render any composition
mise run video:render -- BetterFitShowcase out/showcase.mp4

# Capture key frames for QA
mise run video:still -- BetterFitShowcase /tmp/frame-120.png --frame=120
```

**Raw Bun commands** (if not using mise):
```bash
cd videos
bun run dev              # Preview in browser
bun run render:showcase  # Render showcase
bun run still            # Render single frame
```

## Common patterns

### Feature showcase scene

```tsx
export const AppShowcaseScene: React.FC<{
  videoSrc: string;
  featureTitle: string;
  featureDescription: string;
  featureNumber: number;
}> = ({videoSrc, featureTitle, featureDescription, featureNumber}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  
  const phoneEntrance = spring({frame: frame - 15, fps, config: {damping: 14, stiffness: 80}});
  const videoOpacity = interpolate(frame, [20, 40], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  
  return (
    <AbsoluteFill style={{backgroundColor: '#000', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}}>
      <h2 style={{fontSize: 52, color: '#fff', textTransform: 'uppercase', marginBottom: 12}}>{featureTitle}</h2>
      <p style={{fontSize: 20, color: '#A0A0A0', marginBottom: 40, textAlign: 'center', maxWidth: 500}}>{featureDescription}</p>
      
      <div style={{transform: `scale(${0.85 + Math.max(0, phoneEntrance) * 0.15})`, opacity: Math.max(0, phoneEntrance)}}>
        <PhoneFrame>
          <OffthreadVideo src={staticFile(videoSrc)} style={{width: '100%', height: '100%', objectFit: 'cover', opacity: videoOpacity}} />
        </PhoneFrame>
      </div>
    </AbsoluteFill>
  );
};
```

### Text overlay with spring

```tsx
export const TextOverlay: React.FC<{text: string; delay?: number}> = ({text, delay = 0}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [delay, delay + 15], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const translateY = interpolate(frame, [delay, delay + 20], [40, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  
  return (
    <div style={{position: 'absolute', top: 100, left: 0, right: 0, textAlign: 'center', padding: '0 60px', transform: `translateY(${translateY}px)`, opacity, zIndex: 20}}>
      <h2 style={{fontSize: 64, fontWeight: 700, color: '#fff', textTransform: 'uppercase', textShadow: '0 2px 20px rgba(0,0,0,0.5)'}}>{text}</h2>
    </div>
  );
};
```

## Troubleshooting

### "MEDIA_ELEMENT_ERROR: Format error"
Re-encode videos to Chrome-compatible H.264:
```bash
ffmpeg -i input.mp4 -c:v libx264 -pix_fmt yuv420p -profile:v main -level 4.0 -movflags +faststart -an output.mp4
```

### "404 while downloading file"
Use `staticFile()` for video sources:
```tsx
<OffthreadVideo src={staticFile("video.mp4")} />
```

### Transitions not smooth
Ensure `TransitionSeries` wraps all scenes. Use `@remotion/transitions` package (installed via Bun).

## Related skills

- **betterfit-mise-workflows**: Build/render commands via mise (includes `video:*` tasks)
- **betterfit-testing**: Mobile MCP testing for capturing simulator footage

## External resources

- **remotion-saas-showcase**: PhoneFrame, Cursor, TextOverlay components
- **MATI Teaser**: Narrative arc structure, spring physics examples
- **Appshot**: App Store preview dimensions and store compliance
- **create-onboarding-video skill**: Isolated UI component approach

## Quick checklist

- [ ] Run `mise run video:install` to install deps
- [ ] Real app recordings captured and re-encoded in `public/`
- [ ] Brand colors/fonts defined in `constants.ts`
- [ ] PhoneFrame component with Dynamic Island
- [ ] Spring physics used for all animations (no linear easing)
- [ ] TransitionSeries with fade/slide transitions
- [ ] Text overlays with upward slide + fade entrance
- [ ] Cursor animation for tap interactions
- [ ] Key frames captured for QA (`mise run video:still`)
- [ ] Final render succeeds (`mise run video:render:showcase`)
