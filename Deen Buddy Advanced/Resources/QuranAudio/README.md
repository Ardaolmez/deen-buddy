# Quran Audio Files

This directory contains audio files for Quran recitation.

## Directory Structure

```
QuranAudio/
├── Arabic/
│   └── Alafasy/
│       ├── 001/          # Surah 1 (Al-Fatihah)
│       │   ├── 001.mp3   # Verse 1
│       │   ├── 002.mp3   # Verse 2
│       │   └── ...
│       ├── 002/          # Surah 2 (Al-Baqarah)
│       │   ├── 001.mp3
│       │   ├── 002.mp3
│       │   └── ...
│       └── ...
└── English/
    └── IbrahimWalk/
        ├── 001.mp3       # Surah 1 (full chapter)
        ├── 002.mp3       # Surah 2 (full chapter)
        └── ...
```

## File Naming Convention

### Arabic Audio (Verse-by-Verse)
- **Format**: `{surah}/{verse}.mp3`
- **Surah**: 3-digit zero-padded number (001-114)
- **Verse**: 3-digit zero-padded number (001-286)
- **Example**: `001/001.mp3` = Surah 1, Verse 1

### English Audio (Chapter-by-Chapter)
- **Format**: `{surah}.mp3`
- **Surah**: 3-digit zero-padded number (001-114)
- **Example**: `001.mp3` = Surah 1 (Al-Fatihah)

## Downloading Audio Files

### ⭐ RECOMMENDED: EveryAyah.com (Easiest & Most Straightforward)

**Why EveryAyah.com is the best option:**
- ✅ **No account creation** - Direct downloads, no registration needed
- ✅ **Verse-by-verse MP3** - Perfect for our app structure
- ✅ **Multiple quality options** - 32kbps, 64kbps, 128kbps (recommended), 192kbps
- ✅ **ZIP archives** - Download entire surahs or full Quran at once
- ✅ **Pre-formatted filenames** - Already named correctly (e.g., `001001.mp3`)
- ✅ **Widely trusted** - Used by many established Islamic apps
- ✅ **Multiple reciters** - Mishary Alafasy, Abdul Basit, and many others

### Quick Start Guide

#### Arabic Recitation (Mishary Alafasy) - 128kbps

1. **Direct Download Link**:
   - Visit: https://everyayah.com/data/Alafasy_128kbps/
   - Or browse all options: https://everyayah.com/recitations_ayat.html

2. **Download Options**:
   - **Option A**: Download individual verse files (e.g., `001001.mp3`, `001002.mp3`)
   - **Option B**: Download ZIP archives by surah (easier!)

3. **File Organization**:
   - Files are pre-named: `001001.mp3` = Surah 1, Verse 1
   - Rename to our format: `001001.mp3` → `001.mp3` (remove surah prefix)
   - Create folder: `Arabic/Alafasy/001/`
   - Place verses inside: `001.mp3`, `002.mp3`, `003.mp3`, etc.

4. **For Testing** (Start with just Al-Fatihah):
   - Download: `001001.mp3` through `001007.mp3`
   - Rename to: `001.mp3` through `007.mp3`
   - Place in: `Arabic/Alafasy/001/`

#### English Translation (Ibrahim Walk)

1. **Archive.org Download**:
   - Visit: https://archive.org/details/quran-english-translation-audio
   - Download: "Quran Meaning Translated in English by Ibrahim Walk"
   - 114 MP3 files (one per chapter, ~192kbps quality)

2. **File Organization**:
   - Rename to 3-digit format: `1.mp3` → `001.mp3`, `2.mp3` → `002.mp3`, etc.
   - Place in: `English/IbrahimWalk/`

3. **For Testing**:
   - Download just `1.mp3` (Al-Fatihah)
   - Rename to: `001.mp3`
   - Place in: `English/IbrahimWalk/001.mp3`

#### Alternative: Combined Arabic + English (Verse-by-Verse)

