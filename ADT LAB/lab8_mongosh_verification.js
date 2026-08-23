// ============================================================
// LAB - 8 : Import, Export, Dump, and Restore Operations in MongoDB
// mongosh verification steps
//
// HOW TO RUN:
//   mongosh "mongodb://localhost:27017" lab8_mongosh_verification.js
// or paste the contents into an interactive mongosh session.
//
// NOTE: `use canteendb` and `show collections` / `show dbs` are
// interactive-shell helpers, not valid JavaScript, so they throw a
// SyntaxError in script mode. This version uses db.getSiblingDB()
// and db.getCollectionNames() / db.adminCommand(), which work in
// BOTH interactive mode and script mode.
//
// Run this AFTER the import/dump/restore steps in commands.sh.
// ============================================================

db = db.getSiblingDB("canteendb");

// Create the collection before importing (mongoimport also creates
// it automatically if missing, so this is just belt-and-braces)
db.createCollection("users");
print(db.getCollectionNames());

// ------------------------------------------------------------
// Verify the imported data
// ------------------------------------------------------------
print("Count after first import:", db.users.countDocuments());   // 5

print(db.users.findOne());

// After appending users_extra.json via mongoimport
print("Count after second import:", db.users.countDocuments());   // 10

// (a) Total number of documents
print(db.users.countDocuments());

// (b) Display a sample document
print(db.users.findOne());

// (c) Display newly added records (userId >= 6)
print(db.users.find({ userId: { $gte: 6 } }).toArray());

// Display all users sorted by userId, showing only userId and name
print(db.users.find({}, { _id: 0, userId: 1, name: 1 }).sort({ userId: 1 }).toArray());

// ------------------------------------------------------------
// Delete documents (before restoring, to demonstrate restore)
// ------------------------------------------------------------

// Delete all student users
print(db.users.deleteMany({ userType: "Student" }));
// { acknowledged: true, deletedCount: 6 }

print("Count after deleting students:", db.users.countDocuments());   // 4

// Drop the entire collection
print(db.users.drop());
// true

// ------------------------------------------------------------
// Verify restoration (after running mongorestore from commands.sh)
// ------------------------------------------------------------

// (a) List databases
print(db.adminCommand({ listDatabases: 1 }));

// (b) List collections
db = db.getSiblingDB("canteendb");
print(db.getCollectionNames());

// (c) Total number of documents (post-restore)
print(db.users.countDocuments());   // 10

// (d) Sample document
print(db.users.findOne());

// ------------------------------------------------------------
// Create an index and verify usage
// ------------------------------------------------------------

print(db.users.createIndex({ email: 1 }));
// email_1

// Query that uses the index
print(db.users.find({ email: "rehita@gmail.com" }).toArray());

// Confirm the index is being used via the execution plan
print(db.users.find({ email: "rehita@gmail.com" }).explain("executionStats"));
// winningPlan.inputStage.stage: "IXSCAN", keyPattern: { email: 1 }
