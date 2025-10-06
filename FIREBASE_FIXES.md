# Firebase Index Creation Guide

## Required Composite Index

The app needs a composite index for the `lessonRetention` collection to support queries with multiple order-by clauses.

### Index Details:
- **Collection**: `lessonRetention`
- **Fields**: 
  - `nickname` (Ascending)
  - `completedAt` (Descending)
  - `__name__` (Descending)

### How to Create the Index:

1. **Option 1: Use the Firebase Console Link**
   - Click this link: https://console.firebase.google.com/v1/r/project/easy-mind-51834/firestore/indexes?create_composite=Cldwcm9qZWN0cy9lYXN5LW1pbmQtNTE4MzQvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2xlc3NvblJldGVudGlvbi9pbmRleGVzL18QARoMCghuaWNrbmFtZRABGg8KC2NvbXBsZXRlZEF0EAIaDAoIX19uYW1lX18QAg

2. **Option 2: Manual Creation**
   - Go to Firebase Console → Firestore → Indexes
   - Click "Create Index"
   - Select collection: `lessonRetention`
   - Add fields:
     - Field: `nickname`, Order: Ascending
     - Field: `completedAt`, Order: Descending
     - Field: `__name__`, Order: Descending
   - Click "Create"

### Alternative: Modify Query to Avoid Index

If you prefer not to create the index, you can modify the query in the code to use simpler ordering that doesn't require a composite index.

## Firestore Rules Updated

I've also updated the Firestore rules to allow access to these collections:
- `userStats` (Gamification System)
- `userBadges` (Gamification System) 
- `userActivities` (Gamification System)
- `focusSessions` (Focus System)
- `breakSessions` (Focus System)

## Notification Service Improved

The notification service now handles missing plugin errors more gracefully and won't crash the app if local notifications aren't available.
