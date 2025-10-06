# VideoApp

## Overview
The **VideoFeedApp** is designed to deliver a vertically scrolling short-form video feed, inspired by platforms like **TikTok** and **Instagram Reels**.  
It provides users with a seamless, high-performance viewing experience where each video plays automatically, loops continuously, and transitions smoothly as users swipe up or down.  
The architecture focuses on efficiency, memory safety, and responsiveness to maintain a **60fps** performance standard.

## Architecture Approach
The application follows the **Model-View-ViewModel (MVVM)** pattern using **SwiftUI** for the declarative UI layer and **AVFoundation** for media playback.  
The data model handles fetching and decoding the video manifest, while the ViewModel manages playback state, preloading, and resource cleanup.  
Views are built with **SwiftUI’s ScrollView** and **LazyVStack** for efficient layout and lazy loading of video content.  
UIKit’s **AVPlayerLayer** is wrapped via `UIViewRepresentable` to provide hardware-accelerated rendering inside SwiftUI.

## Design Decisions and Trade-offs
The app combines **SwiftUI** and **UIKit** to balance modern UI patterns with mature, reliable video rendering.  
AVPlayer instances are managed through a custom **PlayerPool**, which reuses a limited number of players to prevent memory spikes.  
A **gesture-velocity detector** is implemented to provide natural scrolling behavior similar to TikTok.  
Using **HLS (HTTP Live Streaming)** ensures adaptive bitrate playback for smooth performance under varying network conditions.

## Memory Management
AVPlayer resources are reused across cells through the **PlayerPool**, minimizing memory churn.  
When a video scrolls off-screen, its player is paused and released from active memory.  
**LazyVStack** ensures that only visible and nearby cells are instantiated, while the ViewModel uses **weak references** where necessary to prevent retain cycles.  
Background tasks execute on non-main queues to maintain smooth UI rendering.

## Smooth Transition Strategy
The app preloads upcoming videos and begins buffering before they appear on screen, ensuring instant playback.  
Playback readiness is verified before advancing to the next video, preventing black frames.  
**Gesture velocity** determines whether to move one or multiple videos per swipe, giving a fluid experience.  
Looping playback is implemented using **AVPlayer observers**, ensuring uninterrupted playback.  
All transitions are optimized to minimize layout recomputation and UI thread load.

## Future Enhancements
Planned improvements include:
- Enhanced network resilience with retry and offline caching  
- A buffering indicator for unready videos  
- Adaptive prefetching that adjusts strategy based on network quality  
- Analytics integration for engagement metrics such as watch duration and scroll velocity  

## Summary
The **VideoFeedApp** architecture is lightweight, modular, and performant.  
It emphasizes real-time responsiveness, memory efficiency, and a clean separation of concerns.  
The result is a smooth, responsive video feed experience suitable for large-scale deployment—offering the best of **modern SwiftUI design** and **low-level AVFoundation performance**.

## Screenshots

  <img width="750" height="1334"  alt="Simulator Screenshot - iPhone 16 Pro - 2025-10-06 at 12 07 09" src="https://github.com/user-  attachments/assets/96c18260-4ffc-4169-9a04-06bc165efcca" />

  <img width="750" height="1334" alt="Simulator Screenshot - iPhone 16 Pro - 2025-10-06 at 12 07 51" src="https://github.com/user-  attachments/assets/34d951df-65f1-4a0b-a3d9-4c80a07e7e50" />