For those who want both languages in a single audio file:
- Visit: https://archive.org/details/AlQuranWithEnglishSaheehIntlTranslation--RecitationByMishariIbnRashidAl-AfasyWithIbrahimWalk
- Each file: Arabic verse → English translation → Next verse
- More complex to implement but provides bilingual experience

## Commercial Usage & Licensing

⚠️ **Important Licensing Information** (Based on Research)

### What We Know:

**EveryAyah.com:**
- ✅ **Open and unrestricted** downloads for **personal and educational use**
- ✅ **Widely used** by many Islamic apps and projects
- ⚠️ **NOT explicitly guaranteed** for commercial app monetization
- ✅ **Likely permissive** for non-commercial or donation-based projects

**Archive.org:**
- ✅ Easy downloads for complete Quran or individual surahs
- ⚠️ Does NOT specify clear commercial-use rights
- 📝 Recommends checking with original source (TheChosenOne.info) for permissions

### Recommendations Based on Your App Type:

#### ✅ **Safe to Use** (No explicit permission needed):
- Personal projects and prototypes
- Educational/learning apps (non-monetized)
- Donation-based apps (no paid features)
- Internal tools or testing
- Non-profit Islamic organizations

#### ⚠️ **Seek Permission** (Contact reciters first):
- Apps with ads or monetization
- Paid app downloads
- In-app purchases
- Commercial distribution on App Store
- Apps by for-profit companies

### How to Proceed:

**Option 1: Start with Non-Commercial** (Recommended)
1. Build and test your app using these files
2. Launch as free/donation-based initially
3. Build user base
4. Seek formal permissions before monetizing

**Option 2: Get Permission First**
1. Contact Sheikh Mishary Rashid Alafasy's organization
2. Contact Ibrahim Walk (if using English audio)
3. Get written permission for commercial use
4. Keep documentation for App Store review

**Option 3: Find Explicitly Licensed Audio**
1. Search for reciters who explicitly allow commercial use
2. Look for Creative Commons or Public Domain recitations
3. May have fewer options but clearer legal standing

### Contact Information:

**For Permissions:**
- Sheikh Mishary Alafasy: Contact through his official website or Islamic organizations
- Ibrahim Walk: Research contact through Islamic audio production companies
- TheChosenOne.info: Original source mentioned by Archive.org

**Legal Consultation:**
If your app will generate significant revenue, consult with:
- Islamic legal scholars (for religious/ethical guidance)
- Intellectual property lawyer (for copyright guidance)

### Precedent:

Many successful Islamic apps (Quran.com, Muslim Pro, etc.) use similar audio resources, suggesting the community is generally permissive, but **always better to ask first** for commercial projects.

## Adding Files to Xcode Project

After downloading and organizing the audio files:

1. Open Xcode
2. Right-click on `Resources/QuranAudio` in Project Navigator
3. Select "Add Files to 'Deen Buddy Advanced'..."
4. Choose the audio folders
5. **Important**: Check "Copy items if needed"
6. Select "Create folder references" (not groups)
7. Add to target: "Deen Buddy Advanced"

## Testing Audio Playback

1. Add a few test files to verify the integration:
   - At minimum: `Arabic/Alafasy/001/001.mp3` through `001/007.mp3`
   - And: `English/IbrahimWalk/001.mp3`

2. Build and run the app
3. Navigate to a Quran chapter
4. Tap verse numbers to play audio
5. Use audio player controls at the bottom

## File Sizes

- **Arabic (verse-by-verse)**: ~6,236 files, ~500MB-1GB depending on quality
- **English (chapter-by-chapter)**: 114 files, ~100-200MB

For initial testing, consider:
- Adding only Al-Fatihah (Surah 1) first
- Testing functionality before adding all files
- Using lower bitrate files (32kbps or 64kbps) to reduce app size

## Future Enhancements

Potential features to implement:
- Download audio on-demand (streaming)
- Cache management
- Multiple reciter options
- Playback speed control
- Offline download manager
- Background playback with lock screen controls
