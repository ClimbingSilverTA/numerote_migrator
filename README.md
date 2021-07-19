# numerote_migrator

This is a package I created while developing [Numerote](https://apps.apple.com/us/app/numerote-word-count-note/id1507853252), a simple notepad app written with Flutter.

I wrote it because I originally created the app with React Native(Expo) and I used [WatermelonDB](https://github.com/Nozbe/WatermelonDB) - and needed to write some logic to migrate away from it(I still think Expo and WatermelonDB are great by the way).

This package depends on another package [numerote_core](https://github.com/ClimbingSilverTA/numerote_core) that includes the models used and an in-memory and SQLite adapters(created with [moor](https://moor.simonbinder.eu/)).
