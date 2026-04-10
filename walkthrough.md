# Technical Report: Storybook Backend Setup & Architecture

**Prepared By:** Backend Team Lead  
**Project:** Storybook Mobile Application  
**Status:** Backend Foundation Complete  

## 1. Project Overview
The **Storybook** application operates on an offline-first architecture designed for maximum reliability and seamless user experience. The system is distributed across a **Flutter** mobile client frontend and a **Supabase** backend, providing robust data synchronization, secure storage, and real-time capabilities.

## 2. Authentication Setup
User authentication is fully established and integrated using **Supabase Auth**. The following sign-in providers are configured and ready for implementation on the Flutter client:
* **Email & Password:** Standard authentication method enabled.
* **Google OAuth:** Configured for seamless, single-sign-on access.
* *Note: A trigger is in place to automatically generate user profiles upon successful registration.*

## 3. Database Schema
The relational database foundation consists of the following tables, all protected by strict Row Level Security (RLS) policies:
* **`profiles`**: Stores user metadata (username, full name, avatar URL) and maps directly to the `auth.users` system table.
* **`stories`**: The core entity storing top-level story metadata, authorship tracking, and publication status.
* **`story_pages`**: Stores the content, sequencing (page numbers), and associated illustration URLs for individual pages within a story.
* **`favorites`**: A join table tracking user-specific bookmarks and story likes.
* **`sync_queue`**: Essential for the offline-first architecture. It acts as an immutable ledger tracking local CRUD operations (Inserts, Updates, Deletes) generated while the mobile device is offline.

## 4. Storage Configuration
File and media hosting have been configured via Supabase Storage. The following buckets have been provisioned:
* **`avatars`**: Dedicated to hosting user profile images.
* **`story-images`**: Dedicated to hosting visual content for stories, including cover photos and individual page illustrations.

## 5. Storage Security (RLS Policies)
Strict access controls are enforced at the storage-bucket level to ensure data integrity and prevent unauthorized modifications:
* **Public Read Access**: enabled for story images and avatars to ensure fast app rendering.
* **Upload Restrictions**: Only authenticated users are allowed to upload assets.
* **Modification Authority**: Users can only modify or delete files they intrinsically own.
* **Enforced Partitioning**: Folder and file authority is rigidly enforced using the `auth.uid()` attribute.

## 6. File Structure Rules
To maintain an organized bucket system and respect RLS policies, all client-side uploads must adhere to the following file path hierarchy:
* **Avatars:** `avatars/<user_id>/profile.jpg`
* **Story Covers:** `story-images/<user_id>/cover_<story_id>.jpg`
* **Story Pages:** `story-images/<user_id>/pages/<story_id>_<page_number>.jpg`

## 7. Offline Architecture Design
To guarantee uninterrupted usage in zero-connectivity environments, an offline-first methodology is configured:
* **Local Data Layer:** The Flutter client will utilize **SQLite (Drift)** for robust, persistent local storage.
* **Locally Queued Actions:** A dedicated local `sync_queue` structure is mandated on the client side to stack user actions securely.
* **Offline-First Workflow:** Reads and writes will prioritize the local Drift database first. The client state will reconcile with the cloud only when connectivity is present.

## 8. Sync Strategy Decision
In a departure from automated server-centric syncing, the team has elected for a client-driven synchronization architecture:
* Synchronization reconciliation will be handled **entirely on the Flutter side**.
* There are currently **no Edge Functions or database triggers** actively processing the `sync_queue` on the backend.
* **Strategy:** Actions will be queued locally (in SQLite) and systematically pushed as batch operations directly to Supabase via the Flutter client once the network is restored.

## 9. System Constraints
To ensure the integrity of the established core architecture:
> [!WARNING]
> No team member is permitted to alter the PostgreSQL database schema, modify Row Level Security (RLS) rules, or change Storage configurations without prior approval from the Backend Lead. All subsequent feature development must conform to the defined offline-first architecture.

## 10. Status Summary
The backend foundation—encompassing the database schema, security rules, storage buckets, and authentication providers—is **fully prepared and deployed**. 

The system is now officially ready for immediate **Flutter integration** and frontend development.
